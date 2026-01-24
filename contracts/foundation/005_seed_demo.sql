-- HUMANTRÍA — FOUNDATION SEED DEMO V1
-- Status: OBRIGATÓRIO
-- Escopo: Seed idempotente para ambiente DEMO (narrativo, sintético, resetável)
-- Requisitos: 1 tenant demo + RBAC mínimo + 1 use_case AI + 1 template + 1 service

SET search_path TO foundation, public;

-- ============================================================================
-- SEED: IDEMPOTENTE (usa ON CONFLICT)
-- ============================================================================

-- ============================================================================
-- A) TENANCY: 1 Tenant Demo
-- ============================================================================

-- Tenant demo: Acme Corporation
INSERT INTO foundation.tenants (id, name, slug, status, plan_id, metadata)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    'Acme Corporation',
    'acme-corp',
    'active',
    'enterprise',
    '{"industry": "technology", "region": "us-east"}'::jsonb
)
ON CONFLICT (slug) DO UPDATE SET
    name = EXCLUDED.name,
    status = EXCLUDED.status,
    plan_id = EXCLUDED.plan_id,
    metadata = EXCLUDED.metadata,
    updated_at = NOW();

-- Tenant Profile
INSERT INTO foundation.tenant_profiles (
    tenant_id,
    industry_vertical,
    size_band,
    operating_model,
    region_scope,
    country,
    primary_locale,
    base_currency,
    legal_model,
    headcount_band
)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    'Technology',
    'large',
    'SaaS',
    'Americas',
    'US',
    'en-US',
    'USD',
    'Corporation',
    '201-1000'
)
ON CONFLICT (tenant_id) DO UPDATE SET
    industry_vertical = EXCLUDED.industry_vertical,
    size_band = EXCLUDED.size_band,
    operating_model = EXCLUDED.operating_model,
    region_scope = EXCLUDED.region_scope,
    country = EXCLUDED.country,
    primary_locale = EXCLUDED.primary_locale,
    base_currency = EXCLUDED.base_currency,
    legal_model = EXCLUDED.legal_model,
    headcount_band = EXCLUDED.headcount_band,
    updated_at = NOW();

-- Tenant Environment (demo)
INSERT INTO foundation.tenant_environments (
    tenant_id,
    environment,
    is_demo,
    flags
)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    'demo',
    TRUE,
    '{"feature_a": true, "feature_b": true}'::jsonb
)
ON CONFLICT (tenant_id, environment) DO UPDATE SET
    is_demo = EXCLUDED.is_demo,
    flags = EXCLUDED.flags,
    updated_at = NOW();

-- Tenant Settings
INSERT INTO foundation.tenant_settings (
    tenant_id,
    timezone,
    locale,
    base_currency,
    date_format,
    time_format
)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    'America/New_York',
    'en-US',
    'USD',
    'MM/DD/YYYY',
    'HH:mm'
)
ON CONFLICT (tenant_id) DO UPDATE SET
    timezone = EXCLUDED.timezone,
    locale = EXCLUDED.locale,
    base_currency = EXCLUDED.base_currency,
    date_format = EXCLUDED.date_format,
    time_format = EXCLUDED.time_format,
    updated_at = NOW();

-- ============================================================================
-- B) IAM: RBAC Mínimo
-- ============================================================================

-- Roles (catálogo canônico)
INSERT INTO foundation.roles (id, code, name, description, is_system)
VALUES 
    ('10000000-0000-0000-0000-000000000001'::uuid, 'platform_owner', 'Platform Owner', 'Operador soberano da plataforma', TRUE),
    ('10000000-0000-0000-0000-000000000002'::uuid, 'tenant_admin', 'Tenant Admin', 'Administrador do tenant', TRUE),
    ('10000000-0000-0000-0000-000000000003'::uuid, 'gestor', 'Gestor', 'Gestor da área', TRUE),
    ('10000000-0000-0000-0000-000000000004'::uuid, 'colaborador', 'Colaborador', 'Colaborador', TRUE),
    ('10000000-0000-0000-0000-000000000005'::uuid, 'auditor', 'Auditor', 'Auditor (papel formal de evidência)', TRUE)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    is_system = EXCLUDED.is_system,
    updated_at = NOW();

-- Permissions (catálogo mínimo)
INSERT INTO foundation.permissions (id, code, name, description, resource_type, action)
VALUES 
    ('20000000-0000-0000-0000-000000000001'::uuid, 'tenant.read', 'Read Tenant', 'Ler dados do tenant', 'tenant', 'read'),
    ('20000000-0000-0000-0000-000000000002'::uuid, 'tenant.write', 'Write Tenant', 'Escrever dados do tenant', 'tenant', 'write'),
    ('20000000-0000-0000-0000-000000000003'::uuid, 'audit.read', 'Read Audit', 'Ler logs de auditoria', 'audit', 'read'),
    ('20000000-0000-0000-0000-000000000004'::uuid, 'ai.use', 'Use AI', 'Usar IA', 'ai', 'use')
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    resource_type = EXCLUDED.resource_type,
    action = EXCLUDED.action,
    updated_at = NOW();

-- Role Permissions (tenant_admin tem todas as permissões básicas)
INSERT INTO foundation.role_permissions (role_id, permission_id)
SELECT 
    r.id,
    p.id
FROM foundation.roles r
CROSS JOIN foundation.permissions p
WHERE r.code = 'tenant_admin'
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- User Role Assignment (usuário demo com role tenant_admin)
INSERT INTO foundation.user_role_assignments (
    tenant_id,
    user_id,
    role_id,
    assigned_at
)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '30000000-0000-0000-0000-000000000001'::uuid, -- user_id demo
    '10000000-0000-0000-0000-000000000002'::uuid, -- tenant_admin
    NOW()
)
ON CONFLICT DO NOTHING;

-- Membership
INSERT INTO foundation.memberships (
    tenant_id,
    user_id,
    status,
    joined_at
)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '30000000-0000-0000-0000-000000000001'::uuid,
    'active',
    NOW()
)
ON CONFLICT (tenant_id, user_id) DO UPDATE SET
    status = EXCLUDED.status,
    updated_at = NOW();

-- ============================================================================
-- C) FEATURE FLAGS & QUOTAS
-- ============================================================================

-- Feature Flags (catálogo)
INSERT INTO foundation.feature_flags (id, code, name, description, default_value)
VALUES 
    ('40000000-0000-0000-0000-000000000001'::uuid, 'feature_ai', 'AI Features', 'Habilita funcionalidades de IA', FALSE),
    ('40000000-0000-0000-0000-000000000002'::uuid, 'feature_advanced_analytics', 'Advanced Analytics', 'Habilita analytics avançado', FALSE)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    default_value = EXCLUDED.default_value,
    updated_at = NOW();

-- Tenant Feature Flags (override para demo)
INSERT INTO foundation.tenant_feature_flags (
    tenant_id,
    feature_flag_id,
    value
)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '40000000-0000-0000-0000-000000000001'::uuid, -- feature_ai
    TRUE
)
ON CONFLICT (tenant_id, feature_flag_id) DO UPDATE SET
    value = EXCLUDED.value,
    updated_at = NOW();

-- Quotas (catálogo)
INSERT INTO foundation.quotas (id, code, name, description, unit, default_value)
VALUES 
    ('50000000-0000-0000-0000-000000000001'::uuid, 'max_users', 'Max Users', 'Máximo de usuários', 'users', 10),
    ('50000000-0000-0000-0000-000000000002'::uuid, 'max_storage_gb', 'Max Storage', 'Máximo de armazenamento (GB)', 'GB', 50)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    unit = EXCLUDED.unit,
    default_value = EXCLUDED.default_value,
    updated_at = NOW();

-- Tenant Quotas (override para demo)
INSERT INTO foundation.tenant_quotas (
    tenant_id,
    quota_id,
    value
)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '50000000-0000-0000-0000-000000000001'::uuid, -- max_users
    100
)
ON CONFLICT (tenant_id, quota_id) DO UPDATE SET
    value = EXCLUDED.value,
    updated_at = NOW();

-- ============================================================================
-- D) BILLING: 1 Service
-- ============================================================================

-- Plans
INSERT INTO foundation.plans (id, code, name, description, billing_cycle, price, currency)
VALUES 
    ('60000000-0000-0000-0000-000000000001'::uuid, 'enterprise', 'Enterprise', 'Plano Enterprise', 'yearly', 10000.00, 'USD'),
    ('60000000-0000-0000-0000-000000000002'::uuid, 'startup', 'Startup', 'Plano Startup', 'monthly', 99.00, 'USD')
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    billing_cycle = EXCLUDED.billing_cycle,
    price = EXCLUDED.price,
    currency = EXCLUDED.currency,
    updated_at = NOW();

-- Subscriptions
INSERT INTO foundation.subscriptions (
    tenant_id,
    plan_id,
    status,
    started_at
)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '60000000-0000-0000-0000-000000000001'::uuid, -- enterprise
    'active',
    NOW()
)
ON CONFLICT DO NOTHING;

-- Service Catalog (1 service)
INSERT INTO foundation.service_catalog (id, code, name, description, service_type)
VALUES 
    ('70000000-0000-0000-0000-000000000001'::uuid, 'onboarding', 'Onboarding Service', 'Serviço de onboarding de tenant', 'admin')
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    service_type = EXCLUDED.service_type,
    updated_at = NOW();

-- Service Order (1 order)
INSERT INTO foundation.service_orders (
    tenant_id,
    service_catalog_id,
    status,
    requested_at,
    requested_by
)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '70000000-0000-0000-0000-000000000001'::uuid, -- onboarding
    'completed',
    NOW() - INTERVAL '1 day',
    '30000000-0000-0000-0000-000000000001'::uuid
)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- E) AI GOVERNANCE: 1 Use Case AI
-- ============================================================================

-- AI Providers
INSERT INTO foundation.ai_providers (id, code, name, provider_type, is_active)
VALUES 
    ('80000000-0000-0000-0000-000000000001'::uuid, 'openai', 'OpenAI', 'api', TRUE),
    ('80000000-0000-0000-0000-000000000002'::uuid, 'anthropic', 'Anthropic', 'api', TRUE)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    provider_type = EXCLUDED.provider_type,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- AI Models Registry
INSERT INTO foundation.ai_models_registry (
    ai_provider_id,
    model_code,
    model_name,
    model_version,
    capabilities
)
VALUES 
    ('80000000-0000-0000-0000-000000000001'::uuid, 'gpt-4', 'GPT-4', '4.0', '["chat", "completion"]'::jsonb),
    ('80000000-0000-0000-0000-000000000001'::uuid, 'gpt-3.5-turbo', 'GPT-3.5 Turbo', '3.5', '["chat", "completion"]'::jsonb)
ON CONFLICT (ai_provider_id, model_code) DO UPDATE SET
    model_name = EXCLUDED.model_name,
    model_version = EXCLUDED.model_version,
    capabilities = EXCLUDED.capabilities,
    updated_at = NOW();

-- Tenant AI Connection
INSERT INTO foundation.tenant_ai_connections (
    tenant_id,
    ai_provider_id,
    connection_name,
    is_active
)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '80000000-0000-0000-0000-000000000001'::uuid, -- openai
    'openai-primary',
    TRUE
)
ON CONFLICT (tenant_id, connection_name) DO UPDATE SET
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- AI Use Case (1 use case)
INSERT INTO foundation.ai_use_cases (
    tenant_id,
    use_case_code,
    use_case_name,
    description,
    ai_model_id,
    is_active
)
SELECT 
    '00000000-0000-0000-0000-000000000001'::uuid,
    'talent-recommendation',
    'Talent Recommendation',
    'Recomendação de talentos usando IA',
    amr.id,
    TRUE
FROM foundation.ai_models_registry amr
WHERE amr.model_code = 'gpt-4'
LIMIT 1
ON CONFLICT (tenant_id, use_case_code) DO UPDATE SET
    use_case_name = EXCLUDED.use_case_name,
    description = EXCLUDED.description,
    ai_model_id = EXCLUDED.ai_model_id,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- AI Usage Policy
INSERT INTO foundation.ai_usage_policies (
    tenant_id,
    policy_name,
    policy_rules,
    is_active
)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    'Default AI Policy',
    '{"max_tokens": 4000, "temperature": 0.7, "require_approval": false}'::jsonb,
    TRUE
)
ON CONFLICT DO NOTHING;

-- Fairness Constraints
INSERT INTO foundation.fairness_constraints (
    tenant_id,
    ai_use_case_id,
    constraint_type,
    constraint_rule,
    enforcement_level
)
SELECT 
    '00000000-0000-0000-0000-000000000001'::uuid,
    auc.id,
    'gender_parity',
    '{"min_female_percentage": 40, "max_female_percentage": 60}'::jsonb,
    'warning'
FROM foundation.ai_use_cases auc
WHERE auc.use_case_code = 'talent-recommendation'
LIMIT 1
ON CONFLICT DO NOTHING;

-- ============================================================================
-- F) TEMPLATES: 1 Template
-- ============================================================================

-- Templates (1 template)
INSERT INTO foundation.templates (id, code, name, description, template_type)
VALUES 
    ('90000000-0000-0000-0000-000000000001'::uuid, 'default-tenant-setup', 'Default Tenant Setup', 'Template padrão de configuração de tenant', 'tenant_setup')
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    template_type = EXCLUDED.template_type,
    updated_at = NOW();

-- Template Versions
INSERT INTO foundation.template_versions (
    template_id,
    version,
    content,
    is_active
)
VALUES (
    '90000000-0000-0000-0000-000000000001'::uuid,
    '1.0',
    '{"settings": {"timezone": "America/Sao_Paulo", "locale": "pt-BR"}, "features": ["feature_a"]}'::jsonb,
    TRUE
)
ON CONFLICT (template_id, version) DO UPDATE SET
    content = EXCLUDED.content,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- Template Assignment
INSERT INTO foundation.template_assignments (
    tenant_id,
    template_id,
    template_version_id,
    status,
    assigned_at,
    applied_at
)
SELECT 
    '00000000-0000-0000-0000-000000000001'::uuid,
    t.id,
    tv.id,
    'applied',
    NOW() - INTERVAL '1 day',
    NOW() - INTERVAL '1 day'
FROM foundation.templates t
JOIN foundation.template_versions tv ON t.id = tv.template_id
WHERE t.code = 'default-tenant-setup' AND tv.version = '1.0'
LIMIT 1
ON CONFLICT DO NOTHING;

-- ============================================================================
-- G) EVENT CONSUMERS
-- ============================================================================

INSERT INTO foundation.event_consumers (consumer_name, status, metadata)
VALUES 
    ('notification-service', 'active', '{"type": "notification"}'::jsonb),
    ('analytics-service', 'active', '{"type": "analytics"}'::jsonb),
    ('billing-service', 'active', '{"type": "billing"}'::jsonb)
ON CONFLICT (consumer_name) DO UPDATE SET
    status = EXCLUDED.status,
    metadata = EXCLUDED.metadata,
    updated_at = NOW();

-- ============================================================================
-- VALIDAÇÃO
-- ============================================================================

DO $$
DECLARE
    v_tenant_count INTEGER;
    v_role_count INTEGER;
    v_permission_count INTEGER;
    v_use_case_count INTEGER;
    v_template_count INTEGER;
    v_service_count INTEGER;
BEGIN
    -- Valida tenant demo
    SELECT COUNT(*) INTO v_tenant_count
    FROM foundation.tenants
    WHERE slug = 'acme-corp';
    
    IF v_tenant_count < 1 THEN
        RAISE EXCEPTION 'Seed demo falhou: tenant demo não encontrado';
    END IF;
    
    -- Valida RBAC mínimo
    SELECT COUNT(*) INTO v_role_count FROM foundation.roles WHERE is_system = TRUE;
    SELECT COUNT(*) INTO v_permission_count FROM foundation.permissions;
    
    IF v_role_count < 5 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado 5 roles, encontrado %', v_role_count;
    END IF;
    
    IF v_permission_count < 4 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado 4 permissions, encontrado %', v_permission_count;
    END IF;
    
    -- Valida use case AI
    SELECT COUNT(*) INTO v_use_case_count
    FROM foundation.ai_use_cases
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;
    
    IF v_use_case_count < 1 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado 1 use case AI, encontrado %', v_use_case_count;
    END IF;
    
    -- Valida template
    SELECT COUNT(*) INTO v_template_count
    FROM foundation.templates
    WHERE code = 'default-tenant-setup';
    
    IF v_template_count < 1 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado 1 template, encontrado %', v_template_count;
    END IF;
    
    -- Valida service
    SELECT COUNT(*) INTO v_service_count
    FROM foundation.service_catalog
    WHERE code = 'onboarding';
    
    IF v_service_count < 1 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado 1 service, encontrado %', v_service_count;
    END IF;
    
    RAISE NOTICE 'Seed demo concluído: tenant=%, roles=%, permissions=%, use_cases=%, templates=%, services=%', 
        v_tenant_count, v_role_count, v_permission_count, v_use_case_count, v_template_count, v_service_count;
END;
$$;
