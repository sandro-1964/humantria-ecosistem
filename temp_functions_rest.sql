-- ============================================================================
-- B) SALARY STRUCTURE FUNCTIONS
-- ============================================================================

-- Criar estrutura salarial (com validaÃ§Ã£o e evento)
CREATE OR REPLACE FUNCTION core.create_salary_structure(
    p_currency TEXT,
    p_effective_from DATE,
    p_base_salary_min NUMERIC,
    p_base_salary_max NUMERIC,
    p_job_id UUID DEFAULT NULL,
    p_job_level_id UUID DEFAULT NULL,
    p_base_salary_mid NUMERIC DEFAULT NULL,
    p_compensation_structure JSONB DEFAULT '{}'::jsonb,
    p_effective_to DATE DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_salary_structure_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id nÃ£o encontrado no contexto';
    END IF;
    
    -- ValidaÃ§Ãµes
    IF p_base_salary_max < p_base_salary_min THEN
        RAISE EXCEPTION 'base_salary_max deve ser >= base_salary_min';
    END IF;
    
    IF p_base_salary_mid IS NOT NULL THEN
        IF p_base_salary_mid < p_base_salary_min OR p_base_salary_mid > p_base_salary_max THEN
            RAISE EXCEPTION 'base_salary_mid deve estar entre min e max';
        END IF;
    END IF;
    
    -- Valida job se fornecido
    IF p_job_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM core.jobs 
            WHERE id = p_job_id AND tenant_id = v_tenant_id
        ) THEN
            RAISE EXCEPTION 'Job nÃ£o encontrado ou nÃ£o pertence ao tenant';
        END IF;
    END IF;
    
    -- Valida job_level se fornecido
    IF p_job_level_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM core.job_levels 
            WHERE id = p_job_level_id AND tenant_id = v_tenant_id
        ) THEN
            RAISE EXCEPTION 'Job level nÃ£o encontrado ou nÃ£o pertence ao tenant';
        END IF;
    END IF;
    
    -- Insere estrutura salarial
    INSERT INTO core.salary_structures (
        tenant_id,
        job_id,
        job_level_id,
        currency,
        effective_from,
        effective_to,
        base_salary_min,
        base_salary_max,
        base_salary_mid,
        compensation_structure
    ) VALUES (
        v_tenant_id,
        p_job_id,
        p_job_level_id,
        p_currency,
        p_effective_from,
        p_effective_to,
        p_base_salary_min,
        p_base_salary_max,
        p_base_salary_mid,
        p_compensation_structure
    ) RETURNING id INTO v_salary_structure_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'salary_structure.created',
        'salary_structure',
        v_salary_structure_id,
        jsonb_build_object(
            'salary_structure_id', v_salary_structure_id,
            'job_id', p_job_id,
            'job_level_id', p_job_level_id,
            'currency', p_currency,
            'effective_from', p_effective_from
        ),
        '1.0'
    );
    
    RETURN v_salary_structure_id;
END;
$$;

COMMENT ON FUNCTION core.create_salary_structure IS 'Cria estrutura salarial com validaÃ§Ã£o e evento';

-- Atualizar estrutura salarial (com histÃ³rico automÃ¡tico)
CREATE OR REPLACE FUNCTION core.update_salary_structure(
    p_salary_structure_id UUID,
    p_effective_to DATE DEFAULT NULL,
    p_base_salary_min NUMERIC DEFAULT NULL,
    p_base_salary_max NUMERIC DEFAULT NULL,
    p_base_salary_mid NUMERIC DEFAULT NULL,
    p_compensation_structure JSONB DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_old_record RECORD;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id nÃ£o encontrado no contexto';
    END IF;
    
    -- Busca registro atual
    SELECT * INTO v_old_record
    FROM core.salary_structures
    WHERE id = p_salary_structure_id AND tenant_id = v_tenant_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Salary structure nÃ£o encontrado ou nÃ£o pertence ao tenant';
    END IF;
    
    -- Cria histÃ³rico antes de atualizar
    INSERT INTO core.salary_structure_history (
        salary_structure_id,
        tenant_id,
        effective_from,
        effective_to,
        base_salary_min,
        base_salary_max,
        base_salary_mid,
        compensation_structure,
        changed_by
    ) VALUES (
        p_salary_structure_id,
        v_tenant_id,
        v_old_record.effective_from,
        COALESCE(p_effective_to, v_old_record.effective_to),
        v_old_record.base_salary_min,
        v_old_record.base_salary_max,
        v_old_record.base_salary_mid,
        v_old_record.compensation_structure,
        (current_setting('request.jwt.claims', true)::json->>'user_id')::uuid
    );
    
    -- Atualiza registro
    UPDATE core.salary_structures
    SET
        effective_to = COALESCE(p_effective_to, effective_to),
        base_salary_min = COALESCE(p_base_salary_min, base_salary_min),
        base_salary_max = COALESCE(p_base_salary_max, base_salary_max),
        base_salary_mid = COALESCE(p_base_salary_mid, base_salary_mid),
        compensation_structure = COALESCE(p_compensation_structure, compensation_structure),
        updated_at = NOW()
    WHERE id = p_salary_structure_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'salary_structure.updated',
        'salary_structure',
        p_salary_structure_id,
        jsonb_build_object(
            'salary_structure_id', p_salary_structure_id,
            'effective_to', p_effective_to
        ),
        '1.0'
    );
    
    RETURN p_salary_structure_id;
END;
$$;

COMMENT ON FUNCTION core.update_salary_structure IS 'Atualiza estrutura salarial com histÃ³rico automÃ¡tico';

-- Obter estrutura salarial para job/level em data especÃ­fica
CREATE OR REPLACE FUNCTION core.get_salary_structure_for_job_level(
    p_job_id UUID DEFAULT NULL,
    p_job_level_id UUID DEFAULT NULL,
    p_currency TEXT DEFAULT NULL,
    p_effective_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    id UUID,
    job_id UUID,
    job_level_id UUID,
    currency TEXT,
    effective_from DATE,
    effective_to DATE,
    base_salary_min NUMERIC,
    base_salary_max NUMERIC,
    base_salary_mid NUMERIC
)
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
DECLARE
    v_tenant_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id nÃ£o encontrado no contexto';
    END IF;
    
    RETURN QUERY
    SELECT 
        ss.id,
        ss.job_id,
        ss.job_level_id,
        ss.currency,
        ss.effective_from,
        ss.effective_to,
        ss.base_salary_min,
        ss.base_salary_max,
        ss.base_salary_mid
    FROM core.salary_structures ss
    WHERE ss.tenant_id = v_tenant_id
        AND (p_job_id IS NULL OR ss.job_id = p_job_id OR ss.job_id IS NULL)
        AND (p_job_level_id IS NULL OR ss.job_level_id = p_job_level_id OR ss.job_level_id IS NULL)
        AND (p_currency IS NULL OR ss.currency = p_currency)
        AND ss.effective_from <= p_effective_date
        AND (ss.effective_to IS NULL OR ss.effective_to >= p_effective_date)
    ORDER BY 
        CASE WHEN ss.job_id IS NOT NULL AND ss.job_level_id IS NOT NULL THEN 1
             WHEN ss.job_id IS NOT NULL THEN 2
             WHEN ss.job_level_id IS NOT NULL THEN 3
             ELSE 4 END,
        ss.effective_from DESC
    LIMIT 1;
END;
$$;

COMMENT ON FUNCTION core.get_salary_structure_for_job_level IS 'ObtÃ©m estrutura salarial para job/level em data especÃ­fica';

-- ============================================================================
-- C) COST PARAMETER FUNCTIONS
-- ============================================================================

-- Criar parÃ¢metro de custo (com validaÃ§Ã£o e evento)
CREATE OR REPLACE FUNCTION core.create_cost_parameter(
    p_currency TEXT,
    p_effective_from DATE,
    p_base_cost NUMERIC,
    p_job_id UUID DEFAULT NULL,
    p_job_level_id UUID DEFAULT NULL,
    p_org_unit_id UUID DEFAULT NULL,
    p_cost_center_id UUID DEFAULT NULL,
    p_overhead_rate NUMERIC DEFAULT NULL,
    p_total_cost_factor NUMERIC DEFAULT NULL,
    p_cost_breakdown JSONB DEFAULT '{}'::jsonb,
    p_effective_to DATE DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_cost_parameter_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id nÃ£o encontrado no contexto';
    END IF;
    
    -- ValidaÃ§Ãµes
    IF p_base_cost < 0 THEN
        RAISE EXCEPTION 'base_cost deve ser >= 0';
    END IF;
    
    IF p_overhead_rate IS NOT NULL AND (p_overhead_rate < 0 OR p_overhead_rate > 100) THEN
        RAISE EXCEPTION 'overhead_rate deve estar entre 0 e 100';
    END IF;
    
    -- Valida job se fornecido
    IF p_job_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM core.jobs 
            WHERE id = p_job_id AND tenant_id = v_tenant_id
        ) THEN
            RAISE EXCEPTION 'Job nÃ£o encontrado ou nÃ£o pertence ao tenant';
        END IF;
    END IF;
    
    -- Valida org_unit se fornecido
    IF p_org_unit_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM core.org_units 
            WHERE id = p_org_unit_id AND tenant_id = v_tenant_id
        ) THEN
            RAISE EXCEPTION 'Org unit nÃ£o encontrado ou nÃ£o pertence ao tenant';
        END IF;
    END IF;
    
    -- Insere parÃ¢metro de custo
    INSERT INTO core.cost_parameters (
        tenant_id,
        job_id,
        job_level_id,
        org_unit_id,
        cost_center_id,
        currency,
        effective_from,
        effective_to,
        base_cost,
        overhead_rate,
        total_cost_factor,
        cost_breakdown
    ) VALUES (
        v_tenant_id,
        p_job_id,
        p_job_level_id,
        p_org_unit_id,
        p_cost_center_id,
        p_currency,
        p_effective_from,
        p_effective_to,
        p_base_cost,
        p_overhead_rate,
        p_total_cost_factor,
        p_cost_breakdown
    ) RETURNING id INTO v_cost_parameter_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'cost_parameter.created',
        'cost_parameter',
        v_cost_parameter_id,
        jsonb_build_object(
            'cost_parameter_id', v_cost_parameter_id,
            'job_id', p_job_id,
            'org_unit_id', p_org_unit_id,
            'currency', p_currency,
            'effective_from', p_effective_from
        ),
        '1.0'
    );
    
    RETURN v_cost_parameter_id;
END;
$$;

COMMENT ON FUNCTION core.create_cost_parameter IS 'Cria parÃ¢metro de custo com validaÃ§Ã£o e evento';

-- Atualizar parÃ¢metro de custo (com histÃ³rico automÃ¡tico)
CREATE OR REPLACE FUNCTION core.update_cost_parameter(
    p_cost_parameter_id UUID,
    p_effective_to DATE DEFAULT NULL,
    p_base_cost NUMERIC DEFAULT NULL,
    p_overhead_rate NUMERIC DEFAULT NULL,
    p_total_cost_factor NUMERIC DEFAULT NULL,
    p_cost_breakdown JSONB DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_old_record RECORD;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id nÃ£o encontrado no contexto';
    END IF;
    
    -- Busca registro atual
    SELECT * INTO v_old_record
    FROM core.cost_parameters
    WHERE id = p_cost_parameter_id AND tenant_id = v_tenant_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Cost parameter nÃ£o encontrado ou nÃ£o pertence ao tenant';
    END IF;
    
    -- Cria histÃ³rico antes de atualizar
    INSERT INTO core.cost_parameter_history (
        cost_parameter_id,
        tenant_id,
        effective_from,
        effective_to,
        base_cost,
        overhead_rate,
        total_cost_factor,
        cost_breakdown,
        changed_by
    ) VALUES (
        p_cost_parameter_id,
        v_tenant_id,
        v_old_record.effective_from,
        COALESCE(p_effective_to, v_old_record.effective_to),
        v_old_record.base_cost,
        v_old_record.overhead_rate,
        v_old_record.total_cost_factor,
        v_old_record.cost_breakdown,
        (current_setting('request.jwt.claims', true)::json->>'user_id')::uuid
    );
    
    -- Atualiza registro
    UPDATE core.cost_parameters
    SET
        effective_to = COALESCE(p_effective_to, effective_to),
        base_cost = COALESCE(p_base_cost, base_cost),
        overhead_rate = COALESCE(p_overhead_rate, overhead_rate),
        total_cost_factor = COALESCE(p_total_cost_factor, total_cost_factor),
        cost_breakdown = COALESCE(p_cost_breakdown, cost_breakdown),
        updated_at = NOW()
    WHERE id = p_cost_parameter_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'cost_parameter.updated',
        'cost_parameter',
        p_cost_parameter_id,
        jsonb_build_object(
            'cost_parameter_id', p_cost_parameter_id,
            'effective_to', p_effective_to
        ),
        '1.0'
    );
    
    RETURN p_cost_parameter_id;
END;
$$;

COMMENT ON FUNCTION core.update_cost_parameter IS 'Atualiza parÃ¢metro de custo com histÃ³rico automÃ¡tico';

-- Obter parÃ¢metro de custo para contexto
CREATE OR REPLACE FUNCTION core.get_cost_parameter_for_context(
    p_job_id UUID DEFAULT NULL,
    p_job_level_id UUID DEFAULT NULL,
    p_org_unit_id UUID DEFAULT NULL,
    p_cost_center_id UUID DEFAULT NULL,
    p_currency TEXT DEFAULT NULL,
    p_effective_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    id UUID,
    job_id UUID,
    job_level_id UUID,
    org_unit_id UUID,
    cost_center_id UUID,
    currency TEXT,
    effective_from DATE,
    effective_to DATE,
    base_cost NUMERIC,
    overhead_rate NUMERIC,
    total_cost_factor NUMERIC
)
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
DECLARE
    v_tenant_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id nÃ£o encontrado no contexto';
    END IF;
    
    RETURN QUERY
    SELECT 
        cp.id,
        cp.job_id,
        cp.job_level_id,
        cp.org_unit_id,
        cp.cost_center_id,
        cp.currency,
        cp.effective_from,
        cp.effective_to,
        cp.base_cost,
        cp.overhead_rate,
        cp.total_cost_factor
    FROM core.cost_parameters cp
    WHERE cp.tenant_id = v_tenant_id
        AND (p_job_id IS NULL OR cp.job_id = p_job_id OR cp.job_id IS NULL)
        AND (p_job_level_id IS NULL OR cp.job_level_id = p_job_level_id OR cp.job_level_id IS NULL)
        AND (p_org_unit_id IS NULL OR cp.org_unit_id = p_org_unit_id OR cp.org_unit_id IS NULL)
        AND (p_cost_center_id IS NULL OR cp.cost_center_id = p_cost_center_id OR cp.cost_center_id IS NULL)
        AND (p_currency IS NULL OR cp.currency = p_currency)
        AND cp.effective_from <= p_effective_date
        AND (cp.effective_to IS NULL OR cp.effective_to >= p_effective_date)
    ORDER BY 
        CASE WHEN cp.job_id IS NOT NULL AND cp.job_level_id IS NOT NULL AND cp.org_unit_id IS NOT NULL THEN 1
             WHEN cp.job_id IS NOT NULL AND cp.job_level_id IS NOT NULL THEN 2
             WHEN cp.job_id IS NOT NULL THEN 3
             WHEN cp.org_unit_id IS NOT NULL THEN 4
             ELSE 5 END,
        cp.effective_from DESC
    LIMIT 1;
END;
$$;

COMMENT ON FUNCTION core.get_cost_parameter_for_context IS 'ObtÃ©m parÃ¢metro de custo para contexto (job/level/org/cost_center)';
