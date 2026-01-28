-- HUMANTRÍA — STRATEGY — GS-PATCH V1 — UI APIs (READ-ONLY)
-- Arquivo: 002_patch_functions.sql
-- Status: PATCH-ONLY (sem features; sem engine nova)
--
-- Objetivo:
-- - Expor RPCs mínimas read-only para Strategy V1 consumida pela UI.
-- - Regras: SECURITY INVOKER, tenant-safe, sem JSON cru (somente tipos primitivos).
--
-- DB alvo (inspeção): schema `strategy` existe; tabela canônica usada:
-- - strategy.objectives (contém tenant_id + cycle_*; metadata jsonb será OMITIDO)

SET search_path TO strategy, foundation, public;

-- ============================================================================
-- HELPERS (internos) — validação & erro governado
-- ============================================================================

-- Obter correlation_id se disponível via headers (best-effort), senão gera UUID
CREATE OR REPLACE FUNCTION strategy._gs_patch_v1_ui_apis_get_correlation_id()
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

COMMENT ON FUNCTION strategy._gs_patch_v1_ui_apis_get_correlation_id IS 'GS-PATCH V1 Strategy UI APIs: best-effort correlation_id (headers) ou UUID gerado';

-- Validar tenant_id governado para funções deste patch
CREATE OR REPLACE FUNCTION strategy._gs_patch_v1_ui_apis_assert_tenant(p_tenant_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
DECLARE
    v_ctx_tenant_id UUID;
    v_corr UUID;
BEGIN
    v_corr := strategy._gs_patch_v1_ui_apis_get_correlation_id();

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

COMMENT ON FUNCTION strategy._gs_patch_v1_ui_apis_assert_tenant IS 'GS-PATCH V1 Strategy UI APIs: valida tenant_id (contexto) e retorna tenant validado';

-- Determinístico: construir cycle_id a partir de (tenant_id + cycle_*).
-- Motivo: o schema Strategy V1 canônico não expõe uma tabela “cycles”; ciclos existem como atributos em `strategy.objectives`.
CREATE OR REPLACE FUNCTION strategy._gs_patch_v1_ui_apis_cycle_id(
    p_tenant_id UUID,
    p_cycle_type TEXT,
    p_cycle_start_date DATE,
    p_cycle_end_date DATE
)
RETURNS UUID
LANGUAGE sql
SECURITY INVOKER
STABLE
AS $$
    WITH h AS (
        SELECT md5(
            p_tenant_id::text
            || ':' || COALESCE(p_cycle_type, '')
            || ':' || COALESCE(p_cycle_start_date::text, '')
            || ':' || COALESCE(p_cycle_end_date::text, '')
        ) AS m
    )
    SELECT (
        substr(m, 1, 8) || '-' ||
        substr(m, 9, 4) || '-' ||
        substr(m, 13, 4) || '-' ||
        substr(m, 17, 4) || '-' ||
        substr(m, 21, 12)
    )::uuid
    FROM h;
$$;

COMMENT ON FUNCTION strategy._gs_patch_v1_ui_apis_cycle_id IS 'GS-PATCH V1 Strategy UI APIs: cycle_id determinístico (tenant + cycle_*)';

-- ============================================================================
-- RPCs mínimas (read-only; sem JSON cru)
-- ============================================================================

CREATE OR REPLACE FUNCTION strategy.list_cycles(
    p_tenant_id UUID,
    p_limit INT DEFAULT 50
)
RETURNS TABLE (
    cycle_id UUID,
    tenant_id UUID,
    cycle_type TEXT,
    start_date DATE,
    end_date DATE,
    objectives_total INT,
    created_at_min TIMESTAMPTZ,
    updated_at_max TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
BEGIN
    PERFORM strategy._gs_patch_v1_ui_apis_assert_tenant(p_tenant_id);

    RETURN QUERY
    SELECT
        strategy._gs_patch_v1_ui_apis_cycle_id(o.tenant_id, o.cycle_type, o.cycle_start_date, o.cycle_end_date) AS cycle_id,
        o.tenant_id,
        o.cycle_type,
        o.cycle_start_date AS start_date,
        o.cycle_end_date AS end_date,
        count(*)::int AS objectives_total,
        min(o.created_at) AS created_at_min,
        max(o.updated_at) AS updated_at_max
    FROM strategy.objectives o
    WHERE o.tenant_id = p_tenant_id
    GROUP BY
        o.tenant_id,
        o.cycle_type,
        o.cycle_start_date,
        o.cycle_end_date
    ORDER BY
        o.cycle_start_date DESC NULLS LAST,
        o.cycle_end_date DESC NULLS LAST,
        o.cycle_type ASC,
        cycle_id ASC
    LIMIT GREATEST(1, LEAST(COALESCE(p_limit, 50), 200));
END;
$$;

COMMENT ON FUNCTION strategy.list_cycles IS 'Lista ciclos (derivados de objectives.cycle_*) do tenant — GS-PATCH V1 Strategy UI APIs';

CREATE OR REPLACE FUNCTION strategy.get_cycle(
    p_tenant_id UUID,
    p_cycle_id UUID
)
RETURNS TABLE (
    cycle_id UUID,
    tenant_id UUID,
    cycle_type TEXT,
    start_date DATE,
    end_date DATE,
    objectives_total INT,
    created_at_min TIMESTAMPTZ,
    updated_at_max TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
DECLARE
    v_corr UUID;
BEGIN
    PERFORM strategy._gs_patch_v1_ui_apis_assert_tenant(p_tenant_id);
    v_corr := strategy._gs_patch_v1_ui_apis_get_correlation_id();

    RETURN QUERY
    SELECT
        strategy._gs_patch_v1_ui_apis_cycle_id(o.tenant_id, o.cycle_type, o.cycle_start_date, o.cycle_end_date) AS cycle_id,
        o.tenant_id,
        o.cycle_type,
        o.cycle_start_date AS start_date,
        o.cycle_end_date AS end_date,
        count(*)::int AS objectives_total,
        min(o.created_at) AS created_at_min,
        max(o.updated_at) AS updated_at_max
    FROM strategy.objectives o
    WHERE o.tenant_id = p_tenant_id
      AND strategy._gs_patch_v1_ui_apis_cycle_id(o.tenant_id, o.cycle_type, o.cycle_start_date, o.cycle_end_date) = p_cycle_id
    GROUP BY
        o.tenant_id,
        o.cycle_type,
        o.cycle_start_date,
        o.cycle_end_date;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING
            MESSAGE = 'ciclo não encontrado',
            DETAIL  = jsonb_build_object('code','NOT_FOUND','correlation_id',v_corr)::text;
    END IF;
END;
$$;

COMMENT ON FUNCTION strategy.get_cycle IS 'Retorna ciclo (derivado) por cycle_id do tenant — GS-PATCH V1 Strategy UI APIs';

CREATE OR REPLACE FUNCTION strategy.list_initiatives(
    p_tenant_id UUID,
    p_cycle_id UUID DEFAULT NULL,
    p_limit INT DEFAULT 50
)
RETURNS TABLE (
    initiative_id UUID,
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
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
BEGIN
    PERFORM strategy._gs_patch_v1_ui_apis_assert_tenant(p_tenant_id);

    RETURN QUERY
    SELECT
        o.id AS initiative_id,
        o.tenant_id,
        strategy._gs_patch_v1_ui_apis_cycle_id(o.tenant_id, o.cycle_type, o.cycle_start_date, o.cycle_end_date) AS cycle_id,
        o.code,
        o.title,
        o.description,
        o.status,
        o.owner_person_id,
        o.cycle_type,
        o.cycle_start_date,
        o.cycle_end_date,
        o.created_at,
        o.updated_at
    FROM strategy.objectives o
    WHERE o.tenant_id = p_tenant_id
      AND (
        p_cycle_id IS NULL
        OR strategy._gs_patch_v1_ui_apis_cycle_id(o.tenant_id, o.cycle_type, o.cycle_start_date, o.cycle_end_date) = p_cycle_id
      )
    ORDER BY
        o.cycle_start_date DESC NULLS LAST,
        o.created_at DESC NULLS LAST,
        o.id ASC
    LIMIT GREATEST(1, LEAST(COALESCE(p_limit, 50), 200));
END;
$$;

COMMENT ON FUNCTION strategy.list_initiatives IS 'Lista iniciativas (objectives) do tenant (opcional por ciclo) — GS-PATCH V1 Strategy UI APIs';

CREATE OR REPLACE FUNCTION strategy.get_initiative(
    p_tenant_id UUID,
    p_initiative_id UUID
)
RETURNS TABLE (
    initiative_id UUID,
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
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
DECLARE
    v_corr UUID;
BEGIN
    PERFORM strategy._gs_patch_v1_ui_apis_assert_tenant(p_tenant_id);
    v_corr := strategy._gs_patch_v1_ui_apis_get_correlation_id();

    RETURN QUERY
    SELECT
        o.id AS initiative_id,
        o.tenant_id,
        strategy._gs_patch_v1_ui_apis_cycle_id(o.tenant_id, o.cycle_type, o.cycle_start_date, o.cycle_end_date) AS cycle_id,
        o.code,
        o.title,
        o.description,
        o.status,
        o.owner_person_id,
        o.cycle_type,
        o.cycle_start_date,
        o.cycle_end_date,
        o.created_at,
        o.updated_at
    FROM strategy.objectives o
    WHERE o.tenant_id = p_tenant_id
      AND o.id = p_initiative_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING
            MESSAGE = 'iniciativa não encontrada',
            DETAIL  = jsonb_build_object('code','NOT_FOUND','correlation_id',v_corr)::text;
    END IF;
END;
$$;

COMMENT ON FUNCTION strategy.get_initiative IS 'Retorna iniciativa (objective) por id do tenant — GS-PATCH V1 Strategy UI APIs';

CREATE OR REPLACE FUNCTION strategy.get_portfolio_snapshot(
    p_tenant_id UUID,
    p_cycle_id UUID
)
RETURNS TABLE (
    tenant_id UUID,
    cycle_id UUID,
    objectives_total INT,
    objectives_active INT,
    objectives_completed INT,
    objectives_blocked INT,
    updated_at_max TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
BEGIN
    PERFORM strategy._gs_patch_v1_ui_apis_assert_tenant(p_tenant_id);

    RETURN QUERY
    SELECT
        p_tenant_id AS tenant_id,
        p_cycle_id AS cycle_id,
        count(*)::int AS objectives_total,
        count(*) FILTER (WHERE o.status = 'active')::int AS objectives_active,
        count(*) FILTER (WHERE o.status = 'completed')::int AS objectives_completed,
        count(*) FILTER (WHERE o.status = 'blocked')::int AS objectives_blocked,
        max(o.updated_at) AS updated_at_max
    FROM strategy.objectives o
    WHERE o.tenant_id = p_tenant_id
      AND strategy._gs_patch_v1_ui_apis_cycle_id(o.tenant_id, o.cycle_type, o.cycle_start_date, o.cycle_end_date) = p_cycle_id;
END;
$$;

COMMENT ON FUNCTION strategy.get_portfolio_snapshot IS 'Retorna snapshot agregado (determinístico; sem JSON) para ciclo do tenant — GS-PATCH V1 Strategy UI APIs';


