# HUMANTRÍA — BRIDGES — GS-PATCH V1 — UI Ops — Final Audit Report

**Data:** 2026-01-27  
**Branch:** `bridges-gs-patch-v1-ui-ops`  
**Status:** ✅ **VALIDADO (aguardando aprovação humana para tag)**

## Resumo das mudanças

### Contratos adicionados

- `contracts/bridges/gs_patch_v1_ui_ops/001_patch_schema.sql` (schema idempotente)
- `contracts/bridges/gs_patch_v1_ui_ops/002_patch_functions.sql` (RPCs mínimas)
- `contracts/bridges/gs_patch_v1_ui_ops/003_patch_grants_rls.sql` (grants mínimos; revoke public)
- `contracts/bridges/gs_patch_v1_ui_ops/004_patch_seed_demo.sql` (no-op)

### Funções adicionadas (bridges)

- `bridges.list_outbox_events(p_tenant_id uuid, p_limit int default 50, p_status text default null)`
- `bridges.get_outbox_event(p_tenant_id uuid, p_event_id uuid)`
- `bridges.list_failed_events(p_tenant_id uuid, p_limit int default 50)`
- `bridges.request_event_replay(p_tenant_id uuid, p_event_id uuid, p_reason text)`

### Helpers internos (bridges)

- `bridges._gs_patch_v1_ui_ops_get_correlation_id()`
- `bridges._gs_patch_v1_ui_ops_assert_tenant(p_tenant_id uuid)`

## Conformidade canônica

- **Bridge-first:** respeitado (opera sobre `foundation.events_outbox`).
- **Multi-tenancy:** RPCs exigem `tenant_id` e validam contra o contexto (exceto Platform Owner).
- **RLS:** não alterado; funções são `SECURITY INVOKER` e operam sobre tabela com RLS/policies canônicas.
- **Sem engine novo:** `request_event_replay` apenas registra decisão/evidência e publica evento; não executa replay.
- **Sem JSON cru para UI:** RPCs não retornam `payload` do outbox.

## Riscos e mitigação

- **Risco:** baixo/médio (há mutação: cria audit log funcional e publica evento no outbox).
- **Mitigação:** restrição de role (Tenant Admin/Platform Owner), validação explícita de tenant, evidências MCP (validation report).

## Rollback (plano)

Executar (via contrato) os `DROP FUNCTION` abaixo:

```sql
drop function if exists bridges.request_event_replay(uuid, uuid, text);
drop function if exists bridges.list_failed_events(uuid, int);
drop function if exists bridges.get_outbox_event(uuid, uuid);
drop function if exists bridges.list_outbox_events(uuid, int, text);
drop function if exists bridges._gs_patch_v1_ui_ops_assert_tenant(uuid);
drop function if exists bridges._gs_patch_v1_ui_ops_get_correlation_id();
```

> Opcional (se necessário): `drop schema bridges;` **não recomendado** se houver outros usos do schema no ambiente.

## Evidência / validação

- ✅ Execução MCP registrada em `docs/bridges/migration_execution_log_patch_v1_ui_ops.md`
- ✅ Evidências (queries + resultados) em `docs/bridges/validation_report_patch_v1_ui_ops.md`
- ✅ Escopo fechado definido em `docs/decisions/2026-01-27_bridges_patch_v1_ui_ops_scope.md`

## Recomendação

- **NÃO taguear** até:
  - execução MCP confirmada
  - `validation_report_patch_v1_ui_ops.md` completo com evidências reais
  - aprovação humana explícita

