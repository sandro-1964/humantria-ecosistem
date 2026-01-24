-- HUMANTRÍA — CORE RLS V1
-- Status: BLOQUEANTE
-- Escopo: Row Level Security para Platform Owner, Tenant Admin e perfis de negócio

SET search_path TO core, foundation, public;

-- ============================================================================
-- HABILITAR RLS
-- ============================================================================

-- Organização
ALTER TABLE core.org_units ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.org_units_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.cost_centers ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.org_unit_cost_center_links ENABLE ROW LEVEL SECURITY;

-- Jobs/Levels
ALTER TABLE core.jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.job_levels ENABLE ROW LEVEL SECURITY;

-- People
ALTER TABLE core.people ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.person_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.person_identities ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.person_org_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.person_status_history ENABLE ROW LEVEL SECURITY;

-- Imports
ALTER TABLE core.import_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.import_job_runs ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.import_row_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.import_mappings ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- ORG_UNITS
-- ============================================================================

-- Platform Owner: visão soberana
CREATE POLICY policy_org_units_platform_owner_all
    ON core.org_units
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

-- Tenant Admin: todos os org_units do tenant
CREATE POLICY policy_org_units_tenant_admin_all
    ON core.org_units
    FOR ALL
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

-- Perfis de negócio: leitura de org_units do tenant
CREATE POLICY policy_org_units_business_profiles_select
    ON core.org_units
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- ORG_UNITS_HISTORY
-- ============================================================================

CREATE POLICY policy_org_units_history_platform_owner_all
    ON core.org_units_history
    FOR SELECT
    TO authenticated
    USING (foundation.is_platform_owner());

CREATE POLICY policy_org_units_history_tenant_admin_all
    ON core.org_units_history
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('tenant_admin', 'auditor')
    );

CREATE POLICY policy_org_units_history_system_insert
    ON core.org_units_history
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- ============================================================================
-- COST_CENTERS
-- ============================================================================

CREATE POLICY policy_cost_centers_platform_owner_all
    ON core.cost_centers
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_cost_centers_tenant_admin_all
    ON core.cost_centers
    FOR ALL
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_cost_centers_business_profiles_select
    ON core.cost_centers
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- ORG_UNIT_COST_CENTER_LINKS
-- ============================================================================

CREATE POLICY policy_org_unit_cost_center_links_platform_owner_all
    ON core.org_unit_cost_center_links
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_org_unit_cost_center_links_tenant_admin_all
    ON core.org_unit_cost_center_links
    FOR ALL
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_org_unit_cost_center_links_business_profiles_select
    ON core.org_unit_cost_center_links
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- JOBS
-- ============================================================================

CREATE POLICY policy_jobs_platform_owner_all
    ON core.jobs
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_jobs_tenant_admin_all
    ON core.jobs
    FOR ALL
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_jobs_business_profiles_select
    ON core.jobs
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- JOB_LEVELS
-- ============================================================================

CREATE POLICY policy_job_levels_platform_owner_all
    ON core.job_levels
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_job_levels_tenant_admin_all
    ON core.job_levels
    FOR ALL
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_job_levels_business_profiles_select
    ON core.job_levels
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- PEOPLE
-- ============================================================================

CREATE POLICY policy_people_platform_owner_all
    ON core.people
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_people_tenant_admin_all
    ON core.people
    FOR ALL
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

-- Perfis de negócio: leitura de people do tenant (com restrições futuras se necessário)
CREATE POLICY policy_people_business_profiles_select
    ON core.people
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- PERSON_CONTACTS
-- ============================================================================

CREATE POLICY policy_person_contacts_platform_owner_all
    ON core.person_contacts
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_person_contacts_tenant_admin_all
    ON core.person_contacts
    FOR ALL
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_person_contacts_business_profiles_select
    ON core.person_contacts
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- PERSON_IDENTITIES
-- ============================================================================

CREATE POLICY policy_person_identities_platform_owner_all
    ON core.person_identities
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_person_identities_tenant_admin_all
    ON core.person_identities
    FOR ALL
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

-- Auditor e especialista podem ler (dados sensíveis)
CREATE POLICY policy_person_identities_auditor_select
    ON core.person_identities
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('auditor', 'especialista')
    );

-- ============================================================================
-- PERSON_ORG_ASSIGNMENTS
-- ============================================================================

CREATE POLICY policy_person_org_assignments_platform_owner_all
    ON core.person_org_assignments
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_person_org_assignments_tenant_admin_all
    ON core.person_org_assignments
    FOR ALL
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_person_org_assignments_business_profiles_select
    ON core.person_org_assignments
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- PERSON_STATUS_HISTORY
-- ============================================================================

CREATE POLICY policy_person_status_history_platform_owner_all
    ON core.person_status_history
    FOR SELECT
    TO authenticated
    USING (foundation.is_platform_owner());

CREATE POLICY policy_person_status_history_tenant_admin_all
    ON core.person_status_history
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('tenant_admin', 'auditor')
    );

CREATE POLICY policy_person_status_history_system_insert
    ON core.person_status_history
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- ============================================================================
-- IMPORT_JOBS
-- ============================================================================

CREATE POLICY policy_import_jobs_platform_owner_all
    ON core.import_jobs
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_import_jobs_tenant_admin_all
    ON core.import_jobs
    FOR ALL
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_import_jobs_business_profiles_select
    ON core.import_jobs
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista', 'auditor')
    );

-- ============================================================================
-- IMPORT_JOB_RUNS
-- ============================================================================

CREATE POLICY policy_import_job_runs_platform_owner_all
    ON core.import_job_runs
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_import_job_runs_tenant_admin_all
    ON core.import_job_runs
    FOR ALL
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_import_job_runs_business_profiles_select
    ON core.import_job_runs
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista', 'auditor')
    );

-- ============================================================================
-- IMPORT_ROW_RESULTS
-- ============================================================================

CREATE POLICY policy_import_row_results_platform_owner_all
    ON core.import_row_results
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_import_row_results_tenant_admin_all
    ON core.import_row_results
    FOR ALL
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_import_row_results_business_profiles_select
    ON core.import_row_results
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista', 'auditor')
    );

-- ============================================================================
-- IMPORT_MAPPINGS
-- ============================================================================

CREATE POLICY policy_import_mappings_platform_owner_all
    ON core.import_mappings
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_import_mappings_tenant_admin_all
    ON core.import_mappings
    FOR ALL
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_import_mappings_business_profiles_select
    ON core.import_mappings
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista', 'auditor')
    );
