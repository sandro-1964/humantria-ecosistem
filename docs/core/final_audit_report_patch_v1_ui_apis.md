# HUMANTRÍA — CORE — GS-PATCH V1 — UI/APIs mínimas — Final Audit Report

**Data:** 2026-01-27  
**Branch:** `core-gs-patch-v1-ui-apis`  
**Status:** ✅ **VALIDADO (aguardando aprovação humana para tag)**

## Resumo das mudanças

### Contratos adicionados
- `contracts/core/gs_patch_v1_ui_apis/001_patch_schema.sql` (no-op)
- `contracts/core/gs_patch_v1_ui_apis/002_patch_functions.sql` (RPCs mínimas)
- `contracts/core/gs_patch_v1_ui_apis/003_patch_grants_rls.sql` (no-op)
- `contracts/core/gs_patch_v1_ui_apis/004_patch_seed_demo.sql` (no-op)

### Funções adicionadas/regularizadas (Core)
- `core.list_jobs(p_tenant_id uuid)`
- `core.list_job_levels(p_tenant_id uuid, p_job_id uuid default null)`
- `core.get_job_matrix(p_tenant_id uuid)`
- `core.get_org_tree(p_tenant_id uuid)`

### Helpers internos (Core)
- `core._gs_patch_v1_ui_apis_get_correlation_id()`
- `core._gs_patch_v1_ui_apis_assert_tenant(p_tenant_id uuid)`

## Conformidade canônica

- **Core V1 congelado:** respeitado (apenas patch dedicado; sem reescrever GS fechado).
- **Multi-tenancy:** RPCs exigem `tenant_id` e validam contra o contexto (exceto Platform Owner).
- **RLS:** não alterado; funções são `SECURITY INVOKER` e operam sobre tabelas com RLS/policies já canônicas.
- **Sem FK cross-product:** nenhuma FK nova.
- **UI Contract:** retornos evitam JSON/estruturas cruas; foco em colunas primitivas para normalização.

## Riscos e mitigação

- **Risco:** baixo (read-only, `SECURITY INVOKER`, filtragem por `tenant_id`).
- **Mitigação:** validação explícita de tenant + evidência via queries MCP (ver validation report).

## Compatibilidade

- **Backward compatible:** sim (apenas adição de funções).
- **Observação:** `core.get_salary_structure_for_context(...)` **não** foi criada; contrato canônico “por contexto” permanece `core.get_salary_structure_for_job_level(...)` (ver decisão `docs/decisions/2026-01-27_core_patch_v1_ui_apis_scope.md`).
- **Nota (DB alvo):** `core.job_levels` usa `seniority_level` (não `level_number`). As RPCs retornam `level_number` mapeando `seniority_level → level_number` para estabilizar contrato para consumidores.

## Rollback (plano)

Executar (via contrato) os `DROP FUNCTION` abaixo:

```sql
drop function if exists core.get_org_tree(uuid);
drop function if exists core.get_job_matrix(uuid);
drop function if exists core.list_job_levels(uuid, uuid);
drop function if exists core.list_jobs(uuid);
drop function if exists core._gs_patch_v1_ui_apis_assert_tenant(uuid);
drop function if exists core._gs_patch_v1_ui_apis_get_correlation_id();
```

## Evidência / validação

- ✅ Execução MCP registrada em `docs/core/migration_execution_log_patch_v1_ui_apis.md`
- ✅ Evidências (queries + resultados) em `docs/core/validation_report_patch_v1_ui_apis.md`

## Recomendação

- **NÃO taguear** até:
  - execução MCP confirmada
  - `validation_report_patch_v1_ui_apis.md` completo com evidências
  - aprovação humana explícita

