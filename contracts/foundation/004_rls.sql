-- HUMANTRÍA — FOUNDATION RLS V1
-- Status: BLOQUEANTE
-- Escopo: Row Level Security para Platform Owner, Tenant Admin e perfis de negócio

SET search_path TO foundation, public;

-- ============================================================================
-- HABILITAR RLS
-- ============================================================================

-- Tenancy
ALTER TABLE foundation.tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.tenant_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.tenant_environments ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.tenant_status_history ENABLE ROW LEVEL SECURITY;

-- IAM
ALTER TABLE foundation.memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.user_role_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.session_revocations ENABLE ROW LEVEL SECURITY;

-- Tenant Settings
ALTER TABLE foundation.tenant_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.tenant_feature_flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.tenant_quotas ENABLE ROW LEVEL SECURITY;

-- LGPD/Privacy
ALTER TABLE foundation.data_purposes ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.legal_bases ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.consents ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.retention_policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.legal_holds ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.anonymization_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.sensitive_access_audit ENABLE ROW LEVEL SECURITY;

-- Audit/Events
ALTER TABLE foundation.audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.audit_log_functional ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.events_outbox ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.event_consumers ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.correlation_context ENABLE ROW LEVEL SECURITY;

-- Billing
ALTER TABLE foundation.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.usage_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.contract_dates ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.service_orders ENABLE ROW LEVEL SECURITY;

-- AI Governance
ALTER TABLE foundation.tenant_ai_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.ai_usage_policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.ai_use_cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.fairness_constraints ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.ai_audit_log ENABLE ROW LEVEL SECURITY;

-- Templates
ALTER TABLE foundation.template_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.bootstrap_runs ENABLE ROW LEVEL SECURITY;

-- POC (Platform Owner Console) - sem RLS ou apenas Platform Owner
ALTER TABLE foundation.platform_incidents ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.platform_ops_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE foundation.platform_audit ENABLE ROW LEVEL SECURITY;

-- Catálogos globais NÃO têm RLS (são universais)
-- foundation.roles, foundation.permissions, foundation.role_permissions
-- foundation.feature_flags, foundation.quotas
-- foundation.plans, foundation.addons, foundation.service_catalog
-- foundation.ai_providers, foundation.ai_models_registry
-- foundation.templates, foundation.template_versions

-- ============================================================================
-- TENANTS
-- ============================================================================

-- Platform Owner: visão soberana (todos os tenants)
CREATE POLICY policy_tenants_platform_owner_all
    ON foundation.tenants
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

-- Tenant Admin: apenas seu próprio tenant
CREATE POLICY policy_tenants_tenant_admin_own
    ON foundation.tenants
    FOR SELECT
    TO authenticated
    USING (
        id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

-- ============================================================================
-- TENANT_PROFILES
-- ============================================================================

CREATE POLICY policy_tenant_profiles_platform_owner_all
    ON foundation.tenant_profiles
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_tenant_profiles_tenant_admin_own
    ON foundation.tenant_profiles
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

-- ============================================================================
-- TENANT_ENVIRONMENTS
-- ============================================================================

CREATE POLICY policy_tenant_environments_platform_owner_all
    ON foundation.tenant_environments
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_tenant_environments_tenant_admin_own
    ON foundation.tenant_environments
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

-- ============================================================================
-- TENANT_STATUS_HISTORY
-- ============================================================================

CREATE POLICY policy_tenant_status_history_platform_owner_all
    ON foundation.tenant_status_history
    FOR SELECT
    TO authenticated
    USING (foundation.is_platform_owner());

CREATE POLICY policy_tenant_status_history_tenant_admin_own
    ON foundation.tenant_status_history
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_tenant_status_history_system_insert
    ON foundation.tenant_status_history
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- ============================================================================
-- MEMBERSHIPS
-- ============================================================================

CREATE POLICY policy_memberships_platform_owner_all
    ON foundation.memberships
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_memberships_tenant_admin_own
    ON foundation.memberships
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

-- ============================================================================
-- USER_ROLE_ASSIGNMENTS
-- ============================================================================

CREATE POLICY policy_user_role_assignments_platform_owner_all
    ON foundation.user_role_assignments
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_user_role_assignments_tenant_admin_own
    ON foundation.user_role_assignments
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

-- ============================================================================
-- SESSION_REVOCATIONS
-- ============================================================================

CREATE POLICY policy_session_revocations_platform_owner_all
    ON foundation.session_revocations
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_session_revocations_tenant_admin_own
    ON foundation.session_revocations
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

-- ============================================================================
-- TENANT_SETTINGS
-- ============================================================================

CREATE POLICY policy_tenant_settings_platform_owner_all
    ON foundation.tenant_settings
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_tenant_settings_tenant_admin_own
    ON foundation.tenant_settings
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

-- ============================================================================
-- TENANT_FEATURE_FLAGS
-- ============================================================================

CREATE POLICY policy_tenant_feature_flags_platform_owner_all
    ON foundation.tenant_feature_flags
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_tenant_feature_flags_tenant_admin_own
    ON foundation.tenant_feature_flags
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

-- ============================================================================
-- TENANT_QUOTAS
-- ============================================================================

CREATE POLICY policy_tenant_quotas_platform_owner_all
    ON foundation.tenant_quotas
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_tenant_quotas_tenant_admin_own
    ON foundation.tenant_quotas
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

-- ============================================================================
-- LGPD/PRIVACY
-- ============================================================================

CREATE POLICY policy_data_purposes_platform_owner_all
    ON foundation.data_purposes
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_data_purposes_tenant_admin_own
    ON foundation.data_purposes
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

CREATE POLICY policy_legal_bases_platform_owner_all
    ON foundation.legal_bases
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_legal_bases_tenant_admin_own
    ON foundation.legal_bases
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

CREATE POLICY policy_consents_platform_owner_all
    ON foundation.consents
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_consents_tenant_admin_own
    ON foundation.consents
    FOR ALL
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('tenant_admin', 'auditor')
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_retention_policies_platform_owner_all
    ON foundation.retention_policies
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_retention_policies_tenant_admin_own
    ON foundation.retention_policies
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

CREATE POLICY policy_legal_holds_platform_owner_all
    ON foundation.legal_holds
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_legal_holds_tenant_admin_own
    ON foundation.legal_holds
    FOR ALL
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('tenant_admin', 'auditor')
    )
    WITH CHECK (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_anonymization_requests_platform_owner_all
    ON foundation.anonymization_requests
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_anonymization_requests_tenant_admin_own
    ON foundation.anonymization_requests
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_sensitive_access_audit_platform_owner_all
    ON foundation.sensitive_access_audit
    FOR SELECT
    TO authenticated
    USING (foundation.is_platform_owner());

CREATE POLICY policy_sensitive_access_audit_tenant_admin_own
    ON foundation.sensitive_access_audit
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('tenant_admin', 'auditor')
    );

CREATE POLICY policy_sensitive_access_audit_system_insert
    ON foundation.sensitive_access_audit
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- ============================================================================
-- AUDIT_LOG
-- ============================================================================

-- Platform Owner: visão soberana (todos os tenants)
CREATE POLICY policy_audit_log_platform_owner_all
    ON foundation.audit_log
    FOR SELECT
    TO authenticated
    USING (foundation.is_platform_owner());

-- Tenant Admin: apenas logs do seu tenant
CREATE POLICY policy_audit_log_tenant_admin_own
    ON foundation.audit_log
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('tenant_admin', 'auditor')
    );

-- Perfis de negócio: apenas logs relacionados às suas entidades (via metadata)
CREATE POLICY policy_audit_log_business_profiles
    ON foundation.audit_log
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista')
    );

-- Sistema pode inserir logs (via trigger)
CREATE POLICY policy_audit_log_system_insert
    ON foundation.audit_log
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- ============================================================================
-- AUDIT_LOG_FUNCTIONAL
-- ============================================================================

-- Platform Owner: visão soberana
CREATE POLICY policy_audit_log_functional_platform_owner_all
    ON foundation.audit_log_functional
    FOR SELECT
    TO authenticated
    USING (foundation.is_platform_owner());

-- Tenant Admin e Auditor: logs do seu tenant
CREATE POLICY policy_audit_log_functional_tenant_admin_own
    ON foundation.audit_log_functional
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('tenant_admin', 'auditor')
    );

-- Perfis de negócio: apenas decisões relacionadas (via entity_type/entity_id)
CREATE POLICY policy_audit_log_functional_business_profiles
    ON foundation.audit_log_functional
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('gestor', 'colaborador', 'especialista')
    );

-- Sistema pode inserir logs funcionais
CREATE POLICY policy_audit_log_functional_system_insert
    ON foundation.audit_log_functional
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- ============================================================================
-- EVENTS_OUTBOX
-- ============================================================================

-- Platform Owner: visão soberana
CREATE POLICY policy_events_outbox_platform_owner_all
    ON foundation.events_outbox
    FOR SELECT
    TO authenticated
    USING (foundation.is_platform_owner());

-- Tenant Admin: eventos do seu tenant
CREATE POLICY policy_events_outbox_tenant_admin_own
    ON foundation.events_outbox
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

-- Sistema pode inserir eventos
CREATE POLICY policy_events_outbox_system_insert
    ON foundation.events_outbox
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Sistema pode atualizar status (processamento)
CREATE POLICY policy_events_outbox_system_update
    ON foundation.events_outbox
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- EVENT_CONSUMERS
-- ============================================================================

-- Platform Owner: visão soberana
CREATE POLICY policy_event_consumers_platform_owner_all
    ON foundation.event_consumers
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

-- Sistema pode gerenciar consumers
CREATE POLICY policy_event_consumers_system_all
    ON foundation.event_consumers
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- CORRELATION_CONTEXT
-- ============================================================================

CREATE POLICY policy_correlation_context_platform_owner_all
    ON foundation.correlation_context
    FOR SELECT
    TO authenticated
    USING (foundation.is_platform_owner());

CREATE POLICY policy_correlation_context_tenant_admin_own
    ON foundation.correlation_context
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_correlation_context_system_insert
    ON foundation.correlation_context
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- ============================================================================
-- BILLING
-- ============================================================================

CREATE POLICY policy_subscriptions_platform_owner_all
    ON foundation.subscriptions
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_subscriptions_tenant_admin_own
    ON foundation.subscriptions
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_usage_metrics_platform_owner_all
    ON foundation.usage_metrics
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_usage_metrics_tenant_admin_own
    ON foundation.usage_metrics
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_usage_metrics_system_insert
    ON foundation.usage_metrics
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY policy_contract_dates_platform_owner_all
    ON foundation.contract_dates
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_contract_dates_tenant_admin_own
    ON foundation.contract_dates
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_service_orders_platform_owner_all
    ON foundation.service_orders
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_service_orders_tenant_admin_own
    ON foundation.service_orders
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

-- ============================================================================
-- AI GOVERNANCE
-- ============================================================================

CREATE POLICY policy_tenant_ai_connections_platform_owner_all
    ON foundation.tenant_ai_connections
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_tenant_ai_connections_tenant_admin_own
    ON foundation.tenant_ai_connections
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

CREATE POLICY policy_ai_usage_policies_platform_owner_all
    ON foundation.ai_usage_policies
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_ai_usage_policies_tenant_admin_own
    ON foundation.ai_usage_policies
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

CREATE POLICY policy_ai_use_cases_platform_owner_all
    ON foundation.ai_use_cases
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_ai_use_cases_tenant_admin_own
    ON foundation.ai_use_cases
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

CREATE POLICY policy_fairness_constraints_platform_owner_all
    ON foundation.fairness_constraints
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_fairness_constraints_tenant_admin_own
    ON foundation.fairness_constraints
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

CREATE POLICY policy_ai_audit_log_platform_owner_all
    ON foundation.ai_audit_log
    FOR SELECT
    TO authenticated
    USING (foundation.is_platform_owner());

CREATE POLICY policy_ai_audit_log_tenant_admin_own
    ON foundation.ai_audit_log
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' IN ('tenant_admin', 'auditor')
    );

CREATE POLICY policy_ai_audit_log_system_insert
    ON foundation.ai_audit_log
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- ============================================================================
-- TEMPLATES
-- ============================================================================

CREATE POLICY policy_template_assignments_platform_owner_all
    ON foundation.template_assignments
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_template_assignments_tenant_admin_own
    ON foundation.template_assignments
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_bootstrap_runs_platform_owner_all
    ON foundation.bootstrap_runs
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_bootstrap_runs_tenant_admin_own
    ON foundation.bootstrap_runs
    FOR SELECT
    TO authenticated
    USING (
        tenant_id = foundation.get_current_tenant_id()
        AND current_setting('request.jwt.claims', true)::json->>'role' = 'tenant_admin'
    );

CREATE POLICY policy_bootstrap_runs_system_all
    ON foundation.bootstrap_runs
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- PLATFORM OWNER CONSOLE (POC)
-- ============================================================================

-- Platform Owner apenas
CREATE POLICY policy_platform_incidents_platform_owner_only
    ON foundation.platform_incidents
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_platform_ops_actions_platform_owner_only
    ON foundation.platform_ops_actions
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

CREATE POLICY policy_platform_audit_platform_owner_only
    ON foundation.platform_audit
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());
