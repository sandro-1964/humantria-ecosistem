# HUMANTRÍA — STRATEGY — GS-PATCH V1 — UI APIs (READ-ONLY) — Final Audit Report

**Data:** 2026-01-28  
**Branch:** `strategy-gs-patch-v1-ui-apis`  
**Status:** ✅ **VALIDADO (aguardando aprovação humana para tag)**

## Resumo das mudanças

### Contratos adicionados

- `contracts/strategy/gs_patch_v1_ui_apis/001_patch_schema.sql` (no-op)
- `contracts/strategy/gs_patch_v1_ui_apis/002_patch_functions.sql` (RPCs mínimas; read-only)
- `contracts/strategy/gs_patch_v1_ui_apis/003_patch_grants_rls.sql` (grants mínimos; sem relaxar RLS)
- `contracts/strategy/gs_patch_v1_ui_apis/004_patch_seed_demo.sql` (no-op)

### Funções adicionadas (Strategy)

- `strategy.list_cycles(p_tenant_id uuid, p_limit int default 50)` (**ciclos derivados** de `strategy.objectives.cycle_*`)
- `strategy.get_cycle(p_tenant_id uuid, p_cycle_id uuid)` (**ciclo derivado**)
- `strategy.list_initiatives(p_tenant_id uuid, p_cycle_id uuid default null, p_limit int default 50)` (`objectives`)
- `strategy.get_initiative(p_tenant_id uuid, p_initiative_id uuid)` (`objectives`)
- `strategy.get_portfolio_snapshot(p_tenant_id uuid, p_cycle_id uuid)` (agregado determinístico sem JSON)

### Helpers internos (Strategy)

- `strategy._gs_patch_v1_ui_apis_get_correlation_id()`
- `strategy._gs_patch_v1_ui_apis_assert_tenant(p_tenant_id uuid)`
- `strategy._gs_patch_v1_ui_apis_cycle_id(p_tenant_id uuid, p_cycle_type text, p_cycle_start_date date, p_cycle_end_date date)` (determinístico; **não** exposto via grants)

## Conformidade canônica

- **Patch-only:** respeitado (sem features; sem engine nova; read-only).
- **Multi-tenancy:** RPCs exigem `tenant_id` e validam contra o contexto (exceto Platform Owner).
- **RLS:** não alterado; funções são `SECURITY INVOKER` e dependem de RLS/policies existentes.
- **UI Contract:** sem JSON cru no retorno (apenas tipos primitivos; quando inevitável, `TEXT` truncado/sanitizado).

## Riscos e limitações

- **Risco:** baixo (read-only).
- **Limitação:** não há tabela `strategy.cycles` no DB alvo; `cycle_id` é **derivado determinísticamente** dos campos `cycle_*` em `strategy.objectives`. Isso evita criar estruturas novas e mantém contrato estável para a UI.

## Rollback (plano)

Executar (via contrato) os `DROP FUNCTION` abaixo (ajustar `<STRATEGY_SCHEMA>` conforme aplicado):

```sql
drop function if exists strategy.get_portfolio_snapshot(uuid, uuid);
drop function if exists strategy.get_initiative(uuid, uuid);
drop function if exists strategy.list_initiatives(uuid, uuid, int);
drop function if exists strategy.get_cycle(uuid, uuid);
drop function if exists strategy.list_cycles(uuid, int);
drop function if exists strategy._gs_patch_v1_ui_apis_cycle_id(uuid, text, date, date);
drop function if exists strategy._gs_patch_v1_ui_apis_assert_tenant(uuid);
drop function if exists strategy._gs_patch_v1_ui_apis_get_correlation_id();
```

> Não dropar schema como parte do rollback.

## Evidência / validação

- Execução MCP: `docs/strategy/migration_execution_log_patch_v1_ui_apis.md`
- Evidências (DB inspection + smoke tests + security checks): `docs/strategy/validation_report_patch_v1_ui_apis.md`
- Escopo fechado: `docs/decisions/2026-01-28_strategy_patch_v1_ui_apis_scope.md`

## Recomendação

- **NÃO taguear** até:\n  - migrations aplicadas via MCP\n  - validation report completo com evidências reais\n  - aprovação humana explícita

