-- HUMANTRÍA — CORE PATCH ECONOMICS V1 — RLS
-- Status: PATCH (Core V1 frozen)
-- Escopo: Row Level Security para Workforce Economics Engine
-- Regras: Platform Owner (all), Tenant Admin (all), Business profiles (select), Auditor (select history)

SET search_path TO core, foundation, public;

-- ============================================================================
-- HABILITAR RLS
-- ============================================================================

-- Currencies & Exchange Rates
ALTER TABLE core.currencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.exchange_rates ENABLE ROW LEVEL SECURITY;

-- Salary Structures
ALTER TABLE core.salary_structures ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.salary_structure_history ENABLE ROW LEVEL SECURITY;

-- Cost Parameters
ALTER TABLE core.cost_parameters ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.cost_parameter_history ENABLE ROW LEVEL SECURITY;

-- Economic Benchmarks
ALTER TABLE core.economic_benchmarks ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- CURRENCIES
-- ============================================================================

-- Platform Owner: visão soberana (all)
CREATE POLICY policy_currencies_platform_owner_all
    ON core.currencies
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

-- Tenant Admin: todos os currencies do tenant + globais
CREATE POLICY policy_currencies_tenant_admin_all
    ON core.currencies
    FOR ALL
    TO authenticated
    USING (
        (tenant_id = foundation.get_current_tenant_id() OR tenant_id IS NULL)
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    )
    WITH CHECK (
        (tenant_id = foundation.get_current_tenant_id() OR tenant_id IS NULL)
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

-- Business profiles: leitura de currencies do tenant + globais
CREATE POLICY policy_currencies_business_profiles_select
    ON core.currencies
    FOR SELECT
    TO authenticated
    USING (
        (tenant_id = foundation.get_current_tenant_id() OR tenant_id IS NULL)
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- EXCHANGE RATES
-- ============================================================================

-- Platform Owner: visão soberana (all)
CREATE POLICY policy_exchange_rates_platform_owner_all
    ON core.exchange_rates
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

-- Tenant Admin: todos os exchange_rates do tenant + globais
CREATE POLICY policy_exchange_rates_tenant_admin_all
    ON core.exchange_rates
    FOR ALL
    TO authenticated
    USING (
        (tenant_id = foundation.get_current_tenant_id() OR tenant_id IS NULL)
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    )
    WITH CHECK (
        (tenant_id = foundation.get_current_tenant_id() OR tenant_id IS NULL)
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

-- Business profiles: leitura de exchange_rates do tenant + globais
CREATE POLICY policy_exchange_rates_business_profiles_select
    ON core.exchange_rates
    FOR SELECT
    TO authenticated
    USING (
        (tenant_id = foundation.get_current_tenant_id() OR tenant_id IS NULL)
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- SALARY STRUCTURES
-- ============================================================================

-- Platform Owner: visão soberana (all)
CREATE POLICY policy_salary_structures_platform_owner_all
    ON core.salary_structures
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

-- Tenant Admin: todos os salary_structures do tenant
CREATE POLICY policy_salary_structures_tenant_admin_all
    ON core.salary_structures
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

-- Business profiles: leitura de salary_structures do tenant (dados sensíveis)
CREATE POLICY policy_salary_structures_business_profiles_select
    ON core.salary_structures
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista', 'auditor')
    );

-- ============================================================================
-- SALARY STRUCTURE HISTORY
-- ============================================================================

-- Platform Owner: visão soberana (select)
CREATE POLICY policy_salary_structure_history_platform_owner_select
    ON core.salary_structure_history
    FOR SELECT
    TO authenticated
    USING (foundation.is_platform_owner());

-- Tenant Admin: histórico do tenant
CREATE POLICY policy_salary_structure_history_tenant_admin_select
    ON core.salary_structure_history
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('tenant_admin', 'auditor')
    );

-- Auditor: acesso a histórico
CREATE POLICY policy_salary_structure_history_auditor_select
    ON core.salary_structure_history
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'auditor'
    );

-- System: inserção automática de histórico
CREATE POLICY policy_salary_structure_history_system_insert
    ON core.salary_structure_history
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- ============================================================================
-- COST PARAMETERS
-- ============================================================================

-- Platform Owner: visão soberana (all)
CREATE POLICY policy_cost_parameters_platform_owner_all
    ON core.cost_parameters
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

-- Tenant Admin: todos os cost_parameters do tenant
CREATE POLICY policy_cost_parameters_tenant_admin_all
    ON core.cost_parameters
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

-- Business profiles: leitura de cost_parameters do tenant
CREATE POLICY policy_cost_parameters_business_profiles_select
    ON core.cost_parameters
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- COST PARAMETER HISTORY
-- ============================================================================

-- Platform Owner: visão soberana (select)
CREATE POLICY policy_cost_parameter_history_platform_owner_select
    ON core.cost_parameter_history
    FOR SELECT
    TO authenticated
    USING (foundation.is_platform_owner());

-- Tenant Admin: histórico do tenant
CREATE POLICY policy_cost_parameter_history_tenant_admin_select
    ON core.cost_parameter_history
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('tenant_admin', 'auditor')
    );

-- Auditor: acesso a histórico
CREATE POLICY policy_cost_parameter_history_auditor_select
    ON core.cost_parameter_history
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'auditor'
    );

-- System: inserção automática de histórico
CREATE POLICY policy_cost_parameter_history_system_insert
    ON core.cost_parameter_history
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- ============================================================================
-- ECONOMIC BENCHMARKS
-- ============================================================================

-- Platform Owner: visão soberana (all)
CREATE POLICY policy_economic_benchmarks_platform_owner_all
    ON core.economic_benchmarks
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

-- Tenant Admin: benchmarks do tenant + globais
CREATE POLICY policy_economic_benchmarks_tenant_admin_all
    ON core.economic_benchmarks
    FOR ALL
    TO authenticated
    USING (
        (tenant_id = foundation.get_current_tenant_id() OR tenant_id IS NULL)
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    )
    WITH CHECK (
        (tenant_id = foundation.get_current_tenant_id() OR tenant_id IS NULL)
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

-- Business profiles: leitura de benchmarks do tenant + globais
CREATE POLICY policy_economic_benchmarks_business_profiles_select
    ON core.economic_benchmarks
    FOR SELECT
    TO authenticated
    USING (
        (tenant_id = foundation.get_current_tenant_id() OR tenant_id IS NULL)
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );
