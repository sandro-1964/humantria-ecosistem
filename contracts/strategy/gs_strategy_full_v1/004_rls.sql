-- HUMANTRÍA — STRATEGY GS FULL V1 — RLS
-- tenant_admin, gestor: ALL; especialista, auditor: SELECT

SET search_path TO strategy, foundation, public;

ALTER TABLE strategy.objectives ENABLE ROW LEVEL SECURITY;
ALTER TABLE strategy.initiatives ENABLE ROW LEVEL SECURITY;

-- objectives: Platform Owner
CREATE POLICY policy_strategy_objectives_platform_owner_all
    ON strategy.objectives FOR ALL TO authenticated
    USING (foundation.is_platform_owner()) WITH CHECK (foundation.is_platform_owner());

-- objectives: Tenant Admin
CREATE POLICY policy_strategy_objectives_tenant_admin_all
    ON strategy.objectives FOR ALL TO authenticated
    USING (tenant_id = foundation.get_current_tenant_id() AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin')
    WITH CHECK (tenant_id = foundation.get_current_tenant_id() AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin');

-- objectives: Gestor
CREATE POLICY policy_strategy_objectives_gestor_all
    ON strategy.objectives FOR ALL TO authenticated
    USING (tenant_id = foundation.get_current_tenant_id() AND current_setting('request.jwt.claims', true)::json->>'role' = 'gestor')
    WITH CHECK (tenant_id = foundation.get_current_tenant_id() AND current_setting('request.jwt.claims', true)::json->>'role' = 'gestor');

-- objectives: Especialista, Auditor (SELECT)
CREATE POLICY policy_strategy_objectives_analyst_select
    ON strategy.objectives FOR SELECT TO authenticated
    USING (tenant_id = foundation.get_current_tenant_id() AND current_setting('request.jwt.claims', true)::json->>'role' IN ('especialista', 'auditor'));

-- initiatives: Platform Owner
CREATE POLICY policy_strategy_initiatives_platform_owner_all
    ON strategy.initiatives FOR ALL TO authenticated
    USING (foundation.is_platform_owner()) WITH CHECK (foundation.is_platform_owner());

-- initiatives: Tenant Admin
CREATE POLICY policy_strategy_initiatives_tenant_admin_all
    ON strategy.initiatives FOR ALL TO authenticated
    USING (tenant_id = foundation.get_current_tenant_id() AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin')
    WITH CHECK (tenant_id = foundation.get_current_tenant_id() AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin');

-- initiatives: Gestor
CREATE POLICY policy_strategy_initiatives_gestor_all
    ON strategy.initiatives FOR ALL TO authenticated
    USING (tenant_id = foundation.get_current_tenant_id() AND current_setting('request.jwt.claims', true)::json->>'role' = 'gestor')
    WITH CHECK (tenant_id = foundation.get_current_tenant_id() AND current_setting('request.jwt.claims', true)::json->>'role' = 'gestor');

-- initiatives: Especialista, Auditor (SELECT)
CREATE POLICY policy_strategy_initiatives_analyst_select
    ON strategy.initiatives FOR SELECT TO authenticated
    USING (tenant_id = foundation.get_current_tenant_id() AND current_setting('request.jwt.claims', true)::json->>'role' IN ('especialista', 'auditor'));

-- service_role (integration tests, backend ops)
GRANT SELECT, INSERT, UPDATE, DELETE ON strategy.objectives TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON strategy.initiatives TO service_role;
