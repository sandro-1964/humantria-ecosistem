-- HUMANTRÍA — BRIDGES — GS-PATCH V1 — UI Ops (Troubleshooting)
-- Arquivo: 002_patch_functions.sql
-- Status: PATCH (bridge-first; sem engine novo; sem relaxar RLS)
--
-- Objetivo:
-- - Expor RPCs mínimas para UI inspecionar `foundation.events_outbox` (sem payload/JSON cru).
-- - Registrar pedido auditável de replay (sem executar replay) e publicar evento `bridges.replay.requested`.
--
-- Regras:
-- - Todas as funções são SECURITY INVOKER
-- - Multi-tenant: valida p_tenant_id contra contexto (exceto Platform Owner)
-- - Sem JSON cru no retorno (apenas colunas primitivas)

SET search_path TO bridges, foundation, public;

-- ============================================================================
-- HELPERS (internos) — validação & erro governado
-- ============================================================================

-- Obter correlation_id se disponível via headers (best-effort), senão gera UUID
CREATE OR REPLACE FUNCTION bridges._gs_patch_v1_ui_ops_get_correlation_id()
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
DECLARE
    v_headers JSONB;
    v_corr_text TEXT;
    v_corr UUID;
BEGIN
    BEGIN
        v_headers := current_setting('request.headers', true)::jsonb;
    EXCEPTION
        WHEN OTHERS THEN
            v_headers := NULL;
    END;

    v_corr_text := NULL;
    IF v_headers IS NOT NULL THEN
        -- padrões comuns (nem sempre UUID)
        v_corr_text := COALESCE(
            v_headers->>'x-correlation-id',
            v_headers->>'x-request-id',
            v_headers->>'x-amzn-trace-id'
        );
    END IF;

    IF v_corr_text IS NOT NULL THEN
        BEGIN
            v_corr := v_corr_text::uuid;
            RETURN v_corr;
        EXCEPTION
            WHEN OTHERS THEN
                -- ignora se não for UUID
                NULL;
        END;
    END IF;

    RETURN gen_random_uuid();
END;
$$;

COMMENT ON FUNCTION bridges._gs_patch_v1_ui_ops_get_correlation_id IS 'GS-PATCH V1 UI Ops: best-effort correlation_id (headers) ou UUID gerado';

-- Validar tenant_id governado para funções deste patch
CREATE OR REPLACE FUNCTION bridges._gs_patch_v1_ui_ops_assert_tenant(p_tenant_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
DECLARE
    v_ctx_tenant_id UUID;
    v_corr UUID;
BEGIN
    v_corr := bridges._gs_patch_v1_ui_ops_get_correlation_id();

    IF p_tenant_id IS NULL THEN
        RAISE EXCEPTION USING
            MESSAGE = 'tenant_id ausente',
            DETAIL  = jsonb_build_object('code','TENANT_ID_MISSING','correlation_id',v_corr)::text;
    END IF;

    v_ctx_tenant_id := foundation.get_current_tenant_id();

    -- Platform Owner pode consultar tenant arbitrário (ainda filtramos por p_tenant_id)
    IF foundation.is_platform_owner() THEN
        RETURN p_tenant_id;
    END IF;

    IF v_ctx_tenant_id IS NULL THEN
        RAISE EXCEPTION USING
            MESSAGE = 'tenant_id não encontrado no contexto',
            DETAIL  = jsonb_build_object('code','TENANT_CONTEXT_MISSING','correlation_id',v_corr)::text;
    END IF;

    IF v_ctx_tenant_id <> p_tenant_id THEN
        RAISE EXCEPTION USING
            MESSAGE = 'tenant_id inválido',
            DETAIL  = jsonb_build_object(
                'code','TENANT_MISMATCH',
                'correlation_id',v_corr
            )::text;
    END IF;

    RETURN p_tenant_id;
END;
$$;

COMMENT ON FUNCTION bridges._gs_patch_v1_ui_ops_assert_tenant IS 'GS-PATCH V1 UI Ops: valida tenant_id (contexto) e retorna tenant validado';

-- ============================================================================
-- A) Outbox — RPCs mínimas (sem payload)
-- ============================================================================

-- Listar eventos do outbox por tenant (opcional: filtrar por status)
CREATE OR REPLACE FUNCTION bridges.list_outbox_events(
    p_tenant_id UUID,
    p_limit INT DEFAULT 50,
    p_status TEXT DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    tenant_id UUID,
    correlation_id UUID,
    causation_id UUID,
    event_type TEXT,
    entity_type TEXT,
    entity_id UUID,
    payload_version TEXT,
    status TEXT,
    retry_count INTEGER,
    error_message TEXT,
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
BEGIN
    PERFORM bridges._gs_patch_v1_ui_ops_assert_tenant(p_tenant_id);

    RETURN QUERY
    SELECT
        e.id,
        e.tenant_id,
        e.correlation_id,
        e.causation_id,
        e.event_type,
        e.entity_type,
        e.entity_id,
        e.payload_version,
        e.status,
        e.retry_count,
        e.error_message,
        e.processed_at,
        e.created_at
    FROM foundation.events_outbox e
    WHERE e.tenant_id = p_tenant_id
      AND (p_status IS NULL OR e.status = p_status)
    ORDER BY e.created_at DESC
    LIMIT GREATEST(1, LEAST(COALESCE(p_limit, 50), 200));
END;
$$;

COMMENT ON FUNCTION bridges.list_outbox_events IS 'Lista eventos do outbox por tenant (sem payload) — GS-PATCH V1 UI Ops';

-- Obter 1 evento do outbox por id (tenant-safe; sem payload)
CREATE OR REPLACE FUNCTION bridges.get_outbox_event(
    p_tenant_id UUID,
    p_event_id UUID
)
RETURNS TABLE (
    id UUID,
    tenant_id UUID,
    correlation_id UUID,
    causation_id UUID,
    event_type TEXT,
    entity_type TEXT,
    entity_id UUID,
    payload_version TEXT,
    status TEXT,
    retry_count INTEGER,
    error_message TEXT,
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
DECLARE
    v_corr UUID;
BEGIN
    PERFORM bridges._gs_patch_v1_ui_ops_assert_tenant(p_tenant_id);
    v_corr := bridges._gs_patch_v1_ui_ops_get_correlation_id();

    RETURN QUERY
    SELECT
        e.id,
        e.tenant_id,
        e.correlation_id,
        e.causation_id,
        e.event_type,
        e.entity_type,
        e.entity_id,
        e.payload_version,
        e.status,
        e.retry_count,
        e.error_message,
        e.processed_at,
        e.created_at
    FROM foundation.events_outbox e
    WHERE e.tenant_id = p_tenant_id
      AND e.id = p_event_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING
            MESSAGE = 'evento não encontrado',
            DETAIL  = jsonb_build_object('code','NOT_FOUND','correlation_id',v_corr)::text;
    END IF;
END;
$$;

COMMENT ON FUNCTION bridges.get_outbox_event IS 'Retorna evento do outbox por id (sem payload) — GS-PATCH V1 UI Ops';

-- Listar apenas eventos com status = failed (atalho)
CREATE OR REPLACE FUNCTION bridges.list_failed_events(
    p_tenant_id UUID,
    p_limit INT DEFAULT 50
)
RETURNS TABLE (
    id UUID,
    tenant_id UUID,
    correlation_id UUID,
    causation_id UUID,
    event_type TEXT,
    entity_type TEXT,
    entity_id UUID,
    payload_version TEXT,
    status TEXT,
    retry_count INTEGER,
    error_message TEXT,
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM bridges.list_outbox_events(p_tenant_id, p_limit, 'failed');
END;
$$;

COMMENT ON FUNCTION bridges.list_failed_events IS 'Lista eventos do outbox com status failed (sem payload) — GS-PATCH V1 UI Ops';

-- ============================================================================
-- B) Replay request (governado) — sem executar replay
-- ============================================================================

CREATE OR REPLACE FUNCTION bridges.request_event_replay(
    p_tenant_id UUID,
    p_event_id UUID,
    p_reason TEXT
)
RETURNS TABLE (
    correlation_id UUID,
    requested_event_id UUID,
    outbox_event_id UUID,
    audit_log_functional_id UUID
)
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_corr UUID;
    v_ctx_tenant UUID;
    v_exists UUID;
    v_outbox_event_id UUID;
    v_audit_id UUID;
    v_role TEXT;
BEGIN
    PERFORM bridges._gs_patch_v1_ui_ops_assert_tenant(p_tenant_id);
    v_corr := bridges._gs_patch_v1_ui_ops_get_correlation_id();

    -- Guardrail: UI Ops mutação só para Tenant Admin (ou Platform Owner)
    BEGIN
        v_role := current_setting('request.jwt.claims', true)::json->>'role';
    EXCEPTION
        WHEN OTHERS THEN
            v_role := NULL;
    END;

    IF NOT foundation.is_platform_owner() AND v_role IS DISTINCT FROM 'tenant_admin' THEN
        RAISE EXCEPTION USING
            MESSAGE = 'ação não permitida',
            DETAIL  = jsonb_build_object('code','FORBIDDEN','correlation_id',v_corr)::text;
    END IF;

    -- Garantir que o evento alvo existe e pertence ao tenant
    SELECT e.id
      INTO v_exists
    FROM foundation.events_outbox e
    WHERE e.tenant_id = p_tenant_id
      AND e.id = p_event_id;

    IF v_exists IS NULL THEN
        RAISE EXCEPTION USING
            MESSAGE = 'evento não encontrado',
            DETAIL  = jsonb_build_object('code','NOT_FOUND','correlation_id',v_corr)::text;
    END IF;

    -- Garantir tenant no contexto para registrar audit/publicar evento (especialmente no caso Platform Owner)
    v_ctx_tenant := foundation.get_current_tenant_id();
    IF v_ctx_tenant IS NULL OR v_ctx_tenant <> p_tenant_id THEN
        PERFORM set_config('app.current_tenant_id', p_tenant_id::text, true);
    END IF;

    -- Audit funcional (decisão/evidência)
    v_audit_id := foundation.audit_log_functional_insert(
        'bridges.replay.requested',
        'events_outbox',
        p_event_id,
        jsonb_build_object(
            'tenant_id', p_tenant_id,
            'event_id', p_event_id,
            'reason', p_reason,
            'correlation_id', v_corr
        ),
        p_reason,
        '[]'::jsonb,
        '[]'::jsonb
    );

    -- Publicar evento no outbox (não executa replay)
    v_outbox_event_id := foundation.publish_event(
        'bridges.replay.requested',
        'events_outbox',
        p_event_id,
        jsonb_build_object(
            'requested_event_id', p_event_id,
            'tenant_id', p_tenant_id,
            'reason', p_reason,
            'audit_log_functional_id', v_audit_id,
            'correlation_id', v_corr
        ),
        '1.0',
        v_corr,
        NULL
    );

    RETURN QUERY
    SELECT
        v_corr AS correlation_id,
        p_event_id AS requested_event_id,
        v_outbox_event_id AS outbox_event_id,
        v_audit_id AS audit_log_functional_id;
END;
$$;

COMMENT ON FUNCTION bridges.request_event_replay IS 'Registra pedido auditável de replay e publica bridges.replay.requested (sem executar replay) — GS-PATCH V1 UI Ops';

