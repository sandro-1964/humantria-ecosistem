-- HUMANTRÍA — STRATEGY RLS V1
-- Status: BLOQUEANTE
-- Escopo: Row Level Security para Platform Owner, Tenant Admin e perfis de negócio

SET search_path TO strategy, core, foundation, public;

-- ============================================================================
-- HABILITAR RLS
-- ============================================================================

-- Objetivos & Metas
ALTER TABLE strategy.objective_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE strategy.objectives ENABLE ROW LEVEL SECURITY;
ALTER TABLE strategy.key_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE strategy.objective_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE strategy.objective_evidence ENABLE ROW LEVEL SECURITY;

-- Orçamento
ALTER TABLE strategy.budget_currencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE strategy.budget_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE strategy.budget_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE strategy.budget_approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE strategy.budget_actuals ENABLE ROW LEVEL SECURITY;

-- Staffing Plan
ALTER TABLE strategy.staffing_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE strategy.staffing_demands ENABLE ROW LEVEL SECURITY;
ALTER TABLE strategy.staffing_calculated_costs ENABLE ROW LEVEL SECURITY;
ALTER TABLE strategy.staffing_actuals ENABLE ROW LEVEL SECURITY;

-- Simulações & IA
ALTER TABLE strategy.ai_suggestions ENABLE ROW LEVEL SECURITY;
ALTER TABLE strategy.ai_simulations ENABLE ROW LEVEL SECURITY;
ALTER TABLE strategy.risk_alerts ENABLE ROW LEVEL SECURITY;

-- Workflows
ALTER TABLE strategy.approval_workflows ENABLE ROW LEVEL SECURITY;
ALTER TABLE strategy.approval_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE strategy.approval_history ENABLE ROW LEVEL SECURITY;

-- Dashboards
ALTER TABLE strategy.executive_dashboards ENABLE ROW LEVEL SECURITY;
ALTER TABLE strategy.dashboard_kpis ENABLE ROW LEVEL SECURITY;

-- Templates
ALTER TABLE strategy.budget_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE strategy.staffing_templates ENABLE ROW LEVEL SECURITY;

-- Import/Export
ALTER TABLE strategy.export_jobs ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- OBJECTIVE_TEMPLATES
-- ============================================================================

CREATE POLICY policy_objective_templates_platform_owner_all
    ON strategy.objective_templates
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_objective_templates_tenant_admin_all
    ON strategy.objective_templates
    FOR ALL
    TO authenticated
    USING (
        (tenant_id = foundation.get_current_tenant_id() OR is_global = TRUE)
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_objective_templates_business_profiles_select
    ON strategy.objective_templates
    FOR SELECT
    TO authenticated
    USING (
        (tenant_id = foundation.get_current_tenant_id() OR is_global = TRUE)
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- OBJECTIVES
-- ============================================================================

CREATE POLICY policy_objectives_platform_owner_all
    ON strategy.objectives
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_objectives_tenant_admin_all
    ON strategy.objectives
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

CREATE POLICY policy_objectives_business_profiles_select
    ON strategy.objectives
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

CREATE POLICY policy_objectives_business_profiles_update
    ON strategy.objectives
    FOR UPDATE
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    );

-- ============================================================================
-- KEY_RESULTS
-- ============================================================================

CREATE POLICY policy_key_results_platform_owner_all
    ON strategy.key_results
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_key_results_tenant_admin_all
    ON strategy.key_results
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

CREATE POLICY policy_key_results_business_profiles_select
    ON strategy.key_results
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

CREATE POLICY policy_key_results_business_profiles_update
    ON strategy.key_results
    FOR UPDATE
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    );

-- ============================================================================
-- OBJECTIVE_HISTORY
-- ============================================================================

CREATE POLICY policy_objective_history_platform_owner_all
    ON strategy.objective_history
    FOR SELECT
    TO authenticated
    USING (foundation.is_platform_owner());

CREATE POLICY policy_objective_history_tenant_admin_all
    ON strategy.objective_history
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('tenant_admin', 'auditor')
    );

CREATE POLICY policy_objective_history_system_insert
    ON strategy.objective_history
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- ============================================================================
-- OBJECTIVE_EVIDENCE
-- ============================================================================

CREATE POLICY policy_objective_evidence_platform_owner_all
    ON strategy.objective_evidence
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_objective_evidence_tenant_admin_all
    ON strategy.objective_evidence
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

CREATE POLICY policy_objective_evidence_business_profiles_select
    ON strategy.objective_evidence
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

CREATE POLICY policy_objective_evidence_business_profiles_insert
    ON strategy.objective_evidence
    FOR INSERT
    TO authenticated
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    );

-- ============================================================================
-- BUDGET_CURRENCIES
-- ============================================================================

CREATE POLICY policy_budget_currencies_platform_owner_all
    ON strategy.budget_currencies
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_budget_currencies_tenant_admin_all
    ON strategy.budget_currencies
    FOR ALL
    TO authenticated
    USING (
        (tenant_id = foundation.get_current_tenant_id() OR is_global = TRUE)
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_budget_currencies_business_profiles_select
    ON strategy.budget_currencies
    FOR SELECT
    TO authenticated
    USING (
        (tenant_id = foundation.get_current_tenant_id() OR is_global = TRUE)
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- BUDGET_VERSIONS
-- ============================================================================

CREATE POLICY policy_budget_versions_platform_owner_all
    ON strategy.budget_versions
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_budget_versions_tenant_admin_all
    ON strategy.budget_versions
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

CREATE POLICY policy_budget_versions_business_profiles_select
    ON strategy.budget_versions
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

CREATE POLICY policy_budget_versions_business_profiles_update
    ON strategy.budget_versions
    FOR UPDATE
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    );

-- ============================================================================
-- BUDGET_ITEMS
-- ============================================================================

CREATE POLICY policy_budget_items_platform_owner_all
    ON strategy.budget_items
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_budget_items_tenant_admin_all
    ON strategy.budget_items
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

CREATE POLICY policy_budget_items_business_profiles_select
    ON strategy.budget_items
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

CREATE POLICY policy_budget_items_business_profiles_update
    ON strategy.budget_items
    FOR UPDATE
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    );

-- ============================================================================
-- BUDGET_APPROVALS
-- ============================================================================

CREATE POLICY policy_budget_approvals_platform_owner_all
    ON strategy.budget_approvals
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_budget_approvals_tenant_admin_all
    ON strategy.budget_approvals
    FOR ALL
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('tenant_admin', 'gestor')
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('tenant_admin', 'gestor')
    );

CREATE POLICY policy_budget_approvals_business_profiles_select
    ON strategy.budget_approvals
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- BUDGET_ACTUALS
-- ============================================================================

CREATE POLICY policy_budget_actuals_platform_owner_all
    ON strategy.budget_actuals
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_budget_actuals_tenant_admin_all
    ON strategy.budget_actuals
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

CREATE POLICY policy_budget_actuals_business_profiles_select
    ON strategy.budget_actuals
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- STAFFING_PLANS
-- ============================================================================

CREATE POLICY policy_staffing_plans_platform_owner_all
    ON strategy.staffing_plans
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_staffing_plans_tenant_admin_all
    ON strategy.staffing_plans
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

CREATE POLICY policy_staffing_plans_business_profiles_select
    ON strategy.staffing_plans
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

CREATE POLICY policy_staffing_plans_business_profiles_update
    ON strategy.staffing_plans
    FOR UPDATE
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    );

-- ============================================================================
-- STAFFING_DEMANDS
-- ============================================================================

CREATE POLICY policy_staffing_demands_platform_owner_all
    ON strategy.staffing_demands
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_staffing_demands_tenant_admin_all
    ON strategy.staffing_demands
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

CREATE POLICY policy_staffing_demands_business_profiles_select
    ON strategy.staffing_demands
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

CREATE POLICY policy_staffing_demands_business_profiles_update
    ON strategy.staffing_demands
    FOR UPDATE
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    );

-- ============================================================================
-- STAFFING_CALCULATED_COSTS
-- ============================================================================

CREATE POLICY policy_staffing_calculated_costs_platform_owner_all
    ON strategy.staffing_calculated_costs
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_staffing_calculated_costs_tenant_admin_all
    ON strategy.staffing_calculated_costs
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

CREATE POLICY policy_staffing_calculated_costs_business_profiles_select
    ON strategy.staffing_calculated_costs
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- STAFFING_ACTUALS
-- ============================================================================

CREATE POLICY policy_staffing_actuals_platform_owner_all
    ON strategy.staffing_actuals
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_staffing_actuals_tenant_admin_all
    ON strategy.staffing_actuals
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

CREATE POLICY policy_staffing_actuals_business_profiles_select
    ON strategy.staffing_actuals
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- AI_SUGGESTIONS
-- ============================================================================

CREATE POLICY policy_ai_suggestions_platform_owner_all
    ON strategy.ai_suggestions
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_ai_suggestions_tenant_admin_all
    ON strategy.ai_suggestions
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

CREATE POLICY policy_ai_suggestions_business_profiles_select
    ON strategy.ai_suggestions
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

CREATE POLICY policy_ai_suggestions_business_profiles_update
    ON strategy.ai_suggestions
    FOR UPDATE
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    );

-- ============================================================================
-- AI_SIMULATIONS
-- ============================================================================

CREATE POLICY policy_ai_simulations_platform_owner_all
    ON strategy.ai_simulations
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_ai_simulations_tenant_admin_all
    ON strategy.ai_simulations
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

CREATE POLICY policy_ai_simulations_business_profiles_select
    ON strategy.ai_simulations
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

CREATE POLICY policy_ai_simulations_business_profiles_insert
    ON strategy.ai_simulations
    FOR INSERT
    TO authenticated
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    );

-- ============================================================================
-- RISK_ALERTS
-- ============================================================================

CREATE POLICY policy_risk_alerts_platform_owner_all
    ON strategy.risk_alerts
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_risk_alerts_tenant_admin_all
    ON strategy.risk_alerts
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

CREATE POLICY policy_risk_alerts_business_profiles_select
    ON strategy.risk_alerts
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

CREATE POLICY policy_risk_alerts_business_profiles_update
    ON strategy.risk_alerts
    FOR UPDATE
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    );

-- ============================================================================
-- APPROVAL_WORKFLOWS
-- ============================================================================

CREATE POLICY policy_approval_workflows_platform_owner_all
    ON strategy.approval_workflows
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_approval_workflows_tenant_admin_all
    ON strategy.approval_workflows
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

CREATE POLICY policy_approval_workflows_business_profiles_select
    ON strategy.approval_workflows
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- APPROVAL_REQUESTS
-- ============================================================================

CREATE POLICY policy_approval_requests_platform_owner_all
    ON strategy.approval_requests
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_approval_requests_tenant_admin_all
    ON strategy.approval_requests
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

CREATE POLICY policy_approval_requests_business_profiles_select
    ON strategy.approval_requests
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

CREATE POLICY policy_approval_requests_business_profiles_update
    ON strategy.approval_requests
    FOR UPDATE
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    );

-- ============================================================================
-- APPROVAL_HISTORY
-- ============================================================================

CREATE POLICY policy_approval_history_platform_owner_all
    ON strategy.approval_history
    FOR SELECT
    TO authenticated
    USING (foundation.is_platform_owner());

CREATE POLICY policy_approval_history_tenant_admin_all
    ON strategy.approval_history
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('tenant_admin', 'auditor')
    );

CREATE POLICY policy_approval_history_system_insert
    ON strategy.approval_history
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- ============================================================================
-- EXECUTIVE_DASHBOARDS
-- ============================================================================

CREATE POLICY policy_executive_dashboards_platform_owner_all
    ON strategy.executive_dashboards
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_executive_dashboards_tenant_admin_all
    ON strategy.executive_dashboards
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

CREATE POLICY policy_executive_dashboards_business_profiles_select
    ON strategy.executive_dashboards
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- DASHBOARD_KPIS
-- ============================================================================

CREATE POLICY policy_dashboard_kpis_platform_owner_all
    ON strategy.dashboard_kpis
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_dashboard_kpis_tenant_admin_all
    ON strategy.dashboard_kpis
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

CREATE POLICY policy_dashboard_kpis_business_profiles_select
    ON strategy.dashboard_kpis
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- BUDGET_TEMPLATES
-- ============================================================================

CREATE POLICY policy_budget_templates_platform_owner_all
    ON strategy.budget_templates
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_budget_templates_tenant_admin_all
    ON strategy.budget_templates
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

CREATE POLICY policy_budget_templates_business_profiles_select
    ON strategy.budget_templates
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- STAFFING_TEMPLATES
-- ============================================================================

CREATE POLICY policy_staffing_templates_platform_owner_all
    ON strategy.staffing_templates
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_staffing_templates_tenant_admin_all
    ON strategy.staffing_templates
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

CREATE POLICY policy_staffing_templates_business_profiles_select
    ON strategy.staffing_templates
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

-- ============================================================================
-- EXPORT_JOBS
-- ============================================================================

CREATE POLICY policy_export_jobs_platform_owner_all
    ON strategy.export_jobs
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_export_jobs_tenant_admin_all
    ON strategy.export_jobs
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

CREATE POLICY policy_export_jobs_business_profiles_select
    ON strategy.export_jobs
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista', 'auditor')
    );

CREATE POLICY policy_export_jobs_business_profiles_insert
    ON strategy.export_jobs
    FOR INSERT
    TO authenticated
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'especialista')
    );
