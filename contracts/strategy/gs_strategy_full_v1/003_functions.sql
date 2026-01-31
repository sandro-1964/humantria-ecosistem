-- HUMANTRÍA — STRATEGY GS FULL V1 — Functions (RPCs CRUD + approve)
-- SECURITY INVOKER, tenant-safe, audit + events

SET search_path TO strategy, foundation, core, public;

-- ============================================================================
-- HELPERS
-- ============================================================================

CREATE OR REPLACE FUNCTION strategy._gs_full_v1_cycle_id(
    p_tenant_id UUID,
    p_cycle_type TEXT,
    p_cycle_start_date DATE,
    p_cycle_end_date DATE
)
RETURNS UUID
LANGUAGE sql SECURITY INVOKER STABLE AS $$
    WITH h AS (SELECT md5(p_tenant_id::text || ':' || COALESCE(p_cycle_type,'') || ':' || COALESCE(p_cycle_start_date::text,'') || ':' || COALESCE(p_cycle_end_date::text,'')) AS m)
    SELECT (substr(m,1,8)||'-'||substr(m,9,4)||'-'||substr(m,13,4)||'-'||substr(m,17,4)||'-'||substr(m,21,12))::uuid FROM h;
$$;

CREATE OR REPLACE FUNCTION strategy._gs_full_v1_assert_tenant(p_tenant_id UUID)
RETURNS UUID LANGUAGE plpgsql SECURITY INVOKER STABLE AS $$
DECLARE v_ctx UUID; v_role TEXT;
BEGIN
    IF p_tenant_id IS NULL THEN RAISE EXCEPTION 'tenant_id ausente'; END IF;
    v_role := current_setting('request.jwt.claims', true)::json->>'role';
    IF v_role = 'service_role' THEN RETURN p_tenant_id; END IF;
    v_ctx := foundation.get_current_tenant_id();
    IF foundation.is_platform_owner() THEN RETURN p_tenant_id; END IF;
    IF v_ctx IS NULL THEN RAISE EXCEPTION 'tenant_id não encontrado no contexto'; END IF;
    IF v_ctx <> p_tenant_id THEN RAISE EXCEPTION 'tenant_id inválido'; END IF;
    RETURN p_tenant_id;
END;
$$;

-- ============================================================================
-- CREATE_OBJECTIVE
-- ============================================================================

CREATE OR REPLACE FUNCTION strategy.create_objective(
    p_tenant_id UUID,
    p_cycle_type TEXT,
    p_cycle_start_date DATE,
    p_cycle_end_date DATE,
    p_code TEXT,
    p_title TEXT,
    p_description TEXT DEFAULT NULL,
    p_owner_person_id UUID DEFAULT NULL,
    p_methodology_type TEXT DEFAULT 'okr'
)
RETURNS UUID
LANGUAGE plpgsql SECURITY INVOKER AS $$
DECLARE v_id UUID; v_payload JSONB;
BEGIN
    PERFORM strategy._gs_full_v1_assert_tenant(p_tenant_id);

    INSERT INTO strategy.objectives (tenant_id, cycle_type, cycle_start_date, cycle_end_date, code, title, description, methodology_type, status, owner_person_id)
    VALUES (p_tenant_id, p_cycle_type, p_cycle_start_date, p_cycle_end_date, p_code, p_title, p_description, COALESCE(p_methodology_type,'okr'), 'draft', p_owner_person_id)
    RETURNING id INTO v_id;

    PERFORM foundation.audit_log_functional_insert('objective_created', 'strategy.objective', v_id, '{}'::jsonb, NULL, jsonb_build_array(jsonb_build_object('type','objective','id',v_id)));
    v_payload := jsonb_build_object('status','draft','cycle_type',p_cycle_type,'code',p_code);
    PERFORM foundation.publish_event('objective.created', 'strategy.objective', v_id, v_payload, '1.0', NULL, NULL);

    RETURN v_id;
END;
$$;

-- ============================================================================
-- UPDATE_OBJECTIVE
-- ============================================================================

CREATE OR REPLACE FUNCTION strategy.update_objective(
    p_tenant_id UUID,
    p_objective_id UUID,
    p_code TEXT DEFAULT NULL,
    p_title TEXT DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_status TEXT DEFAULT NULL,
    p_owner_person_id UUID DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql SECURITY INVOKER AS $$
DECLARE v_row RECORD; v_payload JSONB;
BEGIN
    PERFORM strategy._gs_full_v1_assert_tenant(p_tenant_id);

    UPDATE strategy.objectives SET
        code = COALESCE(p_code, code),
        title = COALESCE(p_title, title),
        description = COALESCE(p_description, description),
        status = COALESCE(p_status, status),
        owner_person_id = COALESCE(p_owner_person_id, owner_person_id),
        updated_at = NOW()
    WHERE id = p_objective_id AND tenant_id = p_tenant_id;

    IF NOT FOUND THEN RAISE EXCEPTION 'objective não encontrado'; END IF;

    SELECT status INTO v_row FROM strategy.objectives WHERE id = p_objective_id;
    PERFORM foundation.audit_log_functional_insert('objective_updated', 'strategy.objective', p_objective_id, jsonb_build_object('status', v_row.status), NULL, '[]'::jsonb);
    v_payload := jsonb_build_object('status', v_row.status);
    PERFORM foundation.publish_event('objective.updated', 'strategy.objective', p_objective_id, v_payload, '1.0', NULL, NULL);
END;
$$;

-- ============================================================================
-- DELETE_OBJECTIVE
-- ============================================================================

CREATE OR REPLACE FUNCTION strategy.delete_objective(p_tenant_id UUID, p_objective_id UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY INVOKER AS $$
BEGIN
    PERFORM strategy._gs_full_v1_assert_tenant(p_tenant_id);
    DELETE FROM strategy.objectives WHERE id = p_objective_id AND tenant_id = p_tenant_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'objective não encontrado'; END IF;
    PERFORM foundation.audit_log_functional_insert('objective_deleted', 'strategy.objective', p_objective_id, '{}'::jsonb, NULL, '[]'::jsonb);
END;
$$;

-- ============================================================================
-- APPROVE_OBJECTIVE (fluxo decisão com evidência)
-- ============================================================================

CREATE OR REPLACE FUNCTION strategy.approve_objective(
    p_tenant_id UUID,
    p_objective_id UUID,
    p_justification TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql SECURITY INVOKER AS $$
DECLARE v_status TEXT; v_payload JSONB;
BEGIN
    PERFORM strategy._gs_full_v1_assert_tenant(p_tenant_id);

    SELECT status INTO v_status FROM strategy.objectives WHERE id = p_objective_id AND tenant_id = p_tenant_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'objective não encontrado'; END IF;
    IF v_status <> 'draft' THEN RAISE EXCEPTION 'objective deve estar em draft para aprovar'; END IF;

    UPDATE strategy.objectives SET status = 'active', updated_at = NOW() WHERE id = p_objective_id AND tenant_id = p_tenant_id;

    PERFORM foundation.audit_log_functional_insert(
        'objective_approved', 'strategy.objective', p_objective_id,
        jsonb_build_object('previous_status','draft','new_status','active'),
        p_justification,
        jsonb_build_array(jsonb_build_object('type','objective','id',p_objective_id))
    );

    v_payload := jsonb_build_object('status','active','previous_status','draft');
    PERFORM foundation.publish_event('objective.approved', 'strategy.objective', p_objective_id, v_payload, '1.0', NULL, NULL);
END;
$$;

-- ============================================================================
-- CREATE_INITIATIVE
-- ============================================================================

CREATE OR REPLACE FUNCTION strategy.create_initiative(
    p_tenant_id UUID,
    p_objective_id UUID,
    p_code TEXT,
    p_title TEXT,
    p_description TEXT DEFAULT NULL,
    p_owner_person_id UUID DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql SECURITY INVOKER AS $$
DECLARE v_id UUID; v_payload JSONB;
BEGIN
    PERFORM strategy._gs_full_v1_assert_tenant(p_tenant_id);
    IF NOT EXISTS (SELECT 1 FROM strategy.objectives WHERE id = p_objective_id AND tenant_id = p_tenant_id) THEN
        RAISE EXCEPTION 'objective não encontrado';
    END IF;

    INSERT INTO strategy.initiatives (tenant_id, objective_id, code, title, description, status, owner_person_id)
    VALUES (p_tenant_id, p_objective_id, p_code, p_title, p_description, 'draft', p_owner_person_id)
    RETURNING id INTO v_id;

    PERFORM foundation.audit_log_functional_insert('initiative_created', 'strategy.initiative', v_id, jsonb_build_object('objective_id',p_objective_id), NULL, '[]'::jsonb);
    v_payload := jsonb_build_object('status','draft','objective_id',p_objective_id);
    PERFORM foundation.publish_event('initiative.created', 'strategy.initiative', v_id, v_payload, '1.0', NULL, NULL);

    RETURN v_id;
END;
$$;

-- ============================================================================
-- UPDATE_INITIATIVE
-- ============================================================================

CREATE OR REPLACE FUNCTION strategy.update_initiative(
    p_tenant_id UUID,
    p_initiative_id UUID,
    p_code TEXT DEFAULT NULL,
    p_title TEXT DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_status TEXT DEFAULT NULL,
    p_owner_person_id UUID DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql SECURITY INVOKER AS $$
DECLARE v_row RECORD;
BEGIN
    PERFORM strategy._gs_full_v1_assert_tenant(p_tenant_id);

    UPDATE strategy.initiatives SET
        code = COALESCE(p_code, code),
        title = COALESCE(p_title, title),
        description = COALESCE(p_description, description),
        status = COALESCE(p_status, status),
        owner_person_id = COALESCE(p_owner_person_id, owner_person_id),
        updated_at = NOW()
    WHERE id = p_initiative_id AND tenant_id = p_tenant_id;

    IF NOT FOUND THEN RAISE EXCEPTION 'initiative não encontrada'; END IF;

    SELECT status INTO v_row FROM strategy.initiatives WHERE id = p_initiative_id;
    PERFORM foundation.audit_log_functional_insert('initiative_updated', 'strategy.initiative', p_initiative_id, jsonb_build_object('status', v_row.status), NULL, '[]'::jsonb);
    PERFORM foundation.publish_event('initiative.updated', 'strategy.initiative', p_initiative_id, jsonb_build_object('status', v_row.status), '1.0', NULL, NULL);
END;
$$;

-- ============================================================================
-- DELETE_INITIATIVE
-- ============================================================================

CREATE OR REPLACE FUNCTION strategy.delete_initiative(p_tenant_id UUID, p_initiative_id UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY INVOKER AS $$
BEGIN
    PERFORM strategy._gs_full_v1_assert_tenant(p_tenant_id);
    DELETE FROM strategy.initiatives WHERE id = p_initiative_id AND tenant_id = p_tenant_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'initiative não encontrada'; END IF;
    PERFORM foundation.audit_log_functional_insert('initiative_deleted', 'strategy.initiative', p_initiative_id, '{}'::jsonb, NULL, '[]'::jsonb);
END;
$$;

-- ============================================================================
-- LIST_OBJECTIVES
-- ============================================================================

CREATE OR REPLACE FUNCTION strategy.list_objectives(
    p_tenant_id UUID,
    p_cycle_id UUID DEFAULT NULL,
    p_limit INT DEFAULT 50
)
RETURNS TABLE (
    id UUID,
    tenant_id UUID,
    cycle_id UUID,
    code TEXT,
    title TEXT,
    description TEXT,
    status TEXT,
    owner_person_id UUID,
    cycle_type TEXT,
    cycle_start_date DATE,
    cycle_end_date DATE,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql SECURITY INVOKER STABLE AS $$
BEGIN
    PERFORM strategy._gs_full_v1_assert_tenant(p_tenant_id);

    RETURN QUERY
    SELECT
        o.id, o.tenant_id,
        strategy._gs_full_v1_cycle_id(o.tenant_id, o.cycle_type, o.cycle_start_date, o.cycle_end_date),
        o.code, o.title, o.description, o.status, o.owner_person_id,
        o.cycle_type, o.cycle_start_date, o.cycle_end_date,
        o.created_at, o.updated_at
    FROM strategy.objectives o
    WHERE o.tenant_id = p_tenant_id
      AND (p_cycle_id IS NULL OR strategy._gs_full_v1_cycle_id(o.tenant_id, o.cycle_type, o.cycle_start_date, o.cycle_end_date) = p_cycle_id)
    ORDER BY o.cycle_start_date DESC NULLS LAST, o.created_at DESC NULLS LAST
    LIMIT GREATEST(1, LEAST(COALESCE(p_limit, 50), 200));
END;
$$;

-- ============================================================================
-- LIST_INITIATIVES (strategy.initiatives)
-- ============================================================================

CREATE OR REPLACE FUNCTION strategy.list_initiatives_full(
    p_tenant_id UUID,
    p_objective_id UUID DEFAULT NULL,
    p_limit INT DEFAULT 50
)
RETURNS TABLE (
    id UUID,
    tenant_id UUID,
    objective_id UUID,
    code TEXT,
    title TEXT,
    description TEXT,
    status TEXT,
    owner_person_id UUID,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql SECURITY INVOKER STABLE AS $$
BEGIN
    PERFORM strategy._gs_full_v1_assert_tenant(p_tenant_id);

    RETURN QUERY
    SELECT i.id, i.tenant_id, i.objective_id, i.code, i.title, i.description, i.status, i.owner_person_id, i.created_at, i.updated_at
    FROM strategy.initiatives i
    WHERE i.tenant_id = p_tenant_id
      AND (p_objective_id IS NULL OR i.objective_id = p_objective_id)
    ORDER BY i.created_at DESC NULLS LAST
    LIMIT GREATEST(1, LEAST(COALESCE(p_limit, 50), 200));
END;
$$;

-- ============================================================================
-- GET_PORTFOLIO_SNAPSHOT (objectives + initiatives)
-- ============================================================================

CREATE OR REPLACE FUNCTION strategy.get_portfolio_snapshot_full(
    p_tenant_id UUID,
    p_cycle_id UUID
)
RETURNS TABLE (
    tenant_id UUID,
    cycle_id UUID,
    objectives_total INT,
    objectives_active INT,
    objectives_completed INT,
    initiatives_total BIGINT,
    initiatives_active BIGINT,
    updated_at_max TIMESTAMPTZ
)
LANGUAGE plpgsql SECURITY INVOKER STABLE AS $$
DECLARE
    v_obj_total INT; v_obj_active INT; v_obj_completed INT;
    v_init_total BIGINT; v_init_active BIGINT; v_updated TIMESTAMPTZ;
BEGIN
    PERFORM strategy._gs_full_v1_assert_tenant(p_tenant_id);

    SELECT count(*)::int, count(*) FILTER (WHERE status='active')::int, count(*) FILTER (WHERE status='completed')::int, max(updated_at)
    INTO v_obj_total, v_obj_active, v_obj_completed, v_updated
    FROM strategy.objectives o
    WHERE o.tenant_id = p_tenant_id AND strategy._gs_full_v1_cycle_id(o.tenant_id, o.cycle_type, o.cycle_start_date, o.cycle_end_date) = p_cycle_id;

    SELECT count(*), count(*) FILTER (WHERE i.status='active')
    INTO v_init_total, v_init_active
    FROM strategy.initiatives i
    JOIN strategy.objectives o ON i.objective_id = o.id
    WHERE o.tenant_id = p_tenant_id AND strategy._gs_full_v1_cycle_id(o.tenant_id, o.cycle_type, o.cycle_start_date, o.cycle_end_date) = p_cycle_id;

    v_updated := greatest(v_updated, (SELECT max(i.updated_at) FROM strategy.initiatives i JOIN strategy.objectives o ON i.objective_id = o.id WHERE o.tenant_id = p_tenant_id AND strategy._gs_full_v1_cycle_id(o.tenant_id, o.cycle_type, o.cycle_start_date, o.cycle_end_date) = p_cycle_id));

    RETURN QUERY SELECT p_tenant_id, p_cycle_id, v_obj_total, v_obj_active, v_obj_completed, v_init_total, v_init_active, v_updated;
END;
$$;
