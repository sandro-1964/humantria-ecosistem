-- HUMANTRÍA — CORE FUNCTIONS V1
-- Status: BLOQUEANTE
-- Escopo: Funções governadas (SECURITY INVOKER, sem bypass invisível)

SET search_path TO core, foundation, public;

-- ============================================================================
-- TENANCY (reutiliza foundation)
-- ============================================================================

-- Obter tenant_id do contexto (usa função do foundation)
-- Nota: foundation.get_current_tenant_id() já existe, podemos reutilizar

-- ============================================================================
-- VALIDAÇÃO/NORMALIZAÇÃO DE IMPORT
-- ============================================================================

-- Normalizar email
CREATE OR REPLACE FUNCTION core.normalize_email(p_email TEXT)
RETURNS TEXT
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    IF p_email IS NULL THEN
        RETURN NULL;
    END IF;
    
    -- Remove espaços e converte para lowercase
    RETURN LOWER(TRIM(p_email));
END;
$$;

COMMENT ON FUNCTION core.normalize_email IS 'Normaliza email (trim + lowercase)';

-- Validar email
CREATE OR REPLACE FUNCTION core.validate_email(p_email TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    IF p_email IS NULL OR p_email = '' THEN
        RETURN FALSE;
    END IF;
    
    -- Validação básica de formato
    RETURN p_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
END;
$$;

COMMENT ON FUNCTION core.validate_email IS 'Valida formato de email';

-- Normalizar código (remove espaços, converte para uppercase)
CREATE OR REPLACE FUNCTION core.normalize_code(p_code TEXT)
RETURNS TEXT
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    IF p_code IS NULL THEN
        RETURN NULL;
    END IF;
    
    RETURN UPPER(TRIM(p_code));
END;
$$;

COMMENT ON FUNCTION core.normalize_code IS 'Normaliza código (trim + uppercase)';

-- Validar row de import
CREATE OR REPLACE FUNCTION core.validate_import_row(
    p_row_data JSONB,
    p_mappings JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_errors JSONB := '[]'::jsonb;
    v_warnings JSONB := '[]'::jsonb;
    v_mapping RECORD;
    v_value TEXT;
    v_is_required BOOLEAN;
BEGIN
    -- Itera sobre os mapeamentos
    FOR v_mapping IN 
        SELECT * FROM jsonb_array_elements(p_mappings) AS m
    LOOP
        v_value := p_row_data->>(v_mapping->>'source_column');
        v_is_required := COALESCE((v_mapping->>'is_required')::boolean, FALSE);
        
        -- Valida campos obrigatórios
        IF v_is_required AND (v_value IS NULL OR v_value = '') THEN
            v_errors := v_errors || jsonb_build_object(
                'field', v_mapping->>'target_field',
                'error', 'Campo obrigatório ausente'
            );
        END IF;
        
        -- Valida email se aplicável
        IF v_mapping->>'target_field' = 'email' AND v_value IS NOT NULL AND v_value != '' THEN
            IF NOT core.validate_email(core.normalize_email(v_value)) THEN
                v_errors := v_errors || jsonb_build_object(
                    'field', 'email',
                    'error', 'Formato de email inválido'
                );
            END IF;
        END IF;
    END LOOP;
    
    RETURN jsonb_build_object(
        'valid', jsonb_array_length(v_errors) = 0,
        'errors', v_errors,
        'warnings', v_warnings
    );
END;
$$;

COMMENT ON FUNCTION core.validate_import_row IS 'Valida uma linha de import baseado nos mapeamentos';

-- ============================================================================
-- CRUD GOVERNADAS (mínimo viável)
-- ============================================================================

-- Criar org_unit (com validação)
CREATE OR REPLACE FUNCTION core.create_org_unit(
    p_code TEXT,
    p_name TEXT,
    p_parent_id UUID DEFAULT NULL,
    p_org_unit_type TEXT DEFAULT NULL,
    p_description TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_org_unit_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Normaliza código
    p_code := core.normalize_code(p_code);
    
    -- Valida código único
    IF EXISTS (
        SELECT 1 FROM core.org_units 
        WHERE tenant_id = v_tenant_id AND code = p_code
    ) THEN
        RAISE EXCEPTION 'Org unit com código % já existe', p_code;
    END IF;
    
    -- Valida parent_id se fornecido
    IF p_parent_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM core.org_units 
            WHERE id = p_parent_id AND tenant_id = v_tenant_id
        ) THEN
            RAISE EXCEPTION 'Parent org_unit não encontrado ou não pertence ao tenant';
        END IF;
    END IF;
    
    -- Insere org_unit
    INSERT INTO core.org_units (
        tenant_id,
        code,
        name,
        parent_id,
        org_unit_type,
        description
    ) VALUES (
        v_tenant_id,
        p_code,
        p_name,
        p_parent_id,
        p_org_unit_type,
        p_description
    ) RETURNING id INTO v_org_unit_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'org_unit.created',
        'org_unit',
        v_org_unit_id,
        jsonb_build_object(
            'org_unit_id', v_org_unit_id,
            'code', p_code,
            'name', p_name,
            'parent_id', p_parent_id
        ),
        '1.0'
    );
    
    RETURN v_org_unit_id;
END;
$$;

COMMENT ON FUNCTION core.create_org_unit IS 'Cria org_unit com validação e evento';

-- Criar person (com validação)
CREATE OR REPLACE FUNCTION core.create_person(
    p_person_id TEXT,
    p_first_name TEXT,
    p_last_name TEXT,
    p_email TEXT,
    p_date_of_birth DATE DEFAULT NULL,
    p_gender TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_person_uuid UUID;
    v_email_normalized TEXT;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Valida email obrigatório
    IF p_email IS NULL OR p_email = '' THEN
        RAISE EXCEPTION 'Email é obrigatório';
    END IF;
    
    v_email_normalized := core.normalize_email(p_email);
    
    IF NOT core.validate_email(v_email_normalized) THEN
        RAISE EXCEPTION 'Email inválido: %', p_email;
    END IF;
    
    -- Valida person_id único
    IF EXISTS (
        SELECT 1 FROM core.people 
        WHERE tenant_id = v_tenant_id AND person_id = p_person_id
    ) THEN
        RAISE EXCEPTION 'Person com person_id % já existe', p_person_id;
    END IF;
    
    -- Insere person
    INSERT INTO core.people (
        tenant_id,
        person_id,
        first_name,
        last_name,
        date_of_birth,
        gender,
        display_name
    ) VALUES (
        v_tenant_id,
        p_person_id,
        p_first_name,
        p_last_name,
        p_date_of_birth,
        p_gender,
        p_first_name || ' ' || p_last_name
    ) RETURNING id INTO v_person_uuid;
    
    -- Insere contato email
    INSERT INTO core.person_contacts (
        tenant_id,
        person_id,
        contact_type,
        contact_value,
        is_primary,
        is_verified
    ) VALUES (
        v_tenant_id,
        v_person_uuid,
        'email',
        v_email_normalized,
        TRUE,
        FALSE
    );
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'person.created',
        'person',
        v_person_uuid,
        jsonb_build_object(
            'person_id', v_person_uuid,
            'person_id_code', p_person_id,
            'first_name', p_first_name,
            'last_name', p_last_name,
            'email', v_email_normalized
        ),
        '1.0'
    );
    
    RETURN v_person_uuid;
END;
$$;

COMMENT ON FUNCTION core.create_person IS 'Cria person com validação de email e evento';

-- Criar person org assignment (com validação)
CREATE OR REPLACE FUNCTION core.create_person_org_assignment(
    p_person_id UUID,
    p_org_unit_id UUID,
    p_job_id UUID DEFAULT NULL,
    p_job_level_id UUID DEFAULT NULL,
    p_cost_center_id UUID DEFAULT NULL,
    p_effective_from DATE DEFAULT CURRENT_DATE,
    p_assignment_type TEXT DEFAULT 'primary'
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_assignment_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Valida person existe
    IF NOT EXISTS (
        SELECT 1 FROM core.people 
        WHERE id = p_person_id AND tenant_id = v_tenant_id
    ) THEN
        RAISE EXCEPTION 'Person não encontrado ou não pertence ao tenant';
    END IF;
    
    -- Valida org_unit existe
    IF NOT EXISTS (
        SELECT 1 FROM core.org_units 
        WHERE id = p_org_unit_id AND tenant_id = v_tenant_id
    ) THEN
        RAISE EXCEPTION 'Org unit não encontrado ou não pertence ao tenant';
    END IF;
    
    -- Valida job se fornecido
    IF p_job_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM core.jobs 
            WHERE id = p_job_id AND tenant_id = v_tenant_id
        ) THEN
            RAISE EXCEPTION 'Job não encontrado ou não pertence ao tenant';
        END IF;
    END IF;
    
    -- Valida job_level se fornecido
    IF p_job_level_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM core.job_levels 
            WHERE id = p_job_level_id AND tenant_id = v_tenant_id
        ) THEN
            RAISE EXCEPTION 'Job level não encontrado ou não pertence ao tenant';
        END IF;
    END IF;
    
    -- Insere assignment
    INSERT INTO core.person_org_assignments (
        tenant_id,
        person_id,
        org_unit_id,
        job_id,
        job_level_id,
        cost_center_id,
        effective_from,
        assignment_type
    ) VALUES (
        v_tenant_id,
        p_person_id,
        p_org_unit_id,
        p_job_id,
        p_job_level_id,
        p_cost_center_id,
        p_effective_from,
        p_assignment_type
    ) RETURNING id INTO v_assignment_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'person_org_assignment.created',
        'person_org_assignment',
        v_assignment_id,
        jsonb_build_object(
            'assignment_id', v_assignment_id,
            'person_id', p_person_id,
            'org_unit_id', p_org_unit_id,
            'job_id', p_job_id,
            'effective_from', p_effective_from
        ),
        '1.0'
    );
    
    RETURN v_assignment_id;
END;
$$;

COMMENT ON FUNCTION core.create_person_org_assignment IS 'Cria person org assignment com validações e evento';

-- ============================================================================
-- HELPERS DE CONSULTA
-- ============================================================================

-- Obter org_unit com hierarquia (recursivo)
CREATE OR REPLACE FUNCTION core.get_org_unit_hierarchy(
    p_org_unit_id UUID
)
RETURNS TABLE (
    id UUID,
    tenant_id UUID,
    parent_id UUID,
    code TEXT,
    name TEXT,
    level INTEGER
)
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE org_hierarchy AS (
        -- Base: org_unit raiz
        SELECT 
            ou.id,
            ou.tenant_id,
            ou.parent_id,
            ou.code,
            ou.name,
            0 AS level
        FROM core.org_units ou
        WHERE ou.id = p_org_unit_id
        
        UNION ALL
        
        -- Recursão: filhos
        SELECT 
            ou.id,
            ou.tenant_id,
            ou.parent_id,
            ou.code,
            ou.name,
            oh.level + 1
        FROM core.org_units ou
        INNER JOIN org_hierarchy oh ON ou.parent_id = oh.id
    )
    SELECT * FROM org_hierarchy
    ORDER BY level, code;
END;
$$;

COMMENT ON FUNCTION core.get_org_unit_hierarchy IS 'Retorna hierarquia de org_unit (recursivo)';
