-- HUMANTRÍA — GS-PATCH FK Cleanup V1 — Core contract surfaces (core_assert)
-- Superfícies de contrato para validação em write (produtos consomem Core por contrato, não por FK).
-- Schema core_assert + funções SECURITY DEFINER com checagem de tenant.

-- Schema (contrato de assert mínimo) — criar antes de usar no search_path
CREATE SCHEMA IF NOT EXISTS core_assert;
COMMENT ON SCHEMA core_assert IS 'Contrato de validação (assert) para entidades Core; usado por produtos em write, sem FK.';

SET search_path TO core_assert, core, foundation, public;

-- assert_person_exists
CREATE OR REPLACE FUNCTION core_assert.assert_person_exists(p_tenant_id uuid, p_person_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO core, public
AS $$
BEGIN
    IF p_person_id IS NULL THEN
        RETURN;
    END IF;
    IF p_tenant_id IS NULL THEN
        RAISE EXCEPTION 'assert_person_exists: tenant_id is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM core.people WHERE id = p_person_id AND tenant_id = p_tenant_id) THEN
        RAISE EXCEPTION 'assert_person_exists: person % not found or does not belong to tenant %', p_person_id, p_tenant_id;
    END IF;
END;
$$;
COMMENT ON FUNCTION core_assert.assert_person_exists(uuid, uuid) IS 'Garante que person existe no tenant (contrato Core para produtos).';

-- assert_org_unit_exists
CREATE OR REPLACE FUNCTION core_assert.assert_org_unit_exists(p_tenant_id uuid, p_org_unit_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO core, public
AS $$
BEGIN
    IF p_org_unit_id IS NULL THEN
        RETURN;
    END IF;
    IF p_tenant_id IS NULL THEN
        RAISE EXCEPTION 'assert_org_unit_exists: tenant_id is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM core.org_units WHERE id = p_org_unit_id AND tenant_id = p_tenant_id) THEN
        RAISE EXCEPTION 'assert_org_unit_exists: org_unit % not found or does not belong to tenant %', p_org_unit_id, p_tenant_id;
    END IF;
END;
$$;
COMMENT ON FUNCTION core_assert.assert_org_unit_exists(uuid, uuid) IS 'Garante que org_unit existe no tenant (contrato Core para produtos).';

-- assert_cost_center_exists
CREATE OR REPLACE FUNCTION core_assert.assert_cost_center_exists(p_tenant_id uuid, p_cost_center_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO core, public
AS $$
BEGIN
    IF p_cost_center_id IS NULL THEN
        RETURN;
    END IF;
    IF p_tenant_id IS NULL THEN
        RAISE EXCEPTION 'assert_cost_center_exists: tenant_id is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM core.cost_centers WHERE id = p_cost_center_id AND tenant_id = p_tenant_id) THEN
        RAISE EXCEPTION 'assert_cost_center_exists: cost_center % not found or does not belong to tenant %', p_cost_center_id, p_tenant_id;
    END IF;
END;
$$;
COMMENT ON FUNCTION core_assert.assert_cost_center_exists(uuid, uuid) IS 'Garante que cost_center existe no tenant (contrato Core para produtos).';

-- assert_job_exists
CREATE OR REPLACE FUNCTION core_assert.assert_job_exists(p_tenant_id uuid, p_job_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO core, public
AS $$
BEGIN
    IF p_job_id IS NULL THEN
        RETURN;
    END IF;
    IF p_tenant_id IS NULL THEN
        RAISE EXCEPTION 'assert_job_exists: tenant_id is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM core.jobs WHERE id = p_job_id AND tenant_id = p_tenant_id) THEN
        RAISE EXCEPTION 'assert_job_exists: job % not found or does not belong to tenant %', p_job_id, p_tenant_id;
    END IF;
END;
$$;
COMMENT ON FUNCTION core_assert.assert_job_exists(uuid, uuid) IS 'Garante que job existe no tenant (contrato Core para produtos).';

-- assert_job_level_exists
CREATE OR REPLACE FUNCTION core_assert.assert_job_level_exists(p_tenant_id uuid, p_job_level_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO core, public
AS $$
BEGIN
    IF p_job_level_id IS NULL THEN
        RETURN;
    END IF;
    IF p_tenant_id IS NULL THEN
        RAISE EXCEPTION 'assert_job_level_exists: tenant_id is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM core.job_levels WHERE id = p_job_level_id AND tenant_id = p_tenant_id) THEN
        RAISE EXCEPTION 'assert_job_level_exists: job_level % not found or does not belong to tenant %', p_job_level_id, p_tenant_id;
    END IF;
END;
$$;
COMMENT ON FUNCTION core_assert.assert_job_level_exists(uuid, uuid) IS 'Garante que job_level existe no tenant (contrato Core para produtos).';

-- Grants mínimos
GRANT USAGE ON SCHEMA core_assert TO authenticated;
GRANT USAGE ON SCHEMA core_assert TO service_role;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA core_assert TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA core_assert TO service_role;
