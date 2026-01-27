-- HUMANTRÍA — CORE — GS-PATCH V1 — UI/APIs mínimas
-- Arquivo: 002_patch_functions.sql
-- Status: PATCH (Core V1 frozen)
--
-- Objetivo: regularizar e “fechar contrato” das RPCs mínimas consumidas pela UI Runtime e produtos.
-- Regras: SECURITY INVOKER, multi-tenant, sem bypass invisível, sem JSON cru para UI.

SET search_path TO core, foundation, public;

-- ============================================================================
-- HELPERS (internos) — validação & erro governado
-- ============================================================================

-- Obter correlation_id se disponível via headers (best-effort), senão gera UUID
CREATE OR REPLACE FUNCTION core._gs_patch_v1_ui_apis_get_correlation_id()
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

COMMENT ON FUNCTION core._gs_patch_v1_ui_apis_get_correlation_id IS 'GS-PATCH V1 UI/APIs: best-effort correlation_id (headers) ou UUID gerado';

-- Validar tenant_id governado para funções deste patch
CREATE OR REPLACE FUNCTION core._gs_patch_v1_ui_apis_assert_tenant(p_tenant_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
DECLARE
    v_ctx_tenant_id UUID;
    v_corr UUID;
BEGIN
    v_corr := core._gs_patch_v1_ui_apis_get_correlation_id();

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

COMMENT ON FUNCTION core._gs_patch_v1_ui_apis_assert_tenant IS 'GS-PATCH V1 UI/APIs: valida tenant_id (contexto) e retorna tenant validado';

-- ============================================================================
-- A) Org/Jobs/Levels — RPCs mínimas
-- ============================================================================

-- Listar jobs por tenant
CREATE OR REPLACE FUNCTION core.list_jobs(
    p_tenant_id UUID
)
RETURNS TABLE (
    id UUID,
    tenant_id UUID,
    code TEXT,
    name TEXT,
    description TEXT,
    is_active BOOLEAN,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
BEGIN
    PERFORM core._gs_patch_v1_ui_apis_assert_tenant(p_tenant_id);

    RETURN QUERY
    SELECT
        j.id,
        j.tenant_id,
        j.code,
        j.name,
        j.description,
        j.is_active,
        j.created_at,
        j.updated_at
    FROM core.jobs j
    WHERE j.tenant_id = p_tenant_id
    ORDER BY j.code;
END;
$$;

COMMENT ON FUNCTION core.list_jobs IS 'Lista jobs do tenant (GS-PATCH V1 UI/APIs mínimas)';

-- Listar job_levels por tenant (opcional: filtrar por job)
CREATE OR REPLACE FUNCTION core.list_job_levels(
    p_tenant_id UUID,
    p_job_id UUID DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    tenant_id UUID,
    job_id UUID,
    level_code TEXT,
    level_name TEXT,
    level_number INTEGER,
    description TEXT,
    is_active BOOLEAN,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
BEGIN
    PERFORM core._gs_patch_v1_ui_apis_assert_tenant(p_tenant_id);

    RETURN QUERY
    SELECT
        jl.id,
        jl.tenant_id,
        jl.job_id,
        jl.level_code,
        jl.level_name,
        jl.seniority_level AS level_number,
        jl.description,
        jl.is_active,
        jl.created_at,
        jl.updated_at
    FROM core.job_levels jl
    WHERE jl.tenant_id = p_tenant_id
      AND (p_job_id IS NULL OR jl.job_id = p_job_id)
    ORDER BY jl.job_id, jl.seniority_level NULLS LAST, jl.level_code;
END;
$$;

COMMENT ON FUNCTION core.list_job_levels IS 'Lista job_levels do tenant (opcional por job) (GS-PATCH V1 UI/APIs mínimas)';

-- Matriz Jobs x Levels (grade simples: levels pertencem ao job)
CREATE OR REPLACE FUNCTION core.get_job_matrix(
    p_tenant_id UUID
)
RETURNS TABLE (
    job_id UUID,
    job_code TEXT,
    job_name TEXT,
    job_is_active BOOLEAN,
    job_level_id UUID,
    level_code TEXT,
    level_name TEXT,
    level_number INTEGER,
    level_is_active BOOLEAN
)
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
BEGIN
    PERFORM core._gs_patch_v1_ui_apis_assert_tenant(p_tenant_id);

    RETURN QUERY
    SELECT
        j.id AS job_id,
        j.code AS job_code,
        j.name AS job_name,
        j.is_active AS job_is_active,
        jl.id AS job_level_id,
        jl.level_code,
        jl.level_name,
        jl.seniority_level AS level_number,
        jl.is_active AS level_is_active
    FROM core.jobs j
    LEFT JOIN core.job_levels jl
        ON jl.job_id = j.id
       AND jl.tenant_id = j.tenant_id
    WHERE j.tenant_id = p_tenant_id
    ORDER BY j.code, jl.seniority_level NULLS LAST, jl.level_code;
END;
$$;

COMMENT ON FUNCTION core.get_job_matrix IS 'Retorna matriz jobs x levels (grade simples) para o tenant (GS-PATCH V1 UI/APIs mínimas)';

-- Árvore organizacional (modelo canônico atual: parent_id em core.org_units)
CREATE OR REPLACE FUNCTION core.get_org_tree(
    p_tenant_id UUID
)
RETURNS TABLE (
    id UUID,
    tenant_id UUID,
    parent_id UUID,
    code TEXT,
    name TEXT,
    description TEXT,
    org_unit_type TEXT,
    is_active BOOLEAN,
    depth INTEGER,
    path TEXT
)
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
BEGIN
    PERFORM core._gs_patch_v1_ui_apis_assert_tenant(p_tenant_id);

    RETURN QUERY
    WITH RECURSIVE tree AS (
        SELECT
            ou.id,
            ou.tenant_id,
            ou.parent_id,
            ou.code,
            ou.name,
            ou.description,
            ou.org_unit_type,
            ou.is_active,
            0 AS depth,
            ou.code::text AS path
        FROM core.org_units ou
        WHERE ou.tenant_id = p_tenant_id
          AND ou.parent_id IS NULL

        UNION ALL

        SELECT
            child.id,
            child.tenant_id,
            child.parent_id,
            child.code,
            child.name,
            child.description,
            child.org_unit_type,
            child.is_active,
            parent.depth + 1 AS depth,
            (parent.path || '/' || child.code)::text AS path
        FROM core.org_units child
        JOIN tree parent
          ON child.parent_id = parent.id
         AND child.tenant_id = parent.tenant_id
        WHERE child.tenant_id = p_tenant_id
    )
    SELECT
        t.id,
        t.tenant_id,
        t.parent_id,
        t.code,
        t.name,
        t.description,
        t.org_unit_type,
        t.is_active,
        t.depth,
        t.path
    FROM tree t
    ORDER BY t.path;
END;
$$;

COMMENT ON FUNCTION core.get_org_tree IS 'Retorna org tree (parent_id) com depth/path (GS-PATCH V1 UI/APIs mínimas)';

