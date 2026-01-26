-- HUMANTRÍA — STRATEGY FUNCTIONS V1
-- Status: BLOQUEANTE
-- Escopo: Funções governadas (SECURITY INVOKER, sem bypass invisível)

SET search_path TO strategy, core, foundation, public;

-- ============================================================================
-- OBJETIVOS & METAS
-- ============================================================================

-- Criar objective (com validação e histórico)
CREATE OR REPLACE FUNCTION strategy.create_objective(
    p_code TEXT,
    p_title TEXT,
    p_template_id UUID DEFAULT NULL,
    p_methodology_type TEXT DEFAULT 'okr',
    p_cycle_type TEXT DEFAULT 'quarterly',
    p_cycle_start_date DATE DEFAULT CURRENT_DATE,
    p_cycle_end_date DATE,
    p_owner_person_id UUID DEFAULT NULL,
    p_description TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_objective_id UUID;
    v_end_date DATE;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Normaliza código
    p_code := core.normalize_code(p_code);
    
    -- Valida código único
    IF EXISTS (
        SELECT 1 FROM strategy.objectives 
        WHERE tenant_id = v_tenant_id AND code = p_code
    ) THEN
        RAISE EXCEPTION 'Objective com código % já existe', p_code;
    END IF;
    
    -- Calcula end_date se não fornecido
    IF p_cycle_end_date IS NULL THEN
        CASE p_cycle_type
            WHEN 'annual' THEN v_end_date := p_cycle_start_date + INTERVAL '1 year' - INTERVAL '1 day';
            WHEN 'semiannual' THEN v_end_date := p_cycle_start_date + INTERVAL '6 months' - INTERVAL '1 day';
            WHEN 'quarterly' THEN v_end_date := p_cycle_start_date + INTERVAL '3 months' - INTERVAL '1 day';
            WHEN 'monthly' THEN v_end_date := p_cycle_start_date + INTERVAL '1 month' - INTERVAL '1 day';
            ELSE v_end_date := p_cycle_start_date + INTERVAL '3 months' - INTERVAL '1 day';
        END CASE;
    ELSE
        v_end_date := p_cycle_end_date;
    END IF;
    
    -- Valida owner se fornecido
    IF p_owner_person_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM core.people 
            WHERE id = p_owner_person_id AND tenant_id = v_tenant_id
        ) THEN
            RAISE EXCEPTION 'Owner person não encontrado ou não pertence ao tenant';
        END IF;
    END IF;
    
    -- Insere objective
    INSERT INTO strategy.objectives (
        tenant_id,
        template_id,
        code,
        title,
        description,
        methodology_type,
        cycle_type,
        cycle_start_date,
        cycle_end_date,
        owner_person_id,
        status
    ) VALUES (
        v_tenant_id,
        p_template_id,
        p_code,
        p_title,
        p_description,
        p_methodology_type,
        p_cycle_type,
        p_cycle_start_date,
        v_end_date,
        p_owner_person_id,
        'draft'
    ) RETURNING id INTO v_objective_id;
    
    -- Registra histórico inicial
    INSERT INTO strategy.objective_history (
        tenant_id,
        objective_id,
        version,
        changed_at,
        changes,
        justification
    ) VALUES (
        v_tenant_id,
        v_objective_id,
        1,
        NOW(),
        jsonb_build_object('action', 'created', 'title', p_title),
        'Objective criado'
    );
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.objective.created',
        'objective',
        v_objective_id,
        jsonb_build_object(
            'objective_id', v_objective_id,
            'code', p_code,
            'title', p_title,
            'methodology_type', p_methodology_type
        ),
        '1.0'
    );
    
    RETURN v_objective_id;
END;
$$;

COMMENT ON FUNCTION strategy.create_objective IS 'Cria objective com validação, histórico e evento';

-- Atualizar objective (com histórico)
CREATE OR REPLACE FUNCTION strategy.update_objective(
    p_objective_id UUID,
    p_title TEXT DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_status TEXT DEFAULT NULL,
    p_justification TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_current_version INTEGER;
    v_changes JSONB := '{}'::jsonb;
    v_old RECORD;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Busca objective atual
    SELECT * INTO v_old FROM strategy.objectives 
    WHERE id = p_objective_id AND tenant_id = v_tenant_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Objective não encontrado ou não pertence ao tenant';
    END IF;
    
    -- Prepara mudanças
    IF p_title IS NOT NULL AND p_title != v_old.title THEN
        v_changes := v_changes || jsonb_build_object('title', jsonb_build_object('old', v_old.title, 'new', p_title));
    END IF;
    
    IF p_description IS NOT NULL AND p_description != COALESCE(v_old.description, '') THEN
        v_changes := v_changes || jsonb_build_object('description', jsonb_build_object('old', v_old.description, 'new', p_description));
    END IF;
    
    IF p_status IS NOT NULL AND p_status != v_old.status THEN
        v_changes := v_changes || jsonb_build_object('status', jsonb_build_object('old', v_old.status, 'new', p_status));
    END IF;
    
    -- Atualiza se houver mudanças
    IF jsonb_object_keys(v_changes) IS NOT NULL THEN
        UPDATE strategy.objectives SET
            title = COALESCE(p_title, title),
            description = COALESCE(p_description, description),
            status = COALESCE(p_status, status),
            updated_at = NOW()
        WHERE id = p_objective_id;
        
        -- Busca próxima versão
        SELECT COALESCE(MAX(version), 0) + 1 INTO v_current_version
        FROM strategy.objective_history
        WHERE objective_id = p_objective_id;
        
        -- Registra histórico
        INSERT INTO strategy.objective_history (
            tenant_id,
            objective_id,
            version,
            changed_at,
            changes,
            justification
        ) VALUES (
            v_tenant_id,
            p_objective_id,
            v_current_version,
            NOW(),
            v_changes,
            p_justification
        );
        
        -- Publica evento
        PERFORM foundation.publish_event(
            'strategy.objective.updated',
            'objective',
            p_objective_id,
            jsonb_build_object(
                'objective_id', p_objective_id,
                'changes', v_changes
            ),
            '1.0'
        );
    END IF;
    
    RETURN p_objective_id;
END;
$$;

COMMENT ON FUNCTION strategy.update_objective IS 'Atualiza objective com histórico e evento';

-- Criar key result
CREATE OR REPLACE FUNCTION strategy.create_key_result(
    p_objective_id UUID,
    p_code TEXT,
    p_title TEXT,
    p_target_value NUMERIC,
    p_current_value NUMERIC DEFAULT 0,
    p_metric_type TEXT DEFAULT NULL,
    p_unit TEXT DEFAULT NULL,
    p_owner_person_id UUID DEFAULT NULL,
    p_description TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_key_result_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Valida objective existe
    IF NOT EXISTS (
        SELECT 1 FROM strategy.objectives 
        WHERE id = p_objective_id AND tenant_id = v_tenant_id
    ) THEN
        RAISE EXCEPTION 'Objective não encontrado ou não pertence ao tenant';
    END IF;
    
    -- Normaliza código
    p_code := core.normalize_code(p_code);
    
    -- Valida código único no objective
    IF EXISTS (
        SELECT 1 FROM strategy.key_results 
        WHERE tenant_id = v_tenant_id AND objective_id = p_objective_id AND code = p_code
    ) THEN
        RAISE EXCEPTION 'Key result com código % já existe neste objective', p_code;
    END IF;
    
    -- Valida owner se fornecido
    IF p_owner_person_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM core.people 
            WHERE id = p_owner_person_id AND tenant_id = v_tenant_id
        ) THEN
            RAISE EXCEPTION 'Owner person não encontrado ou não pertence ao tenant';
        END IF;
    END IF;
    
    -- Insere key result
    INSERT INTO strategy.key_results (
        tenant_id,
        objective_id,
        code,
        title,
        description,
        metric_type,
        current_value,
        target_value,
        unit,
        owner_person_id,
        status
    ) VALUES (
        v_tenant_id,
        p_objective_id,
        p_code,
        p_title,
        p_description,
        p_metric_type,
        p_current_value,
        p_target_value,
        p_unit,
        p_owner_person_id,
        'draft'
    ) RETURNING id INTO v_key_result_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.key_result.created',
        'key_result',
        v_key_result_id,
        jsonb_build_object(
            'key_result_id', v_key_result_id,
            'objective_id', p_objective_id,
            'code', p_code,
            'title', p_title
        ),
        '1.0'
    );
    
    RETURN v_key_result_id;
END;
$$;

COMMENT ON FUNCTION strategy.create_key_result IS 'Cria key result com validação e evento';

-- Atualizar key result
CREATE OR REPLACE FUNCTION strategy.update_key_result(
    p_key_result_id UUID,
    p_current_value NUMERIC DEFAULT NULL,
    p_target_value NUMERIC DEFAULT NULL,
    p_status TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Valida key result existe
    IF NOT EXISTS (
        SELECT 1 FROM strategy.key_results 
        WHERE id = p_key_result_id AND tenant_id = v_tenant_id
    ) THEN
        RAISE EXCEPTION 'Key result não encontrado ou não pertence ao tenant';
    END IF;
    
    -- Atualiza
    UPDATE strategy.key_results SET
        current_value = COALESCE(p_current_value, current_value),
        target_value = COALESCE(p_target_value, target_value),
        status = COALESCE(p_status, status),
        updated_at = NOW()
    WHERE id = p_key_result_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.key_result.updated',
        'key_result',
        p_key_result_id,
        jsonb_build_object(
            'key_result_id', p_key_result_id,
            'current_value', COALESCE(p_current_value, (SELECT current_value FROM strategy.key_results WHERE id = p_key_result_id)),
            'target_value', COALESCE(p_target_value, (SELECT target_value FROM strategy.key_results WHERE id = p_key_result_id))
        ),
        '1.0'
    );
    
    RETURN p_key_result_id;
END;
$$;

COMMENT ON FUNCTION strategy.update_key_result IS 'Atualiza key result com evento';

-- Adicionar evidência a objective
CREATE OR REPLACE FUNCTION strategy.add_objective_evidence(
    p_objective_id UUID,
    p_evidence_type TEXT,
    p_title TEXT,
    p_attachment_url TEXT DEFAULT NULL,
    p_attachment_type TEXT DEFAULT NULL,
    p_description TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_evidence_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Valida objective existe
    IF NOT EXISTS (
        SELECT 1 FROM strategy.objectives 
        WHERE id = p_objective_id AND tenant_id = v_tenant_id
    ) THEN
        RAISE EXCEPTION 'Objective não encontrado ou não pertence ao tenant';
    END IF;
    
    -- Insere evidência (imutável)
    INSERT INTO strategy.objective_evidence (
        tenant_id,
        objective_id,
        evidence_type,
        title,
        description,
        attachment_url,
        attachment_type
    ) VALUES (
        v_tenant_id,
        p_objective_id,
        p_evidence_type,
        p_title,
        p_description,
        p_attachment_url,
        p_attachment_type
    ) RETURNING id INTO v_evidence_id;
    
    RETURN v_evidence_id;
END;
$$;

COMMENT ON FUNCTION strategy.add_objective_evidence IS 'Adiciona evidência a objective (imutável)';

-- ============================================================================
-- ORÇAMENTO
-- ============================================================================

-- Criar budget version
CREATE OR REPLACE FUNCTION strategy.create_budget_version(
    p_code TEXT,
    p_name TEXT,
    p_baseline_version_id UUID DEFAULT NULL,
    p_description TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_budget_version_id UUID;
    v_version_number INTEGER;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Normaliza código
    p_code := core.normalize_code(p_code);
    
    -- Valida código único
    IF EXISTS (
        SELECT 1 FROM strategy.budget_versions 
        WHERE tenant_id = v_tenant_id AND code = p_code
    ) THEN
        RAISE EXCEPTION 'Budget version com código % já existe', p_code;
    END IF;
    
    -- Calcula version_number
    IF p_baseline_version_id IS NULL THEN
        v_version_number := 1;
    ELSE
        SELECT version_number + 1 INTO v_version_number
        FROM strategy.budget_versions
        WHERE id = p_baseline_version_id AND tenant_id = v_tenant_id;
        
        IF v_version_number IS NULL THEN
            RAISE EXCEPTION 'Baseline version não encontrada';
        END IF;
    END IF;
    
    -- Insere budget version
    INSERT INTO strategy.budget_versions (
        tenant_id,
        code,
        name,
        description,
        version_number,
        baseline_version_id,
        status
    ) VALUES (
        v_tenant_id,
        p_code,
        p_name,
        p_description,
        v_version_number,
        p_baseline_version_id,
        'draft'
    ) RETURNING id INTO v_budget_version_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.budget_version.created',
        'budget_version',
        v_budget_version_id,
        jsonb_build_object(
            'budget_version_id', v_budget_version_id,
            'code', p_code,
            'version_number', v_version_number
        ),
        '1.0'
    );
    
    RETURN v_budget_version_id;
END;
$$;

COMMENT ON FUNCTION strategy.create_budget_version IS 'Cria budget version com validação e evento';

-- Criar budget item
CREATE OR REPLACE FUNCTION strategy.create_budget_item(
    p_budget_version_id UUID,
    p_item_type TEXT,
    p_amount_original_currency NUMERIC,
    p_currency_code TEXT,
    p_period_start DATE,
    p_period_end DATE,
    p_org_unit_id UUID DEFAULT NULL,
    p_cost_center_id UUID DEFAULT NULL,
    p_project_id UUID DEFAULT NULL,
    p_category TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_budget_item_id UUID;
    v_base_currency TEXT;
    v_amount_base NUMERIC;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Valida budget version existe
    IF NOT EXISTS (
        SELECT 1 FROM strategy.budget_versions 
        WHERE id = p_budget_version_id AND tenant_id = v_tenant_id
    ) THEN
        RAISE EXCEPTION 'Budget version não encontrada ou não pertence ao tenant';
    END IF;
    
    -- Obtém base currency do tenant
    SELECT base_currency INTO v_base_currency
    FROM foundation.tenant_settings
    WHERE tenant_id = v_tenant_id;
    
    IF v_base_currency IS NULL THEN
        v_base_currency := 'BRL'; -- default
    END IF;
    
    -- Converte para base currency (se necessário)
    -- NOTA: core.convert_currency() não existe ainda, então usa valor original se mesma moeda
    IF p_currency_code = v_base_currency THEN
        v_amount_base := p_amount_original_currency;
    ELSE
        -- TODO: Quando core.convert_currency() existir, usar aqui
        -- v_amount_base := core.convert_currency(p_currency_code, v_base_currency, p_amount_original_currency, CURRENT_DATE);
        -- Por enquanto, assume 1:1 (será corrigido quando economics existir)
        v_amount_base := p_amount_original_currency;
    END IF;
    
    -- Valida item_type
    IF p_item_type = 'org_unit' AND p_org_unit_id IS NULL THEN
        RAISE EXCEPTION 'org_unit_id é obrigatório para item_type org_unit';
    END IF;
    
    IF p_item_type = 'cost_center' AND p_cost_center_id IS NULL THEN
        RAISE EXCEPTION 'cost_center_id é obrigatório para item_type cost_center';
    END IF;
    
    -- Valida org_unit se fornecido
    IF p_org_unit_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM core.org_units 
            WHERE id = p_org_unit_id AND tenant_id = v_tenant_id
        ) THEN
            RAISE EXCEPTION 'Org unit não encontrado ou não pertence ao tenant';
        END IF;
    END IF;
    
    -- Valida cost_center se fornecido
    IF p_cost_center_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM core.cost_centers 
            WHERE id = p_cost_center_id AND tenant_id = v_tenant_id
        ) THEN
            RAISE EXCEPTION 'Cost center não encontrado ou não pertence ao tenant';
        END IF;
    END IF;
    
    -- Insere budget item
    INSERT INTO strategy.budget_items (
        tenant_id,
        budget_version_id,
        item_type,
        org_unit_id,
        project_id,
        cost_center_id,
        category,
        amount_base_currency,
        currency_code,
        amount_original_currency,
        period_start,
        period_end
    ) VALUES (
        v_tenant_id,
        p_budget_version_id,
        p_item_type,
        p_org_unit_id,
        p_project_id,
        p_cost_center_id,
        p_category,
        v_amount_base,
        p_currency_code,
        p_amount_original_currency,
        p_period_start,
        p_period_end
    ) RETURNING id INTO v_budget_item_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.budget_item.created',
        'budget_item',
        v_budget_item_id,
        jsonb_build_object(
            'budget_item_id', v_budget_item_id,
            'budget_version_id', p_budget_version_id,
            'item_type', p_item_type,
            'amount_base_currency', v_amount_base
        ),
        '1.0'
    );
    
    RETURN v_budget_item_id;
END;
$$;

COMMENT ON FUNCTION strategy.create_budget_item IS 'Cria budget item com validação e conversão de moeda (quando economics existir)';

-- Atualizar budget item
CREATE OR REPLACE FUNCTION strategy.update_budget_item(
    p_budget_item_id UUID,
    p_amount_original_currency NUMERIC DEFAULT NULL,
    p_category TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_base_currency TEXT;
    v_amount_base NUMERIC;
    v_currency_code TEXT;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Busca currency_code do item
    SELECT currency_code INTO v_currency_code
    FROM strategy.budget_items
    WHERE id = p_budget_item_id AND tenant_id = v_tenant_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Budget item não encontrado ou não pertence ao tenant';
    END IF;
    
    -- Obtém base currency
    SELECT base_currency INTO v_base_currency
    FROM foundation.tenant_settings
    WHERE tenant_id = v_tenant_id;
    
    IF v_base_currency IS NULL THEN
        v_base_currency := 'BRL';
    END IF;
    
    -- Converte se amount mudou
    IF p_amount_original_currency IS NOT NULL THEN
        IF v_currency_code = v_base_currency THEN
            v_amount_base := p_amount_original_currency;
        ELSE
            -- TODO: Quando core.convert_currency() existir, usar aqui
            v_amount_base := p_amount_original_currency;
        END IF;
        
        UPDATE strategy.budget_items SET
            amount_original_currency = p_amount_original_currency,
            amount_base_currency = v_amount_base,
            category = COALESCE(p_category, category),
            updated_at = NOW()
        WHERE id = p_budget_item_id;
    ELSE
        UPDATE strategy.budget_items SET
            category = COALESCE(p_category, category),
            updated_at = NOW()
        WHERE id = p_budget_item_id;
    END IF;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.budget_item.updated',
        'budget_item',
        p_budget_item_id,
        jsonb_build_object(
            'budget_item_id', p_budget_item_id,
            'amount_base_currency', v_amount_base
        ),
        '1.0'
    );
    
    RETURN p_budget_item_id;
END;
$$;

COMMENT ON FUNCTION strategy.update_budget_item IS 'Atualiza budget item com evento';

-- Submeter budget para aprovação
CREATE OR REPLACE FUNCTION strategy.submit_budget_for_approval(
    p_budget_version_id UUID,
    p_workflow_id UUID
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_approval_request_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Valida budget version existe
    IF NOT EXISTS (
        SELECT 1 FROM strategy.budget_versions 
        WHERE id = p_budget_version_id AND tenant_id = v_tenant_id
    ) THEN
        RAISE EXCEPTION 'Budget version não encontrada ou não pertence ao tenant';
    END IF;
    
    -- Cria approval request
    v_approval_request_id := strategy.create_approval_request(
        p_workflow_id,
        'budget_version',
        p_budget_version_id
    );
    
    -- Atualiza status do budget version
    UPDATE strategy.budget_versions SET
        status = 'pending_approval',
        updated_at = NOW()
    WHERE id = p_budget_version_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.budget_version.submitted',
        'budget_version',
        p_budget_version_id,
        jsonb_build_object(
            'budget_version_id', p_budget_version_id,
            'approval_request_id', v_approval_request_id
        ),
        '1.0'
    );
    
    RETURN v_approval_request_id;
END;
$$;

COMMENT ON FUNCTION strategy.submit_budget_for_approval IS 'Submete budget version para aprovação via workflow';

-- Aprovar budget
CREATE OR REPLACE FUNCTION strategy.approve_budget(
    p_budget_version_id UUID,
    p_approver_person_id UUID,
    p_approval_level INTEGER,
    p_comments TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_approval_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Valida budget version existe
    IF NOT EXISTS (
        SELECT 1 FROM strategy.budget_versions 
        WHERE id = p_budget_version_id AND tenant_id = v_tenant_id
    ) THEN
        RAISE EXCEPTION 'Budget version não encontrada ou não pertence ao tenant';
    END IF;
    
    -- Insere approval
    INSERT INTO strategy.budget_approvals (
        tenant_id,
        budget_version_id,
        approver_person_id,
        approval_level,
        status,
        approved_at,
        comments
    ) VALUES (
        v_tenant_id,
        p_budget_version_id,
        p_approver_person_id,
        p_approval_level,
        'approved',
        NOW(),
        p_comments
    ) RETURNING id INTO v_approval_id;
    
    -- Atualiza status do budget version
    UPDATE strategy.budget_versions SET
        status = 'approved',
        approved_at = NOW(),
        approved_by = p_approver_person_id,
        updated_at = NOW()
    WHERE id = p_budget_version_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.budget_version.approved',
        'budget_version',
        p_budget_version_id,
        jsonb_build_object(
            'budget_version_id', p_budget_version_id,
            'approval_id', v_approval_id,
            'approver_person_id', p_approver_person_id
        ),
        '1.0'
    );
    
    RETURN v_approval_id;
END;
$$;

COMMENT ON FUNCTION strategy.approve_budget IS 'Aprova budget version';

-- Registrar budget actual
CREATE OR REPLACE FUNCTION strategy.record_budget_actual(
    p_budget_item_id UUID,
    p_period DATE,
    p_actual_amount_base_currency NUMERIC,
    p_source_system TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_budget_actual_id UUID;
    v_budgeted_amount NUMERIC;
    v_variance_amount NUMERIC;
    v_variance_percentage NUMERIC;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Busca valor orçado
    SELECT amount_base_currency INTO v_budgeted_amount
    FROM strategy.budget_items
    WHERE id = p_budget_item_id AND tenant_id = v_tenant_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Budget item não encontrado ou não pertence ao tenant';
    END IF;
    
    -- Calcula variância
    v_variance_amount := p_actual_amount_base_currency - v_budgeted_amount;
    IF v_budgeted_amount != 0 THEN
        v_variance_percentage := (v_variance_amount / v_budgeted_amount) * 100;
    ELSE
        v_variance_percentage := NULL;
    END IF;
    
    -- Insere ou atualiza actual
    INSERT INTO strategy.budget_actuals (
        tenant_id,
        budget_item_id,
        period,
        actual_amount_base_currency,
        variance_amount,
        variance_percentage,
        source_system
    ) VALUES (
        v_tenant_id,
        p_budget_item_id,
        p_period,
        p_actual_amount_base_currency,
        v_variance_amount,
        v_variance_percentage,
        p_source_system
    )
    ON CONFLICT (budget_item_id, period) DO UPDATE SET
        actual_amount_base_currency = EXCLUDED.actual_amount_base_currency,
        variance_amount = EXCLUDED.variance_amount,
        variance_percentage = EXCLUDED.variance_percentage,
        source_system = EXCLUDED.source_system,
        updated_at = NOW()
    RETURNING id INTO v_budget_actual_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.budget_actual.recorded',
        'budget_actual',
        v_budget_actual_id,
        jsonb_build_object(
            'budget_actual_id', v_budget_actual_id,
            'budget_item_id', p_budget_item_id,
            'period', p_period,
            'variance_amount', v_variance_amount
        ),
        '1.0'
    );
    
    RETURN v_budget_actual_id;
END;
$$;

COMMENT ON FUNCTION strategy.record_budget_actual IS 'Registra realizado vs previsto';

-- ============================================================================
-- STAFFING PLAN
-- ============================================================================

-- Criar staffing plan
CREATE OR REPLACE FUNCTION strategy.create_staffing_plan(
    p_code TEXT,
    p_name TEXT,
    p_scenario_type TEXT DEFAULT 'base',
    p_period_start DATE,
    p_period_end DATE,
    p_description TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_staffing_plan_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Normaliza código
    p_code := core.normalize_code(p_code);
    
    -- Valida código único
    IF EXISTS (
        SELECT 1 FROM strategy.staffing_plans 
        WHERE tenant_id = v_tenant_id AND code = p_code
    ) THEN
        RAISE EXCEPTION 'Staffing plan com código % já existe', p_code;
    END IF;
    
    -- Insere staffing plan
    INSERT INTO strategy.staffing_plans (
        tenant_id,
        code,
        name,
        description,
        scenario_type,
        period_start,
        period_end,
        status
    ) VALUES (
        v_tenant_id,
        p_code,
        p_name,
        p_description,
        p_scenario_type,
        p_period_start,
        p_period_end,
        'draft'
    ) RETURNING id INTO v_staffing_plan_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.staffing_plan.created',
        'staffing_plan',
        v_staffing_plan_id,
        jsonb_build_object(
            'staffing_plan_id', v_staffing_plan_id,
            'code', p_code,
            'scenario_type', p_scenario_type
        ),
        '1.0'
    );
    
    RETURN v_staffing_plan_id;
END;
$$;

COMMENT ON FUNCTION strategy.create_staffing_plan IS 'Cria staffing plan com validação e evento';

-- Criar staffing demand
CREATE OR REPLACE FUNCTION strategy.create_staffing_demand(
    p_staffing_plan_id UUID,
    p_org_unit_id UUID,
    p_headcount NUMERIC,
    p_period_start DATE,
    p_period_end DATE,
    p_job_id UUID DEFAULT NULL,
    p_job_level_id UUID DEFAULT NULL,
    p_cost_center_id UUID DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_staffing_demand_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Valida staffing plan existe
    IF NOT EXISTS (
        SELECT 1 FROM strategy.staffing_plans 
        WHERE id = p_staffing_plan_id AND tenant_id = v_tenant_id
    ) THEN
        RAISE EXCEPTION 'Staffing plan não encontrado ou não pertence ao tenant';
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
    
    -- Valida cost_center se fornecido
    IF p_cost_center_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM core.cost_centers 
            WHERE id = p_cost_center_id AND tenant_id = v_tenant_id
        ) THEN
            RAISE EXCEPTION 'Cost center não encontrado ou não pertence ao tenant';
        END IF;
    END IF;
    
    -- Insere staffing demand
    INSERT INTO strategy.staffing_demands (
        tenant_id,
        staffing_plan_id,
        org_unit_id,
        job_id,
        job_level_id,
        period_start,
        period_end,
        headcount,
        cost_center_id
    ) VALUES (
        v_tenant_id,
        p_staffing_plan_id,
        p_org_unit_id,
        p_job_id,
        p_job_level_id,
        p_period_start,
        p_period_end,
        p_headcount,
        p_cost_center_id
    ) RETURNING id INTO v_staffing_demand_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.staffing_demand.created',
        'staffing_demand',
        v_staffing_demand_id,
        jsonb_build_object(
            'staffing_demand_id', v_staffing_demand_id,
            'staffing_plan_id', p_staffing_plan_id,
            'headcount', p_headcount
        ),
        '1.0'
    );
    
    RETURN v_staffing_demand_id;
END;
$$;

COMMENT ON FUNCTION strategy.create_staffing_demand IS 'Cria staffing demand com validação e evento';

-- Calcular custos de staffing (BLOQUEADO - fail-fast)
CREATE OR REPLACE FUNCTION strategy.calculate_staffing_costs(
    p_staffing_demand_id UUID
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_calculated_cost_id UUID;
    v_error_message TEXT;
BEGIN
    -- BLOQUEIO FAIL-FAST: Verifica se funções economics existem
    -- Verifica core.convert_currency()
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.routines 
        WHERE routine_schema = 'core' 
        AND routine_name = 'convert_currency'
    ) THEN
        RAISE EXCEPTION 'Economics functions not available in Core. Strategy requires core.convert_currency() and core.get_cost_parameter_for_context() to calculate staffing costs. See docs/decisions/2026-01-26_strategy_v1_economics_functions_missing.md';
    END IF;
    
    -- Verifica core.get_cost_parameter_for_context()
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.routines 
        WHERE routine_schema = 'core' 
        AND routine_name = 'get_cost_parameter_for_context'
    ) THEN
        RAISE EXCEPTION 'Economics functions not available in Core. Strategy requires core.convert_currency() and core.get_cost_parameter_for_context() to calculate staffing costs. See docs/decisions/2026-01-26_strategy_v1_economics_functions_missing.md';
    END IF;
    
    -- Se chegou aqui, as funções existem - implementar lógica
    -- TODO: Implementar quando economics existir
    -- v_tenant_id := foundation.get_current_tenant_id();
    -- ... lógica de cálculo ...
    
    RAISE EXCEPTION 'Function not yet implemented. Economics functions exist but calculation logic pending.';
END;
$$;

COMMENT ON FUNCTION strategy.calculate_staffing_costs IS 'Calcula custos de staffing usando economics do Core (BLOQUEADO até economics existir)';

-- Submeter staffing para aprovação
CREATE OR REPLACE FUNCTION strategy.submit_staffing_for_approval(
    p_staffing_plan_id UUID,
    p_workflow_id UUID
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_approval_request_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Valida staffing plan existe
    IF NOT EXISTS (
        SELECT 1 FROM strategy.staffing_plans 
        WHERE id = p_staffing_plan_id AND tenant_id = v_tenant_id
    ) THEN
        RAISE EXCEPTION 'Staffing plan não encontrado ou não pertence ao tenant';
    END IF;
    
    -- Cria approval request
    v_approval_request_id := strategy.create_approval_request(
        p_workflow_id,
        'staffing_plan',
        p_staffing_plan_id
    );
    
    -- Atualiza status
    UPDATE strategy.staffing_plans SET
        status = 'pending_approval',
        updated_at = NOW()
    WHERE id = p_staffing_plan_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.staffing_plan.submitted',
        'staffing_plan',
        p_staffing_plan_id,
        jsonb_build_object(
            'staffing_plan_id', p_staffing_plan_id,
            'approval_request_id', v_approval_request_id
        ),
        '1.0'
    );
    
    RETURN v_approval_request_id;
END;
$$;

COMMENT ON FUNCTION strategy.submit_staffing_for_approval IS 'Submete staffing plan para aprovação via workflow';

-- Registrar staffing actual
CREATE OR REPLACE FUNCTION strategy.record_staffing_actual(
    p_staffing_demand_id UUID,
    p_period DATE,
    p_actual_headcount NUMERIC DEFAULT NULL,
    p_actual_cost_base_currency NUMERIC DEFAULT NULL,
    p_source_system TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_staffing_actual_id UUID;
    v_planned_headcount NUMERIC;
    v_variance_headcount NUMERIC;
    v_variance_cost NUMERIC;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Busca valores planejados
    SELECT headcount INTO v_planned_headcount
    FROM strategy.staffing_demands
    WHERE id = p_staffing_demand_id AND tenant_id = v_tenant_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Staffing demand não encontrado ou não pertence ao tenant';
    END IF;
    
    -- Calcula variâncias
    IF p_actual_headcount IS NOT NULL THEN
        v_variance_headcount := p_actual_headcount - v_planned_headcount;
    END IF;
    
    -- Insere ou atualiza actual
    INSERT INTO strategy.staffing_actuals (
        tenant_id,
        staffing_demand_id,
        period,
        actual_headcount,
        actual_cost_base_currency,
        variance_headcount,
        variance_cost,
        source_system
    ) VALUES (
        v_tenant_id,
        p_staffing_demand_id,
        p_period,
        p_actual_headcount,
        p_actual_cost_base_currency,
        v_variance_headcount,
        v_variance_cost,
        p_source_system
    )
    ON CONFLICT (staffing_demand_id, period) DO UPDATE SET
        actual_headcount = EXCLUDED.actual_headcount,
        actual_cost_base_currency = EXCLUDED.actual_cost_base_currency,
        variance_headcount = EXCLUDED.variance_headcount,
        variance_cost = EXCLUDED.variance_cost,
        source_system = EXCLUDED.source_system,
        updated_at = NOW()
    RETURNING id INTO v_staffing_actual_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.staffing_actual.recorded',
        'staffing_actual',
        v_staffing_actual_id,
        jsonb_build_object(
            'staffing_actual_id', v_staffing_actual_id,
            'staffing_demand_id', p_staffing_demand_id,
            'period', p_period
        ),
        '1.0'
    );
    
    RETURN v_staffing_actual_id;
END;
$$;

COMMENT ON FUNCTION strategy.record_staffing_actual IS 'Registra realizado vs planejado';

-- ============================================================================
-- SIMULAÇÕES & IA
-- ============================================================================

-- Criar AI suggestion (somente registra, sem chamar provedor)
CREATE OR REPLACE FUNCTION strategy.create_ai_suggestion(
    p_suggestion_type TEXT,
    p_entity_type TEXT,
    p_entity_id UUID,
    p_suggestion_data JSONB,
    p_explanation TEXT,
    p_confidence_score NUMERIC DEFAULT NULL,
    p_model_provider TEXT DEFAULT NULL,
    p_model_name TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_suggestion_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Valida confidence_score
    IF p_confidence_score IS NOT NULL AND (p_confidence_score < 0 OR p_confidence_score > 1) THEN
        RAISE EXCEPTION 'confidence_score deve estar entre 0 e 1';
    END IF;
    
    -- Insere suggestion (status = pending, aguardando aprovação humana)
    INSERT INTO strategy.ai_suggestions (
        tenant_id,
        suggestion_type,
        entity_type,
        entity_id,
        suggestion_data,
        explanation,
        confidence_score,
        model_provider,
        model_name,
        status
    ) VALUES (
        v_tenant_id,
        p_suggestion_type,
        p_entity_type,
        p_entity_id,
        p_suggestion_data,
        p_explanation,
        p_confidence_score,
        p_model_provider,
        p_model_name,
        'pending'
    ) RETURNING id INTO v_suggestion_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.ai_suggestion.generated',
        'ai_suggestion',
        v_suggestion_id,
        jsonb_build_object(
            'suggestion_id', v_suggestion_id,
            'suggestion_type', p_suggestion_type,
            'entity_type', p_entity_type,
            'entity_id', p_entity_id
        ),
        '1.0'
    );
    
    RETURN v_suggestion_id;
END;
$$;

COMMENT ON FUNCTION strategy.create_ai_suggestion IS 'Cria AI suggestion (somente registra, sem chamar provedor real)';

-- Aprovar AI suggestion
CREATE OR REPLACE FUNCTION strategy.approve_ai_suggestion(
    p_suggestion_id UUID,
    p_approved_by UUID
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Atualiza status
    UPDATE strategy.ai_suggestions SET
        status = 'approved',
        approved_by = p_approved_by,
        approved_at = NOW()
    WHERE id = p_suggestion_id AND tenant_id = v_tenant_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'AI suggestion não encontrada ou não pertence ao tenant';
    END IF;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.ai_suggestion.approved',
        'ai_suggestion',
        p_suggestion_id,
        jsonb_build_object(
            'suggestion_id', p_suggestion_id,
            'approved_by', p_approved_by
        ),
        '1.0'
    );
    
    RETURN p_suggestion_id;
END;
$$;

COMMENT ON FUNCTION strategy.approve_ai_suggestion IS 'Aprova AI suggestion (humano confirma)';

-- Rejeitar AI suggestion
CREATE OR REPLACE FUNCTION strategy.reject_ai_suggestion(
    p_suggestion_id UUID
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Atualiza status
    UPDATE strategy.ai_suggestions SET
        status = 'rejected'
    WHERE id = p_suggestion_id AND tenant_id = v_tenant_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'AI suggestion não encontrada ou não pertence ao tenant';
    END IF;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.ai_suggestion.rejected',
        'ai_suggestion',
        p_suggestion_id,
        jsonb_build_object(
            'suggestion_id', p_suggestion_id
        ),
        '1.0'
    );
    
    RETURN p_suggestion_id;
END;
$$;

COMMENT ON FUNCTION strategy.reject_ai_suggestion IS 'Rejeita AI suggestion';

-- Criar risk alert
CREATE OR REPLACE FUNCTION strategy.create_risk_alert(
    p_alert_type TEXT,
    p_severity TEXT,
    p_title TEXT,
    p_description TEXT DEFAULT NULL,
    p_entity_type TEXT DEFAULT NULL,
    p_entity_id UUID DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_alert_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Insere risk alert
    INSERT INTO strategy.risk_alerts (
        tenant_id,
        alert_type,
        severity,
        title,
        description,
        entity_type,
        entity_id
    ) VALUES (
        v_tenant_id,
        p_alert_type,
        p_severity,
        p_title,
        p_description,
        p_entity_type,
        p_entity_id
    ) RETURNING id INTO v_alert_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.risk_alert.created',
        'risk_alert',
        v_alert_id,
        jsonb_build_object(
            'alert_id', v_alert_id,
            'alert_type', p_alert_type,
            'severity', p_severity
        ),
        '1.0'
    );
    
    RETURN v_alert_id;
END;
$$;

COMMENT ON FUNCTION strategy.create_risk_alert IS 'Cria risk alert';

-- Resolver risk alert
CREATE OR REPLACE FUNCTION strategy.resolve_risk_alert(
    p_alert_id UUID,
    p_resolved_by UUID
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Atualiza status
    UPDATE strategy.risk_alerts SET
        resolved_at = NOW(),
        resolved_by = p_resolved_by
    WHERE id = p_alert_id AND tenant_id = v_tenant_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Risk alert não encontrado ou não pertence ao tenant';
    END IF;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.risk_alert.resolved',
        'risk_alert',
        p_alert_id,
        jsonb_build_object(
            'alert_id', p_alert_id,
            'resolved_by', p_resolved_by
        ),
        '1.0'
    );
    
    RETURN p_alert_id;
END;
$$;

COMMENT ON FUNCTION strategy.resolve_risk_alert IS 'Resolve risk alert';

-- ============================================================================
-- WORKFLOWS DE APROVAÇÃO
-- ============================================================================

-- Criar approval request
CREATE OR REPLACE FUNCTION strategy.create_approval_request(
    p_workflow_id UUID,
    p_entity_type TEXT,
    p_entity_id UUID
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_approval_request_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Valida workflow existe
    IF NOT EXISTS (
        SELECT 1 FROM strategy.approval_workflows 
        WHERE id = p_workflow_id AND tenant_id = v_tenant_id AND is_active = TRUE
    ) THEN
        RAISE EXCEPTION 'Approval workflow não encontrado, não pertence ao tenant ou está inativo';
    END IF;
    
    -- Insere approval request
    INSERT INTO strategy.approval_requests (
        tenant_id,
        workflow_id,
        entity_type,
        entity_id,
        status,
        current_level
    ) VALUES (
        v_tenant_id,
        p_workflow_id,
        p_entity_type,
        p_entity_id,
        'pending',
        1
    ) RETURNING id INTO v_approval_request_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.approval_request.created',
        'approval_request',
        v_approval_request_id,
        jsonb_build_object(
            'approval_request_id', v_approval_request_id,
            'workflow_id', p_workflow_id,
            'entity_type', p_entity_type,
            'entity_id', p_entity_id
        ),
        '1.0'
    );
    
    RETURN v_approval_request_id;
END;
$$;

COMMENT ON FUNCTION strategy.create_approval_request IS 'Cria approval request (workflow)';

-- Aprovar request
CREATE OR REPLACE FUNCTION strategy.approve_request(
    p_approval_request_id UUID,
    p_approver_person_id UUID,
    p_comments TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_history_id UUID;
    v_current_level INTEGER;
    v_max_level INTEGER;
    v_workflow_id UUID;
    v_approval_levels JSONB;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Busca approval request
    SELECT ar.current_level, ar.workflow_id, aw.approval_levels
    INTO v_current_level, v_workflow_id, v_approval_levels
    FROM strategy.approval_requests ar
    INNER JOIN strategy.approval_workflows aw ON ar.workflow_id = aw.id
    WHERE ar.id = p_approval_request_id AND ar.tenant_id = v_tenant_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Approval request não encontrado ou não pertence ao tenant';
    END IF;
    
    -- Calcula max_level
    v_max_level := jsonb_array_length(v_approval_levels);
    
    -- Registra histórico
    INSERT INTO strategy.approval_history (
        tenant_id,
        approval_request_id,
        approver_person_id,
        approval_level,
        action,
        comments
    ) VALUES (
        v_tenant_id,
        p_approval_request_id,
        p_approver_person_id,
        v_current_level,
        'approved',
        p_comments
    ) RETURNING id INTO v_history_id;
    
    -- Avança nível ou finaliza
    IF v_current_level >= v_max_level THEN
        -- Último nível aprovado
        UPDATE strategy.approval_requests SET
            status = 'approved',
            approved_at = NOW(),
            updated_at = NOW()
        WHERE id = p_approval_request_id;
    ELSE
        -- Avança para próximo nível
        UPDATE strategy.approval_requests SET
            current_level = v_current_level + 1,
            updated_at = NOW()
        WHERE id = p_approval_request_id;
    END IF;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.approval_request.approved',
        'approval_request',
        p_approval_request_id,
        jsonb_build_object(
            'approval_request_id', p_approval_request_id,
            'approval_level', v_current_level,
            'approver_person_id', p_approver_person_id
        ),
        '1.0'
    );
    
    RETURN v_history_id;
END;
$$;

COMMENT ON FUNCTION strategy.approve_request IS 'Aprova request (por nível)';

-- Rejeitar request
CREATE OR REPLACE FUNCTION strategy.reject_request(
    p_approval_request_id UUID,
    p_approver_person_id UUID,
    p_comments TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_history_id UUID;
    v_current_level INTEGER;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Busca current_level
    SELECT current_level INTO v_current_level
    FROM strategy.approval_requests
    WHERE id = p_approval_request_id AND tenant_id = v_tenant_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Approval request não encontrado ou não pertence ao tenant';
    END IF;
    
    -- Registra histórico
    INSERT INTO strategy.approval_history (
        tenant_id,
        approval_request_id,
        approver_person_id,
        approval_level,
        action,
        comments
    ) VALUES (
        v_tenant_id,
        p_approval_request_id,
        p_approver_person_id,
        v_current_level,
        'rejected',
        p_comments
    ) RETURNING id INTO v_history_id;
    
    -- Atualiza status
    UPDATE strategy.approval_requests SET
        status = 'rejected',
        rejected_at = NOW(),
        updated_at = NOW()
    WHERE id = p_approval_request_id;
    
    -- Publica evento
    PERFORM foundation.publish_event(
        'strategy.approval_request.rejected',
        'approval_request',
        p_approval_request_id,
        jsonb_build_object(
            'approval_request_id', p_approval_request_id,
            'approval_level', v_current_level,
            'approver_person_id', p_approver_person_id
        ),
        '1.0'
    );
    
    RETURN v_history_id;
END;
$$;

COMMENT ON FUNCTION strategy.reject_request IS 'Rejeita request';

-- ============================================================================
-- IMPORT/EXPORT
-- ============================================================================

-- Criar export job (estrutura)
CREATE OR REPLACE FUNCTION strategy.create_export_job(
    p_export_type TEXT,
    p_format TEXT,
    p_filters JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_export_job_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Insere export job
    INSERT INTO strategy.export_jobs (
        tenant_id,
        export_type,
        format,
        filters,
        status
    ) VALUES (
        v_tenant_id,
        p_export_type,
        p_format,
        p_filters,
        'pending'
    ) RETURNING id INTO v_export_job_id;
    
    RETURN v_export_job_id;
END;
$$;

COMMENT ON FUNCTION strategy.create_export_job IS 'Cria export job (estrutura)';

-- ============================================================================
-- HELPERS DE CONSULTA (read-only)
-- ============================================================================

-- Obter dados do dashboard executivo (placeholder)
CREATE OR REPLACE FUNCTION strategy.get_executive_dashboard_data(
    p_dashboard_code TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
DECLARE
    v_tenant_id UUID;
    v_result JSONB;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'tenant_id não encontrado no contexto';
    END IF;
    
    -- Placeholder: retorna estrutura básica
    -- TODO: Implementar lógica real quando necessário
    v_result := jsonb_build_object(
        'dashboard_code', COALESCE(p_dashboard_code, 'default'),
        'kpis', '[]'::jsonb,
        'alerts', '[]'::jsonb,
        'data', '{}'::jsonb
    );
    
    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION strategy.get_executive_dashboard_data IS 'Retorna dados do dashboard executivo (placeholder read-only)';
