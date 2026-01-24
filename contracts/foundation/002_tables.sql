-- HUMANTRÍA — FOUNDATION TABLES V1
-- Status: BLOQUEANTE
-- Escopo: Tabelas de infraestrutura transversal (multi-tenant + RLS)

SET search_path TO foundation, public;

-- ============================================================================
-- A) TENANCY & ONBOARDING
-- ============================================================================

-- Tenants (organizações/clientes)
CREATE TABLE IF NOT EXISTS foundation.tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'archived')),
    plan_id TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

COMMENT ON TABLE foundation.tenants IS 'Organizações/clientes da plataforma';
COMMENT ON COLUMN foundation.tenants.slug IS 'Identificador único do tenant (kebab-case)';

-- Tenant Profiles (dados de perfil do tenant)
CREATE TABLE IF NOT EXISTS foundation.tenant_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    industry_vertical TEXT,
    size_band TEXT CHECK (size_band IN ('startup', 'small', 'medium', 'large', 'enterprise')),
    operating_model TEXT,
    region_scope TEXT,
    country TEXT,
    primary_locale TEXT DEFAULT 'pt-BR',
    base_currency TEXT DEFAULT 'BRL',
    legal_model TEXT,
    headcount_band TEXT CHECK (headcount_band IN ('1-10', '11-50', '51-200', '201-1000', '1000+')),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id)
);

COMMENT ON TABLE foundation.tenant_profiles IS 'Perfil detalhado do tenant (industry, size, locale, currency, etc)';

-- Tenant Environments (demo/trial/prod + flags)
CREATE TABLE IF NOT EXISTS foundation.tenant_environments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    environment TEXT NOT NULL CHECK (environment IN ('demo', 'trial', 'prod')),
    is_demo BOOLEAN DEFAULT FALSE,
    is_trial BOOLEAN DEFAULT FALSE,
    is_prod BOOLEAN DEFAULT FALSE,
    trial_expires_at TIMESTAMPTZ,
    flags JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, environment)
);

COMMENT ON TABLE foundation.tenant_environments IS 'Ambientes do tenant (demo/trial/prod) com flags específicas';

-- Tenant Status History (auditoria de mudanças de status)
CREATE TABLE IF NOT EXISTS foundation.tenant_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    old_status TEXT,
    new_status TEXT NOT NULL,
    reason TEXT,
    changed_by UUID,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

COMMENT ON TABLE foundation.tenant_status_history IS 'Histórico de mudanças de status do tenant (auditoria)';

-- ============================================================================
-- B) IAM (Identity & Access Management)
-- ============================================================================

-- Memberships (user ↔ tenant)
CREATE TABLE IF NOT EXISTS foundation.memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    left_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, user_id)
);

COMMENT ON TABLE foundation.memberships IS 'Associação usuário ↔ tenant (multi-tenant membership)';

-- Roles (catálogo canônico)
CREATE TABLE IF NOT EXISTS foundation.roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    is_system BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.roles IS 'Catálogo canônico de roles (platform_owner, tenant_admin, gestor, colaborador, etc)';

-- Permissions (catálogo)
CREATE TABLE IF NOT EXISTS foundation.permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    resource_type TEXT,
    action TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.permissions IS 'Catálogo de permissões (resource + action)';

-- Role Permissions (associação role ↔ permission)
CREATE TABLE IF NOT EXISTS foundation.role_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id UUID NOT NULL REFERENCES foundation.roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES foundation.permissions(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(role_id, permission_id)
);

COMMENT ON TABLE foundation.role_permissions IS 'Associação role ↔ permission';

-- User Role Assignments (usuário tem role em tenant)
CREATE TABLE IF NOT EXISTS foundation.user_role_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    role_id UUID NOT NULL REFERENCES foundation.roles(id) ON DELETE CASCADE,
    assigned_by UUID,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    revoked_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.user_role_assignments IS 'Atribuição de role a usuário em tenant específico';

-- Session Revocations (revogação de sessões)
CREATE TABLE IF NOT EXISTS foundation.session_revocations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    user_id UUID,
    session_id TEXT,
    revoked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reason TEXT,
    revoked_by UUID,
    metadata JSONB DEFAULT '{}'::jsonb
);

COMMENT ON TABLE foundation.session_revocations IS 'Registro de revogação de sessões (logout forçado, segurança)';

-- ============================================================================
-- C) TENANT SETTINGS
-- ============================================================================

-- Tenant Settings (timezone, locale, base_currency, formats)
CREATE TABLE IF NOT EXISTS foundation.tenant_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    timezone TEXT DEFAULT 'America/Sao_Paulo',
    locale TEXT DEFAULT 'pt-BR',
    base_currency TEXT DEFAULT 'BRL',
    date_format TEXT DEFAULT 'DD/MM/YYYY',
    time_format TEXT DEFAULT 'HH:mm',
    number_format JSONB DEFAULT '{"decimal": ",", "thousands": "."}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id)
);

COMMENT ON TABLE foundation.tenant_settings IS 'Configurações do tenant (timezone, locale, currency, formats)';

-- Feature Flags (catálogo global)
CREATE TABLE IF NOT EXISTS foundation.feature_flags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    default_value BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.feature_flags IS 'Catálogo global de feature flags';

-- Tenant Feature Flags (override por tenant)
CREATE TABLE IF NOT EXISTS foundation.tenant_feature_flags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    feature_flag_id UUID NOT NULL REFERENCES foundation.feature_flags(id) ON DELETE CASCADE,
    value BOOLEAN NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, feature_flag_id)
);

COMMENT ON TABLE foundation.tenant_feature_flags IS 'Override de feature flags por tenant';

-- Quotas (catálogo global)
CREATE TABLE IF NOT EXISTS foundation.quotas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    unit TEXT,
    default_value NUMERIC,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.quotas IS 'Catálogo global de quotas';

-- Tenant Quotas (override por tenant)
CREATE TABLE IF NOT EXISTS foundation.tenant_quotas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    quota_id UUID NOT NULL REFERENCES foundation.quotas(id) ON DELETE CASCADE,
    value NUMERIC NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, quota_id)
);

COMMENT ON TABLE foundation.tenant_quotas IS 'Override de quotas por tenant';

-- ============================================================================
-- D) LGPD/PRIVACY (estrutural, registro governado)
-- ============================================================================

-- Data Purposes (finalidades de uso de dados)
CREATE TABLE IF NOT EXISTS foundation.data_purposes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    legal_basis_id UUID,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, code)
);

COMMENT ON TABLE foundation.data_purposes IS 'Finalidades de uso de dados (LGPD)';

-- Legal Bases (bases legais LGPD)
CREATE TABLE IF NOT EXISTS foundation.legal_bases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    article TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, code)
);

COMMENT ON TABLE foundation.legal_bases IS 'Bases legais LGPD (consentimento, execução de contrato, etc)';

-- Consents (status, dates, version)
CREATE TABLE IF NOT EXISTS foundation.consents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    data_purpose_id UUID NOT NULL REFERENCES foundation.data_purposes(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('granted', 'denied', 'withdrawn', 'pending')),
    granted_at TIMESTAMPTZ,
    withdrawn_at TIMESTAMPTZ,
    version TEXT NOT NULL DEFAULT '1.0',
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.consents IS 'Consentimentos LGPD (status, datas, versão)';

-- Retention Policies (registro)
CREATE TABLE IF NOT EXISTS foundation.retention_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    entity_type TEXT NOT NULL,
    retention_period_days INTEGER NOT NULL,
    auto_delete BOOLEAN DEFAULT FALSE,
    legal_basis_id UUID REFERENCES foundation.legal_bases(id),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.retention_policies IS 'Políticas de retenção de dados (LGPD)';

-- Legal Holds (registro)
CREATE TABLE IF NOT EXISTS foundation.legal_holds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    reason TEXT NOT NULL,
    placed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    released_at TIMESTAMPTZ,
    placed_by UUID,
    released_by UUID,
    metadata JSONB DEFAULT '{}'::jsonb
);

COMMENT ON TABLE foundation.legal_holds IS 'Bloqueios legais (preservação de dados para litígio)';

-- Anonymization Requests (fila)
CREATE TABLE IF NOT EXISTS foundation.anonymization_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    error_message TEXT,
    metadata JSONB DEFAULT '{}'::jsonb
);

COMMENT ON TABLE foundation.anonymization_requests IS 'Fila de solicitações de anonimização (LGPD)';

-- Sensitive Access Audit (registro)
CREATE TABLE IF NOT EXISTS foundation.sensitive_access_audit (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    resource_type TEXT NOT NULL,
    resource_id UUID,
    access_type TEXT NOT NULL,
    accessed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT,
    metadata JSONB DEFAULT '{}'::jsonb
);

COMMENT ON TABLE foundation.sensitive_access_audit IS 'Auditoria de acesso a dados sensíveis (LGPD)';

-- ============================================================================
-- E) AUDIT / EVIDENCE / EVENTS (bridge-first)
-- ============================================================================

-- Audit Log (técnico: operação, tabela, registro, user, timestamp)
CREATE TABLE IF NOT EXISTS foundation.audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    operation TEXT NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE', 'SELECT')),
    table_schema TEXT NOT NULL,
    table_name TEXT NOT NULL,
    record_id UUID,
    user_id UUID,
    user_email TEXT,
    ip_address INET,
    user_agent TEXT,
    changes JSONB,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_log_tenant_id ON foundation.audit_log(tenant_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_table ON foundation.audit_log(table_schema, table_name);
CREATE INDEX IF NOT EXISTS idx_audit_log_record_id ON foundation.audit_log(record_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_user_id ON foundation.audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_created_at ON foundation.audit_log(created_at);

COMMENT ON TABLE foundation.audit_log IS 'Log técnico de operações (mutação e leitura relevante)';

-- Audit Log Functional (decisões, evidências, justificativas)
CREATE TABLE IF NOT EXISTS foundation.audit_log_functional (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    decision_type TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    user_id UUID,
    user_email TEXT,
    context JSONB NOT NULL DEFAULT '{}'::jsonb,
    justification TEXT,
    evidence_refs JSONB DEFAULT '[]'::jsonb,
    attachments JSONB DEFAULT '[]'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_log_functional_tenant_id ON foundation.audit_log_functional(tenant_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_functional_entity ON foundation.audit_log_functional(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_functional_user_id ON foundation.audit_log_functional(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_functional_created_at ON foundation.audit_log_functional(created_at);

COMMENT ON TABLE foundation.audit_log_functional IS 'Log funcional de decisões e evidências (imutável ou versionado)';

-- Events Outbox (event backbone obrigatório)
CREATE TABLE IF NOT EXISTS foundation.events_outbox (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    correlation_id UUID,
    causation_id UUID,
    event_type TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    tenant_id UUID REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    payload JSONB NOT NULL,
    payload_version TEXT NOT NULL DEFAULT '1.0',
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'processed', 'failed')),
    retry_count INTEGER DEFAULT 0,
    error_message TEXT,
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_events_outbox_tenant_id ON foundation.events_outbox(tenant_id);
CREATE INDEX IF NOT EXISTS idx_events_outbox_correlation_id ON foundation.events_outbox(correlation_id);
CREATE INDEX IF NOT EXISTS idx_events_outbox_status ON foundation.events_outbox(status);
CREATE INDEX IF NOT EXISTS idx_events_outbox_entity ON foundation.events_outbox(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_events_outbox_created_at ON foundation.events_outbox(created_at);

COMMENT ON TABLE foundation.events_outbox IS 'Event backbone: eventos de domínio com correlation_id, causation_id, payload versionado';

-- Event Consumers (checkpoints governados)
CREATE TABLE IF NOT EXISTS foundation.event_consumers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    consumer_name TEXT NOT NULL UNIQUE,
    last_processed_event_id UUID REFERENCES foundation.events_outbox(id),
    last_processed_at TIMESTAMPTZ,
    checkpoint JSONB DEFAULT '{}'::jsonb,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'error')),
    error_message TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.event_consumers IS 'Consumers e checkpoints governados para replay controlado';

-- Correlation Context (correlation_id/cause)
CREATE TABLE IF NOT EXISTS foundation.correlation_context (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    correlation_id UUID NOT NULL,
    causation_id UUID,
    tenant_id UUID REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    context_type TEXT,
    context_data JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_correlation_context_correlation_id ON foundation.correlation_context(correlation_id);
CREATE INDEX IF NOT EXISTS idx_correlation_context_tenant_id ON foundation.correlation_context(tenant_id);

COMMENT ON TABLE foundation.correlation_context IS 'Contexto de correlação para rastreamento de eventos (correlation_id/causation_id)';

-- ============================================================================
-- F) BILLING INFRA (métrica faturável + serviços)
-- ============================================================================

-- Plans (planos de assinatura)
CREATE TABLE IF NOT EXISTS foundation.plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    billing_cycle TEXT CHECK (billing_cycle IN ('monthly', 'quarterly', 'yearly')),
    price NUMERIC,
    currency TEXT DEFAULT 'BRL',
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.plans IS 'Planos de assinatura (catálogo global)';

-- Subscriptions (assinaturas de tenants)
CREATE TABLE IF NOT EXISTS foundation.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES foundation.plans(id),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'cancelled', 'expired')),
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.subscriptions IS 'Assinaturas de tenants a planos';

-- Addons (add-ons/extras)
CREATE TABLE IF NOT EXISTS foundation.addons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC,
    currency TEXT DEFAULT 'BRL',
    billing_cycle TEXT CHECK (billing_cycle IN ('monthly', 'quarterly', 'yearly', 'one-time')),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.addons IS 'Catálogo de add-ons/extras';

-- Usage Metrics (métricas de uso faturável)
CREATE TABLE IF NOT EXISTS foundation.usage_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    metric_code TEXT NOT NULL,
    metric_value NUMERIC NOT NULL,
    period_start TIMESTAMPTZ NOT NULL,
    period_end TIMESTAMPTZ NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_usage_metrics_tenant_id ON foundation.usage_metrics(tenant_id);
CREATE INDEX IF NOT EXISTS idx_usage_metrics_period ON foundation.usage_metrics(period_start, period_end);
CREATE INDEX IF NOT EXISTS idx_usage_metrics_code ON foundation.usage_metrics(metric_code);

COMMENT ON TABLE foundation.usage_metrics IS 'Métricas de uso faturável (por período)';

-- Contract Dates (datas contratuais)
CREATE TABLE IF NOT EXISTS foundation.contract_dates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    contract_type TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    renewal_date DATE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.contract_dates IS 'Datas contratuais (início, fim, renovação)';

-- Service Catalog (config/admin services)
CREATE TABLE IF NOT EXISTS foundation.service_catalog (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    service_type TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.service_catalog IS 'Catálogo de serviços (config/admin services)';

-- Service Orders (prestação para cliente)
CREATE TABLE IF NOT EXISTS foundation.service_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    service_catalog_id UUID NOT NULL REFERENCES foundation.service_catalog(id),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    requested_by UUID,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.service_orders IS 'Ordens de serviço (prestação para cliente)';

-- ============================================================================
-- G) AI GOVERNANCE (BYO AI) + FAIRNESS CONSTRAINTS
-- ============================================================================

-- AI Providers (provedores de IA)
CREATE TABLE IF NOT EXISTS foundation.ai_providers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    provider_type TEXT NOT NULL,
    api_endpoint TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.ai_providers IS 'Catálogo de provedores de IA (OpenAI, Anthropic, etc)';

-- Tenant AI Connections (referência segura)
CREATE TABLE IF NOT EXISTS foundation.tenant_ai_connections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    ai_provider_id UUID NOT NULL REFERENCES foundation.ai_providers(id),
    connection_name TEXT NOT NULL,
    api_key_encrypted TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, connection_name)
);

COMMENT ON TABLE foundation.tenant_ai_connections IS 'Conexões seguras de tenant com provedores de IA (BYO AI)';

-- AI Models Registry (registro de modelos)
CREATE TABLE IF NOT EXISTS foundation.ai_models_registry (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ai_provider_id UUID NOT NULL REFERENCES foundation.ai_providers(id),
    model_code TEXT NOT NULL,
    model_name TEXT NOT NULL,
    model_version TEXT,
    capabilities JSONB DEFAULT '[]'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(ai_provider_id, model_code)
);

COMMENT ON TABLE foundation.ai_models_registry IS 'Registro de modelos de IA disponíveis';

-- AI Usage Policies (políticas de uso de IA)
CREATE TABLE IF NOT EXISTS foundation.ai_usage_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    policy_name TEXT NOT NULL,
    policy_rules JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.ai_usage_policies IS 'Políticas de uso de IA por tenant';

-- AI Use Cases (casos de uso de IA)
CREATE TABLE IF NOT EXISTS foundation.ai_use_cases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    use_case_code TEXT NOT NULL,
    use_case_name TEXT NOT NULL,
    description TEXT,
    ai_model_id UUID REFERENCES foundation.ai_models_registry(id),
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, use_case_code)
);

COMMENT ON TABLE foundation.ai_use_cases IS 'Casos de uso de IA por tenant';

-- Fairness Constraints (tenant + use_case; hard_stop vs warning)
CREATE TABLE IF NOT EXISTS foundation.fairness_constraints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    ai_use_case_id UUID NOT NULL REFERENCES foundation.ai_use_cases(id) ON DELETE CASCADE,
    constraint_type TEXT NOT NULL,
    constraint_rule JSONB NOT NULL,
    enforcement_level TEXT NOT NULL CHECK (enforcement_level IN ('hard_stop', 'warning')),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.fairness_constraints IS 'Restrições de fairness (hard_stop vs warning) por use case';

-- AI Audit Log (meta + custo + aprovação)
CREATE TABLE IF NOT EXISTS foundation.ai_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    ai_use_case_id UUID NOT NULL REFERENCES foundation.ai_use_cases(id),
    ai_model_id UUID REFERENCES foundation.ai_models_registry(id),
    user_id UUID,
    request_payload JSONB,
    response_payload JSONB,
    cost NUMERIC,
    tokens_used INTEGER,
    approval_status TEXT CHECK (approval_status IN ('approved', 'rejected', 'pending')),
    approved_by UUID,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_audit_log_tenant_id ON foundation.ai_audit_log(tenant_id);
CREATE INDEX IF NOT EXISTS idx_ai_audit_log_use_case ON foundation.ai_audit_log(ai_use_case_id);
CREATE INDEX IF NOT EXISTS idx_ai_audit_log_created_at ON foundation.ai_audit_log(created_at);

COMMENT ON TABLE foundation.ai_audit_log IS 'Auditoria de uso de IA (meta, custo, aprovação)';

-- ============================================================================
-- H) TEMPLATES & BOOTSTRAP
-- ============================================================================

-- Templates (templates de configuração)
CREATE TABLE IF NOT EXISTS foundation.templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    template_type TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.templates IS 'Catálogo de templates de configuração';

-- Template Versions (versões de templates)
CREATE TABLE IF NOT EXISTS foundation.template_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_id UUID NOT NULL REFERENCES foundation.templates(id) ON DELETE CASCADE,
    version TEXT NOT NULL,
    content JSONB NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(template_id, version)
);

COMMENT ON TABLE foundation.template_versions IS 'Versões de templates';

-- Template Assignments (atribuição de template a tenant)
CREATE TABLE IF NOT EXISTS foundation.template_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    template_id UUID NOT NULL REFERENCES foundation.templates(id),
    template_version_id UUID REFERENCES foundation.template_versions(id),
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    applied_at TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'applied', 'failed')),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.template_assignments IS 'Atribuição de template a tenant';

-- Bootstrap Runs (execuções de bootstrap)
CREATE TABLE IF NOT EXISTS foundation.bootstrap_runs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    template_id UUID REFERENCES foundation.templates(id),
    status TEXT NOT NULL DEFAULT 'running' CHECK (status IN ('running', 'completed', 'failed')),
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    error_message TEXT,
    logs JSONB DEFAULT '[]'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.bootstrap_runs IS 'Execuções de bootstrap (inicialização de tenant)';

-- ============================================================================
-- I) PLATFORM OWNER CONSOLE (POC) — infra
-- ============================================================================

-- Platform Incidents (incidentes da plataforma)
CREATE TABLE IF NOT EXISTS foundation.platform_incidents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_code TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    description TEXT,
    severity TEXT NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'investigating', 'resolved', 'closed')),
    affected_tenants JSONB DEFAULT '[]'::jsonb,
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE foundation.platform_incidents IS 'Incidentes da plataforma (visão soberana)';

-- Platform Ops Actions (ações de operação)
CREATE TABLE IF NOT EXISTS foundation.platform_ops_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    action_type TEXT NOT NULL,
    target_type TEXT NOT NULL,
    target_id UUID,
    performed_by UUID NOT NULL,
    performed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    result TEXT,
    metadata JSONB DEFAULT '{}'::jsonb
);

COMMENT ON TABLE foundation.platform_ops_actions IS 'Ações de operação da plataforma (auditoria soberana)';

-- Platform Audit (auditoria cruzada)
CREATE TABLE IF NOT EXISTS foundation.platform_audit (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    audit_type TEXT NOT NULL,
    tenant_id UUID REFERENCES foundation.tenants(id) ON DELETE SET NULL,
    performed_by UUID NOT NULL,
    performed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    findings JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_platform_audit_tenant_id ON foundation.platform_audit(tenant_id);
CREATE INDEX IF NOT EXISTS idx_platform_audit_performed_at ON foundation.platform_audit(performed_at);

COMMENT ON TABLE foundation.platform_audit IS 'Auditoria cruzada da plataforma (visão soberana)';

-- ============================================================================
-- TRIGGERS: updated_at automático
-- ============================================================================

CREATE OR REPLACE FUNCTION foundation.update_updated_at()
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
        WHERE table_schema = 'foundation' 
        AND column_name = 'updated_at'
        AND table_name NOT IN ('audit_log', 'audit_log_functional', 'events_outbox', 'usage_metrics', 'sensitive_access_audit', 'ai_audit_log', 'platform_ops_actions', 'platform_audit')
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS trigger_%s_updated_at ON foundation.%I', r.table_name, r.table_name);
        EXECUTE format('CREATE TRIGGER trigger_%s_updated_at BEFORE UPDATE ON foundation.%I FOR EACH ROW EXECUTE FUNCTION foundation.update_updated_at()', r.table_name, r.table_name);
    END LOOP;
END;
$$;
