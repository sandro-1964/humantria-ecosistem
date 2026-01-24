# HUMANTRÍA — BASE RELEASE V1

**Versão:** BASE-V1.0.0
**Data:** 2026-01-24
**Status:** ✅ RELEASED · FROZEN
**Escopo:** Foundation V1 + Core V1 (Infra + Semântica Canônica)

---

## 📋 ESCOPO DA RELEASE

### Foundation V1 (Infra Transversal)
- **Tenancy & Onboarding:** tenants, tenant_profiles, tenant_environments, tenant_status_history
- **IAM:** memberships, roles, permissions, role_permissions, user_role_assignments, session_revocations
- **Tenant Settings:** tenant_settings, feature_flags, tenant_feature_flags, quotas, tenant_quotas
- **LGPD/Privacy:** data_purposes, legal_bases, consents, retention_policies, legal_holds, anonymization_requests, sensitive_access_audit
- **Audit/Events:** audit_log, audit_log_functional, events_outbox, event_consumers, correlation_context
- **Billing Infra:** plans, subscriptions, addons, usage_metrics, contract_dates, service_catalog, service_orders
- **AI Governance:** ai_providers, tenant_ai_connections, ai_models_registry, ai_usage_policies, ai_use_cases, fairness_constraints, ai_audit_log
- **Templates & Bootstrap:** templates, template_versions, template_assignments, bootstrap_runs
- **Platform Owner Console:** platform_incidents, platform_ops_actions, platform_audit

### Core V1 (Semântica Canônica)
- **Organização:** org_units (hierarquia), org_units_history (effective dating), cost_centers, org_unit_cost_center_links
- **Jobs/Levels:** jobs, job_levels (7 níveis: JUNIOR→VP)
- **People:** people, person_contacts (email obrigatório), person_identities, person_org_assignments (effective dating), person_status_history
- **Imports:** import_jobs, import_job_runs, import_row_results, import_mappings

---

## 📊 ESTATÍSTICAS DA BASE

### Foundation
- **48 tabelas** + 2 views (50 objetos)
- **11 funções** (SECURITY INVOKER)
- **81 políticas RLS**
- **2.803 linhas** de código SQL

### Core
- **15 tabelas**
- **8 funções** (SECURITY INVOKER)
- **45 políticas RLS**
- **1.966 linhas** de código SQL

### Total Base
- **63 tabelas** + 2 views
- **19 funções** governadas
- **126 políticas RLS**
- **4.769 linhas** de código SQL

---

## 🔗 ARTEFATOS DE REFERÊNCIA

### Contracts (Read-Only)
```
contracts/foundation/
├── 001_schema.sql          ✅ Executado
├── 002_tables.sql          ✅ Executado (48 tabelas)
├── 003_functions.sql       ✅ Executado (11 funções)
├── 004_rls.sql            ✅ Executado (81 políticas)
└── 005_seed_demo.sql      ✅ Executado (seed completo)

contracts/core/
├── 001_schema.sql          ✅ Executado
├── 002_tables.sql          ✅ Executado (15 tabelas)
├── 003_functions.sql       ✅ Executado (8 funções)
├── 004_rls.sql            ✅ Executado (45 políticas)
└── 005_seed_demo.sql      ✅ Executado (seed completo)
```

### Documentação
```
docs/_canon/                → Regras canônicas (fonte de verdade)
docs/foundation/            → Logs e validação Foundation
docs/core/                  → Logs e validação Core
docs/releases/              → Histórico de releases
docs/decisions/             → Registro de decisões arquiteturais
```

---

## 🌱 SEED DEMO (Dados de Referência)

### Foundation Demo
- **1 tenant:** Acme Corporation (acme-corp)
- **5 roles canônicas:** platform_owner, tenant_admin, gestor, colaborador, auditor
- **4 permissions básicas:** tenant.read, tenant.write, audit.read, ai.use
- **1 use case AI:** talent-recommendation (com fairness constraints)
- **1 template:** default-tenant-setup
- **1 service:** onboarding (completed)

### Core Demo
- **6 org_units:** Hierarquia Acme Corp (CORP → TECH/PROD/SALES → sub-depts)
- **2 cost_centers:** TECH-CC, SALES-CC (vinculados a org_units)
- **5 jobs:** ENG, PM, SALES, HR, FIN
- **35 job_levels:** 7 níveis × 5 jobs (JUNIOR, PLENO, SENIOR, LEAD, MANAGER, DIRECTOR, VP)
- **10 people:** Dados fictícios com emails obrigatórios
- **10 assignments:** Vínculos org_unit + job + level

---

## ✅ VALIDAÇÃO EXECUTADA

### RLS (Row Level Security)
- ✅ **126 políticas** aplicadas
- ✅ **Platform Owner:** Acesso soberano a tudo
- ✅ **Tenant Admin:** Acesso limitado ao próprio tenant
- ✅ **Perfis de negócio:** Acesso read-only aos dados necessários

### Audit & Events
- ✅ **Event backbone:** events_outbox ativo com correlation_id/causation_id
- ✅ **Audit logs:** audit_log e audit_log_functional funcionando
- ✅ **Consumers:** notification-service, analytics-service, billing-service registrados

### Integration
- ✅ **Schema isolation:** foundation e core separados
- ✅ **Cross-schema refs:** Core referencia tenants do Foundation
- ✅ **Security:** Todas as funções SECURITY INVOKER
- ✅ **Idempotency:** Seeds executáveis múltiplas vezes

---

## 🎯 DECISÕES E TODOS

### Decisões Tomadas
- **Multi-tenancy hard:** tenant_id em todas as tabelas domain (35 tabelas Foundation + 14 Core)
- **RLS mandatory:** Zero bypass possível, policies baseadas em roles JWT
- **Event-first:** Todo mutation gera evento no outbox
- **Effective dating:** Usado em org_units_history e person_org_assignments
- **Hierarquia recursiva:** Suporte completo em org_units (parent_id)

### TODOs Deferidos (Não Bloqueantes)
- **org_unit_edges v1.5:** Dual-reporting/matrix organization (deferido para v2.0)
- **job_families:** Agrupamento de jobs (deferido para quando necessário)
- **Advanced audit:** Compressão automática de logs antigos (deferido para v2.0)
- **Event replay:** Controle avançado de replay por consumer (implementado básico)

### Regras de Evolução
- **Base frozen:** Não reabrir Foundation/Core sem decisão explícita
- **Patch only:** Apenas correções críticas de segurança/bug
- **New products:** Via contracts/<product>/ apenas
- **No breaking changes:** Qualquer alteração deve ser backward-compatible

---

## 🏁 CRITÉRIOS DE ACEITE (VALIDAÇÃO)

### Funcional
- [x] **RLS ativa:** Platform Owner vê tudo, Tenant Admin vê apenas seu tenant
- [x] **Audit funcionando:** Qualquer INSERT/UPDATE gera log em audit_log
- [x] **Events outbox:** Mutations geram eventos no events_outbox
- [x] **Seeds completos:** Dados demo suficientes para testes funcionais
- [x] **Hierarquia OK:** org_units suportam estrutura em árvore
- [x] **Effective dating:** Mudanças históricas preservadas

### Segurança
- [x] **No public tables:** Tudo em schemas foundation/core
- [x] **SECURITY INVOKER:** Todas as funções rodam como caller
- [x] **No cross-product FKs:** Apenas refs controladas Foundation→Core
- [x] **JWT-based auth:** Roles vem do token JWT
- [x] **Data isolation:** tenant_id isola dados completamente

### Performance
- [x] **Índices adequados:** PKs, FKs, e campos de busca indexados
- [x] **Queries otimizadas:** Views para consultas frequentes
- [x] **Partitioning ready:** Estrutura preparada para particionamento futuro

---

## 🚀 PRÓXIMO PASSO

**BASE V1 CONCLUÍDA** ✅

Próximas releases serão produtos específicos:
- contracts/<product>/001_schema.sql
- contracts/<product>/002_tables.sql
- contracts/<product>/003_functions.sql
- contracts/<product>/004_rls.sql
- contracts/<product>/005_seed_demo.sql

Cada produto terá seu próprio validation_report.md e release document.

---

**Esta é a referência congelada da Base HUMANTRÍA V1.**
**Qualquer evolução deve ser registrada em docs/decisions/ e seguir o método DEV NON-STOP.**