# GS-DB-PATCH FK Cleanup V1 — Plano (resumo)

**Data:** 2026-02-08  
**Branch:** feat/strategy-ui-integration-v1  
**Objetivo:** Remover FKs strategy → core no banco sem quebrar Strategy UI V2.2.

---

## O que foi feito

1. **Pre-flight** — `git status -sb` (limpo), `npm run build` (PASS). Registrado em validation_report.md.

2. **Introspecção** — Query em pg_catalog para listar FKs com `table_schema = 'strategy'` e `referenced_schema = 'core'`. Resultado: 11 constraints (approval_history, budget_approvals, budget_items, initiatives, key_results, objectives, staffing_demands). Script: [contracts/strategy/gs_patch_fk_cleanup_v1/001_introspection.sql](../../../contracts/strategy/gs_patch_fk_cleanup_v1/001_introspection.sql).

3. **Core contract surfaces** — Criado schema `core_assert` e 5 funções SECURITY DEFINER: `assert_person_exists`, `assert_org_unit_exists`, `assert_cost_center_exists`, `assert_job_exists`, `assert_job_level_exists`. Todas validam tenant_id e lançam exceção se a entidade não existir. Contrato em [contracts/core/gs_patch_fk_cleanup_v1/002_core_contract_surfaces.sql](../../../contracts/core/gs_patch_fk_cleanup_v1/002_core_contract_surfaces.sql). Migração aplicada via MCP: `gs_patch_fk_cleanup_v1_core_contract_surfaces`.

4. **Drop FK** — Removidas as 11 constraints strategy→core; colunas UUID mantidas. Nenhum trigger criado (seção “Triggers (futuro)” deixada comentada). Script: [contracts/strategy/gs_patch_fk_cleanup_v1/003_fk_drop_and_rewire.sql](../../../contracts/strategy/gs_patch_fk_cleanup_v1/003_fk_drop_and_rewire.sql). Migração aplicada: `gs_patch_fk_cleanup_v1_fk_drop_and_rewire`.

5. **Validação pós-patch** — Reexecução da query de introspecção: **0 linhas** (nenhuma FK strategy→core). Contagens: strategy.objectives 11, strategy.key_results 9, strategy.initiatives 15. Script: [contracts/strategy/gs_patch_fk_cleanup_v1/004_validation_queries.sql](../../../contracts/strategy/gs_patch_fk_cleanup_v1/004_validation_queries.sql).

6. **Smoke** — `npm run build` PASS. Smoke manual: `npm run dev` e validar `/login` → `/strategy` (lista real sem regressão). Evidências em validation_report.md.

---

## Paths canônicos

- Superfícies do Core: `contracts/core/gs_patch_fk_cleanup_v1/`
- Drops/rewire Strategy: `contracts/strategy/gs_patch_fk_cleanup_v1/`

---

## Pausa canônica

Antes de commit/tag: confirmação explícita do responsável. Frase: “Pre-flight ok, introspecção ok (lista de constraints anexada), core_assert criado ok, drops executados ok, validação ok, smoke ok. Posso commitar?”
