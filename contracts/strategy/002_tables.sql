-- HUMANTRÍA — STRATEGY TABLES V1
-- Status: BLOQUEANTE
-- Escopo: Tabelas do produto Strategy (multi-tenant + RLS)

SET search_path TO strategy, core, foundation, public;

-- ============================================================================
-- A) OBJETIVOS & METAS (OKR/BSC)
-- ============================================================================

-- Objective Templates (templates de metodologia)
CREATE TABLE IF NOT EXISTS strategy.objective_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    methodology_type TEXT NOT NULL CHECK (methodology_type IN ('okr', 'bsc', 'smart', 'other')),
    structure JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    is_global BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE INDEX IF NOT EXISTS idx_objective_templates_tenant_id ON strategy.objective_templates(tenant_id);
CREATE INDEX IF NOT EXISTS idx_objective_templates_methodology ON strategy.objective_templates(methodology_type);

COMMENT ON TABLE strategy.objective_templates IS 'Templates de metodologia (OKR, BSC, SMART, etc)';
COMMENT ON COLUMN strategy.objective_templates.is_global IS 'TRUE = template global (tenant_id NULL), FALSE = template do tenant';

-- Objectives (objectives OKR ou objetivos BSC)
CREATE TABLE IF NOT EXISTS strategy.objectives (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    template_id UUID REFERENCES strategy.objective_templates(id) ON DELETE SET NULL,
    code TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    methodology_type TEXT NOT NULL CHECK (methodology_type IN ('okr', 'bsc', 'smart', 'other')),
    cycle_type TEXT NOT NULL CHECK (cycle_type IN ('annual', 'semiannual', 'quarterly', 'monthly')),
    cycle_start_date DATE NOT NULL,
    cycle_end_date DATE NOT NULL,
    owner_person_id UUID REFERENCES core.people(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'completed', 'cancelled')),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE INDEX IF NOT EXISTS idx_objectives_tenant_id ON strategy.objectives(tenant_id);
CREATE INDEX IF NOT EXISTS idx_objectives_template_id ON strategy.objectives(template_id);
CREATE INDEX IF NOT EXISTS idx_objectives_owner_person_id ON strategy.objectives(owner_person_id);
CREATE INDEX IF NOT EXISTS idx_objectives_cycle ON strategy.objectives(cycle_start_date, cycle_end_date);
CREATE INDEX IF NOT EXISTS idx_objectives_status ON strategy.objectives(status);

COMMENT ON TABLE strategy.objectives IS 'Objectives (OKR) ou Objetivos (BSC)';

-- Key Results (key results OKR ou indicadores BSC)
CREATE TABLE IF NOT EXISTS strategy.key_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    objective_id UUID NOT NULL REFERENCES strategy.objectives(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    metric_type TEXT,
    current_value NUMERIC,
    target_value NUMERIC,
    unit TEXT,
    owner_person_id UUID REFERENCES core.people(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'completed', 'cancelled')),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    UNIQUE(tenant_id, objective_id, code)
);

CREATE INDEX IF NOT EXISTS idx_key_results_tenant_id ON strategy.key_results(tenant_id);
CREATE INDEX IF NOT EXISTS idx_key_results_objective_id ON strategy.key_results(objective_id);
CREATE INDEX IF NOT EXISTS idx_key_results_owner_person_id ON strategy.key_results(owner_person_id);
CREATE INDEX IF NOT EXISTS idx_key_results_status ON strategy.key_results(status);

COMMENT ON TABLE strategy.key_results IS 'Key Results (OKR) ou Indicadores (BSC)';

-- Objective History (histórico de alterações)
CREATE TABLE IF NOT EXISTS strategy.objective_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    objective_id UUID NOT NULL REFERENCES strategy.objectives(id) ON DELETE CASCADE,
    version INTEGER NOT NULL,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    changed_by UUID,
    changes JSONB NOT NULL DEFAULT '{}'::jsonb,
    justification TEXT,
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_objective_history_tenant_id ON strategy.objective_history(tenant_id);
CREATE INDEX IF NOT EXISTS idx_objective_history_objective_id ON strategy.objective_history(objective_id);
CREATE INDEX IF NOT EXISTS idx_objective_history_version ON strategy.objective_history(objective_id, version);

COMMENT ON TABLE strategy.objective_history IS 'Histórico de alterações de objectives (versionamento)';

-- Objective Evidence (evidências e anexos)
CREATE TABLE IF NOT EXISTS strategy.objective_evidence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    objective_id UUID NOT NULL REFERENCES strategy.objectives(id) ON DELETE CASCADE,
    evidence_type TEXT NOT NULL CHECK (evidence_type IN ('document', 'link', 'attachment', 'note')),
    title TEXT NOT NULL,
    description TEXT,
    attachment_url TEXT,
    attachment_type TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID
);

CREATE INDEX IF NOT EXISTS idx_objective_evidence_tenant_id ON strategy.objective_evidence(tenant_id);
CREATE INDEX IF NOT EXISTS idx_objective_evidence_objective_id ON strategy.objective_evidence(objective_id);

COMMENT ON TABLE strategy.objective_evidence IS 'Evidências e anexos de objectives (imutável)';

-- ============================================================================
-- B) ORÇAMENTO (BUDGET)
-- ============================================================================

-- Budget Currencies (moedas suportadas)
CREATE TABLE IF NOT EXISTS strategy.budget_currencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    symbol TEXT,
    exchange_rate_to_base NUMERIC,
    is_active BOOLEAN DEFAULT TRUE,
    is_global BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, code)
);

CREATE INDEX IF NOT EXISTS idx_budget_currencies_tenant_id ON strategy.budget_currencies(tenant_id);

COMMENT ON TABLE strategy.budget_currencies IS 'Moedas suportadas (global ou tenant-specific)';
COMMENT ON COLUMN strategy.budget_currencies.is_global IS 'TRUE = moeda global (tenant_id NULL), FALSE = moeda do tenant';

-- Budget Versions (versões de orçamento: baseline, revisões)
CREATE TABLE IF NOT EXISTS strategy.budget_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    version_number INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'pending_approval', 'approved', 'rejected', 'archived')),
    baseline_version_id UUID REFERENCES strategy.budget_versions(id) ON DELETE SET NULL,
    approved_at TIMESTAMPTZ,
    approved_by UUID,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE INDEX IF NOT EXISTS idx_budget_versions_tenant_id ON strategy.budget_versions(tenant_id);
CREATE INDEX IF NOT EXISTS idx_budget_versions_baseline ON strategy.budget_versions(baseline_version_id);
CREATE INDEX IF NOT EXISTS idx_budget_versions_status ON strategy.budget_versions(status);

COMMENT ON TABLE strategy.budget_versions IS 'Versões de orçamento (baseline, revisões)';

-- Budget Items (itens de orçamento por org_unit/projeto/cost_center)
CREATE TABLE IF NOT EXISTS strategy.budget_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    budget_version_id UUID NOT NULL REFERENCES strategy.budget_versions(id) ON DELETE CASCADE,
    item_type TEXT NOT NULL CHECK (item_type IN ('org_unit', 'project', 'cost_center')),
    org_unit_id UUID REFERENCES core.org_units(id) ON DELETE SET NULL,
    project_id UUID,
    cost_center_id UUID REFERENCES core.cost_centers(id) ON DELETE SET NULL,
    category TEXT,
    amount_base_currency NUMERIC NOT NULL,
    currency_code TEXT NOT NULL,
    amount_original_currency NUMERIC NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

CREATE INDEX IF NOT EXISTS idx_budget_items_tenant_id ON strategy.budget_items(tenant_id);
CREATE INDEX IF NOT EXISTS idx_budget_items_budget_version_id ON strategy.budget_items(budget_version_id);
CREATE INDEX IF NOT EXISTS idx_budget_items_org_unit_id ON strategy.budget_items(org_unit_id);
CREATE INDEX IF NOT EXISTS idx_budget_items_cost_center_id ON strategy.budget_items(cost_center_id);
CREATE INDEX IF NOT EXISTS idx_budget_items_period ON strategy.budget_items(period_start, period_end);

COMMENT ON TABLE strategy.budget_items IS 'Itens de orçamento (por org_unit, projeto ou cost_center)';

-- Budget Approvals (aprovações de orçamento)
CREATE TABLE IF NOT EXISTS strategy.budget_approvals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    budget_version_id UUID NOT NULL REFERENCES strategy.budget_versions(id) ON DELETE CASCADE,
    approver_person_id UUID REFERENCES core.people(id) ON DELETE SET NULL,
    approval_level INTEGER NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'approved', 'rejected')),
    approved_at TIMESTAMPTZ,
    comments TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_budget_approvals_tenant_id ON strategy.budget_approvals(tenant_id);
CREATE INDEX IF NOT EXISTS idx_budget_approvals_budget_version_id ON strategy.budget_approvals(budget_version_id);
CREATE INDEX IF NOT EXISTS idx_budget_approvals_approver ON strategy.budget_approvals(approver_person_id);

COMMENT ON TABLE strategy.budget_approvals IS 'Aprovações de orçamento (workflow)';

-- Budget Actuals (realizado vs previsto)
CREATE TABLE IF NOT EXISTS strategy.budget_actuals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    budget_item_id UUID NOT NULL REFERENCES strategy.budget_items(id) ON DELETE CASCADE,
    period DATE NOT NULL,
    actual_amount_base_currency NUMERIC NOT NULL,
    variance_amount NUMERIC,
    variance_percentage NUMERIC,
    source_system TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(budget_item_id, period)
);

CREATE INDEX IF NOT EXISTS idx_budget_actuals_tenant_id ON strategy.budget_actuals(tenant_id);
CREATE INDEX IF NOT EXISTS idx_budget_actuals_budget_item_id ON strategy.budget_actuals(budget_item_id);
CREATE INDEX IF NOT EXISTS idx_budget_actuals_period ON strategy.budget_actuals(period);

COMMENT ON TABLE strategy.budget_actuals IS 'Realizado vs Previsto (quando disponível de sistemas externos)';

-- ============================================================================
-- C) STAFFING PLAN
-- ============================================================================

-- Staffing Plans (planos de staffing com cenários)
CREATE TABLE IF NOT EXISTS strategy.staffing_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    scenario_type TEXT NOT NULL CHECK (scenario_type IN ('best', 'base', 'worst')),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'pending_approval', 'approved', 'rejected', 'archived')),
    approved_at TIMESTAMPTZ,
    approved_by UUID,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE INDEX IF NOT EXISTS idx_staffing_plans_tenant_id ON strategy.staffing_plans(tenant_id);
CREATE INDEX IF NOT EXISTS idx_staffing_plans_period ON strategy.staffing_plans(period_start, period_end);
CREATE INDEX IF NOT EXISTS idx_staffing_plans_status ON strategy.staffing_plans(status);

COMMENT ON TABLE strategy.staffing_plans IS 'Planos de staffing (com cenários best/base/worst)';

-- Staffing Demands (demanda de pessoas por período)
CREATE TABLE IF NOT EXISTS strategy.staffing_demands (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    staffing_plan_id UUID NOT NULL REFERENCES strategy.staffing_plans(id) ON DELETE CASCADE,
    org_unit_id UUID NOT NULL REFERENCES core.org_units(id) ON DELETE CASCADE,
    job_id UUID REFERENCES core.jobs(id) ON DELETE SET NULL,
    job_level_id UUID REFERENCES core.job_levels(id) ON DELETE SET NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    headcount NUMERIC NOT NULL,
    cost_center_id UUID REFERENCES core.cost_centers(id) ON DELETE SET NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

CREATE INDEX IF NOT EXISTS idx_staffing_demands_tenant_id ON strategy.staffing_demands(tenant_id);
CREATE INDEX IF NOT EXISTS idx_staffing_demands_staffing_plan_id ON strategy.staffing_demands(staffing_plan_id);
CREATE INDEX IF NOT EXISTS idx_staffing_demands_org_unit_id ON strategy.staffing_demands(org_unit_id);
CREATE INDEX IF NOT EXISTS idx_staffing_demands_job_id ON strategy.staffing_demands(job_id);
CREATE INDEX IF NOT EXISTS idx_staffing_demands_period ON strategy.staffing_demands(period_start, period_end);

COMMENT ON TABLE strategy.staffing_demands IS 'Demanda de pessoas por período (org_unit, job, level)';

-- Staffing Calculated Costs (custos calculados: headcount × economic_parameter)
CREATE TABLE IF NOT EXISTS strategy.staffing_calculated_costs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    staffing_demand_id UUID NOT NULL REFERENCES strategy.staffing_demands(id) ON DELETE CASCADE,
    calculated_cost_base_currency NUMERIC NOT NULL,
    calculated_cost_original_currency NUMERIC,
    currency_code TEXT,
    calculation_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_staffing_calculated_costs_tenant_id ON strategy.staffing_calculated_costs(tenant_id);
CREATE INDEX IF NOT EXISTS idx_staffing_calculated_costs_staffing_demand_id ON strategy.staffing_calculated_costs(staffing_demand_id);

COMMENT ON TABLE strategy.staffing_calculated_costs IS 'Custos calculados (headcount × economic_parameter do Core)';

-- Staffing Actuals (real vs planejado)
CREATE TABLE IF NOT EXISTS strategy.staffing_actuals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    staffing_demand_id UUID NOT NULL REFERENCES strategy.staffing_demands(id) ON DELETE CASCADE,
    period DATE NOT NULL,
    actual_headcount NUMERIC,
    actual_cost_base_currency NUMERIC,
    variance_headcount NUMERIC,
    variance_cost NUMERIC,
    source_system TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(staffing_demand_id, period)
);

CREATE INDEX IF NOT EXISTS idx_staffing_actuals_tenant_id ON strategy.staffing_actuals(tenant_id);
CREATE INDEX IF NOT EXISTS idx_staffing_actuals_staffing_demand_id ON strategy.staffing_actuals(staffing_demand_id);
CREATE INDEX IF NOT EXISTS idx_staffing_actuals_period ON strategy.staffing_actuals(period);

COMMENT ON TABLE strategy.staffing_actuals IS 'Real vs Planejado (quando disponível de sistemas externos)';

-- ============================================================================
-- D) SIMULAÇÕES & IA
-- ============================================================================

-- AI Suggestions (sugestões geradas por IA)
CREATE TABLE IF NOT EXISTS strategy.ai_suggestions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    suggestion_type TEXT NOT NULL CHECK (suggestion_type IN ('goal', 'budget', 'staffing', 'other')),
    entity_type TEXT NOT NULL,
    entity_id UUID,
    suggestion_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    explanation TEXT NOT NULL,
    confidence_score NUMERIC CHECK (confidence_score >= 0 AND confidence_score <= 1),
    model_provider TEXT,
    model_name TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    approved_by UUID,
    approved_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_suggestions_tenant_id ON strategy.ai_suggestions(tenant_id);
CREATE INDEX IF NOT EXISTS idx_ai_suggestions_entity ON strategy.ai_suggestions(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_ai_suggestions_status ON strategy.ai_suggestions(status);

COMMENT ON TABLE strategy.ai_suggestions IS 'Sugestões geradas por IA (com explicabilidade e aprovação humana)';

-- AI Simulations (simulações de cenários)
CREATE TABLE IF NOT EXISTS strategy.ai_simulations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    simulation_type TEXT NOT NULL,
    input_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    output_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    model_provider TEXT,
    model_name TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID
);

CREATE INDEX IF NOT EXISTS idx_ai_simulations_tenant_id ON strategy.ai_simulations(tenant_id);
CREATE INDEX IF NOT EXISTS idx_ai_simulations_type ON strategy.ai_simulations(simulation_type);

COMMENT ON TABLE strategy.ai_simulations IS 'Simulações de cenários geradas por IA';

-- Risk Alerts (alertas de risco detectados)
CREATE TABLE IF NOT EXISTS strategy.risk_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    alert_type TEXT NOT NULL,
    severity TEXT NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    title TEXT NOT NULL,
    description TEXT,
    entity_type TEXT,
    entity_id UUID,
    detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ,
    resolved_by UUID,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_risk_alerts_tenant_id ON strategy.risk_alerts(tenant_id);
CREATE INDEX IF NOT EXISTS idx_risk_alerts_entity ON strategy.risk_alerts(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_risk_alerts_severity ON strategy.risk_alerts(severity);
CREATE INDEX IF NOT EXISTS idx_risk_alerts_resolved ON strategy.risk_alerts(resolved_at);

COMMENT ON TABLE strategy.risk_alerts IS 'Alertas de risco detectados (por IA ou regras)';

-- ============================================================================
-- E) WORKFLOWS DE APROVAÇÃO
-- ============================================================================

-- Approval Workflows (definição de workflows)
CREATE TABLE IF NOT EXISTS strategy.approval_workflows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    entity_type TEXT NOT NULL,
    approval_levels JSONB NOT NULL DEFAULT '[]'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE INDEX IF NOT EXISTS idx_approval_workflows_tenant_id ON strategy.approval_workflows(tenant_id);
CREATE INDEX IF NOT EXISTS idx_approval_workflows_entity_type ON strategy.approval_workflows(entity_type);

COMMENT ON TABLE strategy.approval_workflows IS 'Definição de workflows de aprovação (genérico e reusável)';

-- Approval Requests (solicitações de aprovação)
CREATE TABLE IF NOT EXISTS strategy.approval_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    workflow_id UUID NOT NULL REFERENCES strategy.approval_workflows(id) ON DELETE CASCADE,
    entity_type TEXT NOT NULL,
    entity_id UUID NOT NULL,
    requested_by UUID,
    requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    current_level INTEGER NOT NULL DEFAULT 1,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')),
    approved_at TIMESTAMPTZ,
    rejected_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_approval_requests_tenant_id ON strategy.approval_requests(tenant_id);
CREATE INDEX IF NOT EXISTS idx_approval_requests_workflow_id ON strategy.approval_requests(workflow_id);
CREATE INDEX IF NOT EXISTS idx_approval_requests_entity ON strategy.approval_requests(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_approval_requests_status ON strategy.approval_requests(status);

COMMENT ON TABLE strategy.approval_requests IS 'Solicitações de aprovação (workflow)';

-- Approval History (histórico de aprovações)
CREATE TABLE IF NOT EXISTS strategy.approval_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    approval_request_id UUID NOT NULL REFERENCES strategy.approval_requests(id) ON DELETE CASCADE,
    approver_person_id UUID REFERENCES core.people(id) ON DELETE SET NULL,
    approval_level INTEGER NOT NULL,
    action TEXT NOT NULL CHECK (action IN ('approved', 'rejected')),
    comments TEXT,
    approved_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_approval_history_tenant_id ON strategy.approval_history(tenant_id);
CREATE INDEX IF NOT EXISTS idx_approval_history_approval_request_id ON strategy.approval_history(approval_request_id);
CREATE INDEX IF NOT EXISTS idx_approval_history_approver ON strategy.approval_history(approver_person_id);

COMMENT ON TABLE strategy.approval_history IS 'Histórico de aprovações (auditoria)';

-- ============================================================================
-- F) DASHBOARDS EXECUTIVOS
-- ============================================================================

-- Executive Dashboards (configurações de dashboards)
CREATE TABLE IF NOT EXISTS strategy.executive_dashboards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    dashboard_code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    target_role TEXT,
    widget_config JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    UNIQUE(tenant_id, dashboard_code)
);

CREATE INDEX IF NOT EXISTS idx_executive_dashboards_tenant_id ON strategy.executive_dashboards(tenant_id);

COMMENT ON TABLE strategy.executive_dashboards IS 'Configurações de dashboards executivos (config/metadata)';

-- Dashboard KPIs (KPIs estratégicos calculados)
CREATE TABLE IF NOT EXISTS strategy.dashboard_kpis (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    kpi_code TEXT NOT NULL,
    kpi_name TEXT NOT NULL,
    calculation_rule JSONB DEFAULT '{}'::jsonb,
    current_value NUMERIC,
    target_value NUMERIC,
    period DATE NOT NULL,
    calculated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, kpi_code, period)
);

CREATE INDEX IF NOT EXISTS idx_dashboard_kpis_tenant_id ON strategy.dashboard_kpis(tenant_id);
CREATE INDEX IF NOT EXISTS idx_dashboard_kpis_period ON strategy.dashboard_kpis(period);

COMMENT ON TABLE strategy.dashboard_kpis IS 'KPIs estratégicos calculados (por período)';

-- ============================================================================
-- G) TEMPLATES
-- ============================================================================

-- Budget Templates (templates de orçamento)
CREATE TABLE IF NOT EXISTS strategy.budget_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    structure JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE INDEX IF NOT EXISTS idx_budget_templates_tenant_id ON strategy.budget_templates(tenant_id);

COMMENT ON TABLE strategy.budget_templates IS 'Templates de orçamento';

-- Staffing Templates (templates de staffing)
CREATE TABLE IF NOT EXISTS strategy.staffing_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    structure JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE INDEX IF NOT EXISTS idx_staffing_templates_tenant_id ON strategy.staffing_templates(tenant_id);

COMMENT ON TABLE strategy.staffing_templates IS 'Templates de staffing';

-- ============================================================================
-- H) IMPORT/EXPORT
-- ============================================================================

-- Export Jobs (trabalhos de exportação)
CREATE TABLE IF NOT EXISTS strategy.export_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    export_type TEXT NOT NULL,
    format TEXT NOT NULL CHECK (format IN ('excel', 'pdf', 'csv', 'json')),
    filters JSONB DEFAULT '{}'::jsonb,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'running', 'completed', 'failed')),
    file_url TEXT,
    created_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    error_message TEXT,
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_export_jobs_tenant_id ON strategy.export_jobs(tenant_id);
CREATE INDEX IF NOT EXISTS idx_export_jobs_status ON strategy.export_jobs(status);

COMMENT ON TABLE strategy.export_jobs IS 'Trabalhos de exportação (import usa core.import_jobs com import_type=''strategy'')';

-- ============================================================================
-- TRIGGERS: updated_at automático
-- ============================================================================

CREATE OR REPLACE FUNCTION strategy.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger updated_at em todas as tabelas com updated_at
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT table_name 
        FROM information_schema.columns 
        WHERE table_schema = 'strategy' 
        AND column_name = 'updated_at'
        AND table_name NOT IN ('objective_evidence', 'budget_actuals', 'staffing_calculated_costs', 'staffing_actuals', 'ai_suggestions', 'ai_simulations', 'risk_alerts', 'approval_history', 'dashboard_kpis', 'export_jobs')
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS trigger_%s_updated_at ON strategy.%I', r.table_name, r.table_name);
        EXECUTE format('CREATE TRIGGER trigger_%s_updated_at BEFORE UPDATE ON strategy.%I FOR EACH ROW EXECUTE FUNCTION strategy.update_updated_at()', r.table_name, r.table_name);
    END LOOP;
END;
$$;
