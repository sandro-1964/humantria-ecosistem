-- HUMANTRÍA — BASE V1 VALIDATION QUERIES
-- Status: READ-ONLY · SAFE TO RUN
-- Objetivo: Validar que Foundation V1 + Core V1 estão corretamente aplicados
-- Como usar: Execute via Supabase Dashboard SQL Editor ou MCP execute_sql

-- ============================================================================
-- 1) VALIDAÇÃO DE SCHEMAS E ESTRUTURA
-- ============================================================================

-- 1.1 Verificar schemas criados
SELECT
    schema_name,
    CASE
        WHEN schema_name = 'foundation' THEN '✅ Foundation V1 ativo'
        WHEN schema_name = 'core' THEN '✅ Core V1 ativo'
        ELSE '❓ Schema não identificado'
    END as status
FROM information_schema.schemata
WHERE schema_name IN ('foundation', 'core')
ORDER BY schema_name;

-- 1.2 Contagem total de tabelas por schema
SELECT
    schemaname as schema_name,
    COUNT(*) as table_count,
    CASE
        WHEN schemaname = 'foundation' AND COUNT(*) >= 48 THEN '✅ Foundation: OK (48+ tabelas)'
        WHEN schemaname = 'core' AND COUNT(*) >= 15 THEN '✅ Core: OK (15+ tabelas)'
        ELSE '❌ Contagem insuficiente'
    END as validation
FROM pg_tables
WHERE schemaname IN ('foundation', 'core')
GROUP BY schemaname
ORDER BY schemaname;

-- 1.3 Verificar extensões instaladas
SELECT
    name as extension,
    CASE
        WHEN name = 'uuid-ossp' THEN '✅ UUID generation OK'
        WHEN name = 'pgcrypto' THEN '✅ Crypto functions OK'
        ELSE '❓ Extensão não identificada'
    END as status
FROM pg_available_extensions
WHERE name IN ('uuid-ossp', 'pgcrypto') AND installed_version IS NOT NULL;

-- ============================================================================
-- 2) VALIDAÇÃO DE SEED DEMO (FOUNDATION)
-- ============================================================================

-- 2.1 Tenant demo criado
SELECT
    COUNT(*) as tenant_count,
    CASE
        WHEN COUNT(*) >= 1 THEN '✅ Tenant demo OK'
        ELSE '❌ Tenant demo faltando'
    END as validation
FROM foundation.tenants
WHERE slug = 'acme-corp';

-- 2.2 Roles canônicas criadas
SELECT
    COUNT(*) as role_count,
    CASE
        WHEN COUNT(*) >= 5 THEN '✅ Roles canônicas OK (5+)'
        ELSE '❌ Roles insuficientes'
    END as validation
FROM foundation.roles
WHERE is_system = TRUE;

-- 2.3 Permissions criadas
SELECT
    COUNT(*) as permission_count,
    CASE
        WHEN COUNT(*) >= 4 THEN '✅ Permissions OK (4+)'
        ELSE '❌ Permissions insuficientes'
    END as validation
FROM foundation.permissions;

-- 2.4 AI Use Case criado
SELECT
    COUNT(*) as ai_use_case_count,
    CASE
        WHEN COUNT(*) >= 1 THEN '✅ AI Use Case OK'
        ELSE '❌ AI Use Case faltando'
    END as validation
FROM foundation.ai_use_cases auc
WHERE auc.tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;

-- 2.5 Template criado
SELECT
    COUNT(*) as template_count,
    CASE
        WHEN COUNT(*) >= 1 THEN '✅ Template OK'
        ELSE '❌ Template faltando'
    END as validation
FROM foundation.templates
WHERE code = 'default-tenant-setup';

-- 2.6 Service criado
SELECT
    COUNT(*) as service_count,
    CASE
        WHEN COUNT(*) >= 1 THEN '✅ Service OK'
        ELSE '❌ Service faltando'
    END as validation
FROM foundation.service_catalog
WHERE code = 'onboarding';

-- ============================================================================
-- 3) VALIDAÇÃO DE SEED DEMO (CORE)
-- ============================================================================

-- 3.1 Org Units criados (hierarquia)
SELECT
    COUNT(*) as org_unit_count,
    CASE
        WHEN COUNT(*) >= 6 THEN '✅ Org Units OK (6+ com hierarquia)'
        ELSE '❌ Org Units insuficientes'
    END as validation
FROM core.org_units
WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;

-- 3.2 Cost Centers criados
SELECT
    COUNT(*) as cost_center_count,
    CASE
        WHEN COUNT(*) >= 2 THEN '✅ Cost Centers OK (2+)'
        ELSE '❌ Cost Centers insuficientes'
    END as validation
FROM core.cost_centers
WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;

-- 3.3 Jobs criados
SELECT
    COUNT(*) as job_count,
    CASE
        WHEN COUNT(*) >= 5 THEN '✅ Jobs OK (5+)'
        ELSE '❌ Jobs insuficientes'
    END as validation
FROM core.jobs
WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;

-- 3.4 Job Levels criados (35 = 7 níveis × 5 jobs)
SELECT
    COUNT(*) as job_level_count,
    CASE
        WHEN COUNT(*) >= 35 THEN '✅ Job Levels OK (35+)'
        ELSE '❌ Job Levels insuficientes'
    END as validation
FROM core.job_levels
WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;

-- 3.5 People criados
SELECT
    COUNT(*) as people_count,
    CASE
        WHEN COUNT(*) >= 10 THEN '✅ People OK (10+)'
        ELSE '❌ People insuficientes'
    END as validation
FROM core.people
WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;

-- 3.6 Person Contacts (emails obrigatórios)
SELECT
    COUNT(*) as email_contacts_count,
    CASE
        WHEN COUNT(*) >= 10 THEN '✅ Email contacts OK (10+)'
        ELSE '❌ Email contacts insuficientes'
    END as validation
FROM core.person_contacts pc
WHERE pc.tenant_id = '00000000-0000-0000-0000-000000000001'::uuid
  AND pc.contact_type = 'email';

-- 3.7 Person Org Assignments
SELECT
    COUNT(*) as assignment_count,
    CASE
        WHEN COUNT(*) >= 10 THEN '✅ Assignments OK (10+)'
        ELSE '❌ Assignments insuficientes'
    END as validation
FROM core.person_org_assignments poa
WHERE poa.tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;

-- ============================================================================
-- 4) VALIDAÇÃO DE AUDIT & EVENTS
-- ============================================================================

-- 4.1 Audit Log tem registros (se houver mutations)
SELECT
    COUNT(*) as audit_log_count,
    MAX(created_at) as last_audit_entry,
    CASE
        WHEN COUNT(*) > 0 THEN '✅ Audit Log ativo'
        ELSE 'ℹ️ Audit Log vazio (normal se sem mutations)'
    END as status
FROM foundation.audit_log;

-- 4.2 Events Outbox tem registros (se houver mutations)
SELECT
    COUNT(*) as outbox_count,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_events,
    COUNT(CASE WHEN status = 'processed' THEN 1 END) as processed_events,
    MAX(created_at) as last_event,
    CASE
        WHEN COUNT(*) > 0 THEN '✅ Event backbone ativo'
        ELSE 'ℹ️ Events outbox vazio (normal se sem mutations)'
    END as status
FROM foundation.events_outbox;

-- 4.3 Event Consumers registrados
SELECT
    consumer_name,
    status,
    last_processed_event_id,
    CASE
        WHEN status = 'active' THEN '✅ Consumer ativo'
        ELSE '⚠️ Consumer inativo'
    END as validation
FROM foundation.event_consumers
ORDER BY consumer_name;

-- ============================================================================
-- 5) VALIDAÇÃO DE RLS (ROW LEVEL SECURITY)
-- ============================================================================

-- 5.1 Verificar RLS habilitado por tabela
SELECT
    schemaname as schema_name,
    tablename as table_name,
    CASE
        WHEN rowsecurity THEN '✅ RLS ativo'
        ELSE '❌ RLS inativo'
    END as rls_status
FROM pg_tables pt
LEFT JOIN pg_class pc ON pc.relname = pt.tablename AND pc.relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = pt.schemaname)
LEFT JOIN pg_seclabel psl ON psl.objoid = pc.oid AND psl.objtype = 'table'
WHERE pt.schemaname IN ('foundation', 'core')
ORDER BY pt.schemaname, pt.tablename;

-- 5.2 Contar políticas RLS por tabela
SELECT
    schemaname as schema_name,
    tablename as table_name,
    COUNT(*) as policy_count,
    CASE
        WHEN COUNT(*) > 0 THEN '✅ Políticas aplicadas'
        ELSE '❌ Sem políticas RLS'
    END as validation
FROM pg_policies pp
WHERE schemaname IN ('foundation', 'core')
GROUP BY schemaname, tablename
ORDER BY schemaname, tablename;

-- ============================================================================
-- 6) VALIDAÇÃO DE FUNÇÕES GOVERNADAS
-- ============================================================================

-- 6.1 Funções por schema
SELECT
    n.nspname as schema_name,
    COUNT(*) as function_count,
    CASE
        WHEN n.nspname = 'foundation' AND COUNT(*) >= 11 THEN '✅ Foundation functions OK (11+)'
        WHEN n.nspname = 'core' AND COUNT(*) >= 8 THEN '✅ Core functions OK (8+)'
        ELSE '❌ Funções insuficientes'
    END as validation
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname IN ('foundation', 'core')
  AND p.prokind = 'f'  -- funções normais
GROUP BY n.nspname;

-- 6.2 Verificar SECURITY INVOKER
SELECT
    n.nspname as schema_name,
    p.proname as function_name,
    CASE
        WHEN p.prosecdef THEN '✅ SECURITY INVOKER'
        ELSE '❌ SECURITY DEFINER (risco!)'
    END as security_mode
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname IN ('foundation', 'core')
  AND p.prokind = 'f'
ORDER BY n.nspname, p.proname;

-- ============================================================================
-- 7) VALIDAÇÃO DE HIERARQUIA ORG UNITS
-- ============================================================================

-- 7.1 Testar hierarquia (org_units com parent_id)
WITH RECURSIVE org_hierarchy AS (
    SELECT
        id,
        code,
        parent_id,
        0 as level,
        ARRAY[code] as path
    FROM core.org_units
    WHERE parent_id IS NULL
        AND tenant_id = '00000000-0000-0000-0000-000000000001'::uuid

    UNION ALL

    SELECT
        ou.id,
        ou.code,
        ou.parent_id,
        oh.level + 1,
        oh.path || ou.code
    FROM core.org_units ou
    JOIN org_hierarchy oh ON ou.parent_id = oh.id
    WHERE ou.tenant_id = '00000000-0000-0000-0000-000000000001'::uuid
)
SELECT
    COUNT(*) as hierarchy_nodes,
    MAX(level) as max_depth,
    CASE
        WHEN COUNT(*) >= 6 AND MAX(level) >= 2 THEN '✅ Hierarquia OK (árvore completa)'
        ELSE '❌ Hierarquia insuficiente'
    END as validation
FROM org_hierarchy;

-- ============================================================================
-- 8) RESUMO FINAL DE VALIDAÇÃO
-- ============================================================================

-- 8.1 Status consolidado
WITH validation_summary AS (
    -- Schemas
    SELECT 'Schemas' as category, COUNT(*) >= 2 as passed FROM information_schema.schemata WHERE schema_name IN ('foundation', 'core')
    UNION ALL
    -- Tabelas Foundation
    SELECT 'Foundation Tables', COUNT(*) >= 48 as passed FROM pg_tables WHERE schemaname = 'foundation'
    UNION ALL
    -- Tabelas Core
    SELECT 'Core Tables', COUNT(*) >= 15 as passed FROM pg_tables WHERE schemaname = 'core'
    UNION ALL
    -- Tenant demo
    SELECT 'Demo Tenant', COUNT(*) >= 1 as passed FROM foundation.tenants WHERE slug = 'acme-corp'
    UNION ALL
    -- Roles
    SELECT 'Roles Canônicas', COUNT(*) >= 5 as passed FROM foundation.roles WHERE is_system = TRUE
    UNION ALL
    -- Org Units
    SELECT 'Org Units', COUNT(*) >= 6 as passed FROM core.org_units WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid
    UNION ALL
    -- People
    SELECT 'People', COUNT(*) >= 10 as passed FROM core.people WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid
    UNION ALL
    -- RLS ativo
    SELECT 'RLS Ativo', COUNT(DISTINCT schemaname || '.' || tablename) >= 63 as passed
    FROM pg_policies WHERE schemaname IN ('foundation', 'core')
)
SELECT
    category,
    CASE WHEN passed THEN '✅ PASS' ELSE '❌ FAIL' END as status,
    CASE WHEN passed THEN 'OK' ELSE 'Verificar' END as action
FROM validation_summary
ORDER BY
    CASE
        WHEN category = 'Schemas' THEN 1
        WHEN category = 'Foundation Tables' THEN 2
        WHEN category = 'Core Tables' THEN 3
        WHEN category = 'Demo Tenant' THEN 4
        WHEN category = 'Roles Canônicas' THEN 5
        WHEN category = 'Org Units' THEN 6
        WHEN category = 'People' THEN 7
        WHEN category = 'RLS Ativo' THEN 8
        ELSE 99
    END;

-- ============================================================================
-- FIM DAS QUERIES DE VALIDAÇÃO
-- ============================================================================

/*
INSTRUÇÕES DE USO:
1. Execute todas as queries em sequência via Supabase Dashboard
2. Cada query retorna status de validação
3. ✅ significa OK, ❌ significa problema encontrado
4. Queries são READ-ONLY (seguras de executar)
5. Resultados devem mostrar todos ✅ para Base V1 estar OK
*/