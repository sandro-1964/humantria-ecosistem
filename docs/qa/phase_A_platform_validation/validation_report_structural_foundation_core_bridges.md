# HUMANTRÍA — Validação Estrutural (Read-Only) — Foundation + Core + Bridges

**Data:** 2026-01-31  
**Branch:** qa-t9-supabase-integration  
**Project ID:** vpsqhmklecjvbnlhktbg  
**Project Name:** Humantria  
**Project URL:** https://vpsqhmklecjvbnlhktbg.supabase.co  

Conforme docs/_canon (DB Contract, Architecture, Release Criteria). Validação somente leitura via MCP execute_sql.

---

## 1. Metadados

| Campo | Valor |
|-------|-------|
| Data | 2026-01-31 |
| Branch | qa-t9-supabase-integration |
| project_id | vpsqhmklecjvbnlhktbg |
| project_name | Humantria |
| project_url | https://vpsqhmklecjvbnlhktbg.supabase.co |

---

## 2. Evidências por Query

### Q1: Schemas existentes (E1)

```sql
SELECT schema_name FROM information_schema.schemata
WHERE schema_name NOT IN ('pg_catalog','information_schema','pg_toast')
  AND schema_name NOT LIKE 'pg_temp%'
ORDER BY schema_name;
```

**Output:**
```json
["auth","bridges","core","extensions","foundation","graphql","graphql_public","pgbouncer","public","realtime","storage","strategy","supabase_migrations","vault"]
```

### Q2: Migrations aplicadas (E2)

```sql
SELECT version, name FROM supabase_migrations.schema_migrations
WHERE name LIKE '%foundation%' OR name LIKE '%core%' OR name LIKE '%bridges%'
ORDER BY version;
```

**Output:**
| version | name |
|---------|------|
| 20260127205302 | core_gs_patch_v1_ui_apis_001_patch_schema |
| 20260127205324 | core_gs_patch_v1_ui_apis_002_patch_functions |
| 20260127205333 | core_gs_patch_v1_ui_apis_003_patch_grants_rls |
| 20260127205344 | core_gs_patch_v1_ui_apis_004_patch_seed_demo |
| 20260127205619 | core_gs_patch_v1_ui_apis_002_patch_functions_fix_job_levels_column |
| 20260128001241 | bridges_gs_patch_v1_ui_ops_001_patch_schema |
| 20260128001512 | bridges_gs_patch_v1_ui_ops_002_patch_functions |
| 20260128001524 | bridges_gs_patch_v1_ui_ops_003_patch_grants_rls |
| 20260128001529 | bridges_gs_patch_v1_ui_ops_004_patch_seed_demo |
| 20260131141701 | 001_foundation_schema |
| 20260131142242 | 002_foundation_tables |
| 20260131142349 | 003_foundation_functions |
| 20260131142539 | 004_foundation_rls |
| 20260131142828 | 005_foundation_seed_demo |

### Q3: Tabelas SEM tenant_id (E3) — catálogos globais esperados

```sql
SELECT t.table_schema, t.table_name, c.column_name
FROM information_schema.tables t
LEFT JOIN information_schema.columns c ON c.table_schema=t.table_schema AND c.table_name=t.table_name AND c.column_name='tenant_id'
WHERE t.table_schema IN ('foundation','core','bridges')
  AND t.table_type='BASE TABLE'
  AND c.column_name IS NULL
ORDER BY t.table_schema, t.table_name;
```

**Output:** foundation.addons, ai_models_registry, ai_providers, event_consumers, feature_flags, permissions, plans, platform_incidents, platform_ops_actions, quotas, role_permissions, roles, service_catalog, template_versions, templates, tenants — todos catálogos/raiz. OK.

### Q4: Tabelas COM tenant_id (cross-check)

**Output:** 42 tabelas em foundation + core com tenant_id. OK.

### Q5: Tabelas SEM RLS (E4)

```sql
SELECT c.table_schema, c.table_name
FROM information_schema.tables c
WHERE c.table_schema IN ('foundation','core') AND c.table_type = 'BASE TABLE'
  AND NOT EXISTS (SELECT 1 FROM pg_tables pt WHERE pt.schemaname = c.table_schema AND pt.tablename = c.table_name AND pt.rowsecurity = true)
ORDER BY c.table_schema, c.table_name;
```

**Output:** addons, ai_models_registry, ai_providers, feature_flags, permissions, plans, quotas, role_permissions, roles, service_catalog, template_versions, templates — catálogos globais (sem RLS conforme canon). OK.

### Q6: Políticas RLS (E12)

**Pré-patch:** 98 políticas em foundation + core.

**Pós-patch (8 tabelas corrigidas):** As 8 tabelas core agora têm policies:
- cost_centers: 3 policies
- import_job_runs: 3 policies
- import_mappings: 3 policies
- import_row_results: 3 policies
- org_unit_cost_center_links: 3 policies
- org_units_history: 3 policies
- person_identities: 3 policies
- person_status_history: 3 policies

### Q7: Tabelas com RLS SEM policy (E5)

**Pré-patch:** 8 tabelas core sem policy (FAIL).

**Pós-patch (GS-PATCH Core RLS Policies V1):**
```sql
-- mesma query Q7
```
**Output:** `[]` (vazio) — OK.

### Q8: Funções SECURITY DEFINER (E6)

```sql
SELECT n.nspname AS schema, p.proname AS function_name, p.prosecdef AS is_security_definer
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname IN ('foundation','core','bridges')
  AND p.proname NOT LIKE 'update_updated_at'
ORDER BY n.nspname, p.proname;
```

**Output:** Todas as funções com `is_security_definer=false` (SECURITY INVOKER). OK.

### Q9: FK Cross-Product (E7)

**Output:** 10 FKs strategy→core (approval_history, budget_approvals, budget_items, key_results, objectives, staffing_demands → core.people, org_units, cost_centers, jobs, job_levels).

**Classificação pós-decisão (2026-01-31):** FK Produto→Core é **permitida** conforme docs/decisions/2026-01-31-layer-dependency-fk-policy.md. Strategy→Core = OK.

### Q10: events_outbox colunas (E8)

**Output:** id, correlation_id, causation_id, event_type, entity_type, entity_id, tenant_id, payload, payload_version, status, retry_count, error_message, processed_at, created_at. OK.

### Q11: event_consumers colunas (E9)

**Output:** id, consumer_name, last_processed_event_id, last_processed_at, checkpoint, status, error_message, metadata, created_at, updated_at. OK.

### Q12: Contagem event backbone (E9)

**Output:** events_outbox_count=6, event_consumers_count=3. OK.

### Q13: audit_log e audit_log_functional (E10)

**Output:** Ambas existem em foundation. OK.

### Q14: Seed Foundation (E11)

**Output:** tenants=1, roles=5, permissions=4, event_consumers=3, plans=2. OK.

### Q15: Seed Core (E11)

**Output:** org_units=6, people=10, jobs=5. OK.

### Q16: Bridges RPCs (E6 complementar)

**Output:** 6 funções, todas is_security_definer=false. OK.

---

## 3. Decisão canônica aplicada

**Arquivo:** docs/decisions/2026-01-31-layer-dependency-fk-policy.md

**Resumo:** FK Produto→Core e FK Produto→Foundation são **permitidas**. Proibido: Core/Foundation→Produto e Produto↔Produto.

**Canon atualizado:** docs/_canon/01_architecture_principles.md (seção 2.1), docs/_canon/02_db_contract_global.md (proibições).

---

## 4. GS-PATCH aplicado

**Contrato:** contracts/gs_patch_core_rls_policies_v1/001_core_rls_missing_policies.sql

**Escopo:** 24 policies adicionadas para 8 tabelas core (org_units_history, cost_centers, org_unit_cost_center_links, person_identities, person_status_history, import_job_runs, import_row_results, import_mappings).

**Método:** MCP execute_sql no projeto Humantria (vpsqhmklecjvbnlhktbg).

---

## 5. Tabela PASS/FAIL por Critério (revisada)

| Critério | Resultado | Observação |
|----------|-----------|------------|
| Multi-tenancy | PASS | Catálogos sem tenant_id; domínio com tenant_id |
| RLS | PASS | Q7 pós-patch vazio; 8 tabelas com policies |
| SECURITY INVOKER | PASS | Todas as funções governadas com prosecdef=false |
| FK cross-product | PASS | Strategy→Core permitido (Decisão 2026-01-31) |
| Event backbone | PASS | events_outbox e event_consumers OK |
| Audit | PASS | audit_log e audit_log_functional existem |
| Seed Foundation | PASS | tenants≥1, roles≥5, permissions≥4, event_consumers≥1 |
| Migrations | PASS | foundation 001–005, core e bridges patches aplicados |

---

## 6. Conclusão

**ESTRUTURAL OK**

Todas as falhas foram tratadas:
- **RLS:** GS-PATCH aplicado; Q7 pós-patch retorna vazio.
- **FK cross-product:** Strategy→Core classificado como OK conforme decisão canônica 2026-01-31.
