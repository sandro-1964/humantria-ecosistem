-- HUMANTRÍA — GS-PATCH CORE RLS POLICIES V1
-- Arquivo: 001_core_rls_missing_policies.sql
-- Status: PATCH
-- Objetivo: adicionar policies tenant-safe para 8 tabelas core com RLS=true e sem policy
-- Regras: não criar tabelas, não alterar colunas, não criar FKs

SET search_path TO core, foundation, public;

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

CREATE POLICY policy_person_identities_auditor_select
    ON core.person_identities
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('auditor', 'especialista')
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
