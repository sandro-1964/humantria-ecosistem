# GS-DB-PATCH FK Cleanup V1 — Validation Report

**Data:** 2026-02-08  
**Objetivo:** Remover FKs strategy → core sem quebrar Strategy UI V2.2.  
**Projeto Supabase:** Humantria (vpsqhmklecjvbnlhktbg)

---

## Pre-flight

### git status -sb

```
## feat/strategy-ui-integration-v1...origin/feat/strategy-ui-integration-v1
```

### npm run build

```
> humantria@0.0.0 build
> tsc -b && vite build

vite v7.3.1 building client environment for production...
✓ 1735 modules transformed.
...
✓ built in 2.92s
```

**Resultado:** PASS (exit 0).

---

## Introspecção — FKs strategy → core

Query: ver [contracts/strategy/gs_patch_fk_cleanup_v1/001_introspection.sql](contracts/strategy/gs_patch_fk_cleanup_v1/001_introspection.sql) (pg_catalog).

### Output (executado via MCP)

| table_schema | table_name       | column_name         | constraint_name                          | referenced_schema | referenced_table | referenced_column |
|--------------|------------------|---------------------|-----------------------------------------|------------------|------------------|--------------------|
| strategy     | approval_history | approver_person_id  | approval_history_approver_person_id_fkey | core             | people           | id                 |
| strategy     | budget_approvals  | approver_person_id  | budget_approvals_approver_person_id_fkey  | core             | people           | id                 |
| strategy     | budget_items      | cost_center_id      | budget_items_cost_center_id_fkey          | core             | cost_centers     | id                 |
| strategy     | budget_items      | org_unit_id         | budget_items_org_unit_id_fkey            | core             | org_units        | id                 |
| strategy     | initiatives       | owner_person_id     | initiatives_owner_person_id_fkey         | core             | people           | id                 |
| strategy     | key_results       | owner_person_id     | key_results_owner_person_id_fkey         | core             | people           | id                 |
| strategy     | objectives        | owner_person_id     | objectives_owner_person_id_fkey           | core             | people           | id                 |
| strategy     | staffing_demands  | cost_center_id      | staffing_demands_cost_center_id_fkey     | core             | cost_centers     | id                 |
| strategy     | staffing_demands  | job_id              | staffing_demands_job_id_fkey             | core             | jobs             | id                 |
| strategy     | staffing_demands  | job_level_id        | staffing_demands_job_level_id_fkey       | core             | job_levels       | id                 |
| strategy     | staffing_demands  | org_unit_id         | staffing_demands_org_unit_id_fkey        | core             | org_units        | id                 |

**Total:** 11 constraints.

---

## Core contract surfaces (core_assert)

- Migração aplicada: `gs_patch_fk_cleanup_v1_core_contract_surfaces` (schema core_assert + 5 funções).
- GRANT EXECUTE para `authenticated`, `service_role`.

---

## Drops executados

- Migração aplicada: `gs_patch_fk_cleanup_v1_fk_drop_and_rewire` (11 DROP CONSTRAINT).
- Colunas mantidas (UUIDs como referência lógica).

---

## Validação pós-patch

### 1) Reexecução introspecção (FKs strategy → core)

**Resultado:** `[]` (0 linhas). Nenhuma FK strategy→core restante.

### 2) Contagens (objectives, key_results, initiatives)

| tbl                  | cnt |
|----------------------|-----|
| strategy.objectives   | 11  |
| strategy.key_results | 9   |
| strategy.initiatives | 15  |

---

## Smoke

### npm run build

```
> tsc -b && vite build
✓ 1735 modules transformed.
✓ built in 3.01s
```

**Resultado:** PASS (exit 0).

### Smoke manual (obrigatório)

- Executar `npm run dev`, abrir `/login` → autenticar → navegar para `/strategy`.
- Confirmar que a lista real (objectives) carrega sem regressão (11 linhas no cenário atual).
- Registrar aqui qualquer falha ou observação.

---

## Checklist final

- [x] Pre-flight ok
- [x] Introspecção registrada (11 constraints)
- [x] core_assert criado e aplicado
- [x] Drops aplicados (0 FKs strategy→core restantes)
- [x] Validação 004 executada (0 linhas na reexecução da intro)
- [x] npm run build PASS
- [ ] /strategy carrega sem regressão (validar manualmente)
