# GS-DB-PATCH FK Cleanup V1 — Decisões

**Data:** 2026-02-08

---

## Por que remover FK strategy → core

- **Canon (docs/_canon):** “Proibido FK entre produtos” (01_architecture_principles, 02_db_contract_global). “Produto depender de tabela do outro produto” é proibido (10_product_rules). Strategy e Core são tratados como produtos/camadas distintas; integração deve ser **governada por contrato**, não por acoplamento físico.
- **Efeito:** FK física obriga o banco a garantir integridade referencial entre schemas e bloqueia evolução independente (deploys, versionamento de Core vs Strategy). Removendo a FK, Strategy continua a armazenar UUIDs de referência (org_unit_id, person_id, etc.) mas a validação de “existência no Core” passa a ser feita por **contrato** (funções core_assert.*), opcionalmente em triggers em write, ou na aplicação.

---

## Qual contrato foi criado

- **Schema `core_assert`** com 5 funções SECURITY DEFINER:
  - `core_assert.assert_person_exists(p_tenant_id, p_person_id)`
  - `core_assert.assert_org_unit_exists(p_tenant_id, p_org_unit_id)`
  - `core_assert.assert_cost_center_exists(p_tenant_id, p_cost_center_id)`
  - `core_assert.assert_job_exists(p_tenant_id, p_job_id)`
  - `core_assert.assert_job_level_exists(p_tenant_id, p_job_level_id)`
- Todas validam que o registro existe em Core no tenant informado; caso contrário lançam exceção. NULL para o ID é permitido (retorno imediato).
- Uso previsto: chamadas em triggers BEFORE INSERT/UPDATE nas tabelas Strategy que gravam esses IDs, ou na camada de aplicação antes do write. Neste patch **não** foram criados triggers (seção “Triggers (futuro)” em 003 está comentada).

---

## Escopo do patch

- **In scope:** Apenas FKs **strategy → core** (11 constraints). Colunas não foram removidas.
- **Out of scope:** FKs strategy → foundation (ex.: tenant_id); outras camadas; UI além do mínimo para smoke.

---

## Tabelas Strategy afetadas (drops)

| Tabela            | Constraint(s) removida(s) |
|------------------|---------------------------|
| approval_history | approver_person_id → core.people |
| budget_approvals | approver_person_id → core.people |
| budget_items     | org_unit_id → core.org_units, cost_center_id → core.cost_centers |
| initiatives      | owner_person_id → core.people |
| key_results      | owner_person_id → core.people |
| objectives       | owner_person_id → core.people |
| staffing_demands | org_unit_id, cost_center_id, job_id, job_level_id → core |

Nenhuma trigger de validação foi adicionada neste patch; pode ser feita em etapa futura usando core_assert.*.
