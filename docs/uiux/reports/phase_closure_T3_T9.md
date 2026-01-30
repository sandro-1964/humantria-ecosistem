# Fechamento de fase — T3 a T9

**Data:** 2026-01-30  
**Branch:** qa-t9-supabase-integration  
**Objetivo:** Encerrar a fase de testes (T3–T9) com evidência máxima, mínimo risco, sem SQL Editor.

---

## Escopo

- **T3–T8:** Infra e patches (strategy, components, bridges, core, foundation contratos).
- **T9:** Integração Supabase — foundation (schema, tables, functions, RLS, seed) aplicada; testes de integração Vitest; validação via MCP somente leitura.

---

## Commits relevantes (últimos)

- `be9de12` ci(t9): add manual workflow for Supabase integration tests + docs(qa)
- `f9dbd77` feat(diag): expose supabaseConfigured in /__diag/meta
- `f89c18f` test(t9): vitest integration harness + foundation/spec + helpers
- `9dbf4ff` chore(qa): bootstrap T9 integration structure

---

## Checks realizados (fechamento)

| Check | Resultado |
|-------|-----------|
| Branch | qa-t9-supabase-integration |
| Schemas (foundation, core, strategy) | OK (MCP) |
| Tabelas foundation essenciais | OK (tenants, tenant_profiles, memberships, events_outbox, audit_log) |
| Policies foundation | 81 OK |
| Policies tenants (2) | OK |
| RLS por tabela (pg_tables) | OK (33 com RLS, 15 catálogos sem RLS) |
| foundation.tenants count | 1 |
| strategy.objectives count | 3 |
| DIAG (/__diag/meta) | Disponível (SPA) |
| test:int | FAIL — "Invalid schema: foundation" |

---

## Evidências

- Queries e outputs reais: [docs/qa/t9_integration_report.md](../../qa/t9_integration_report.md)
- Contrato tenant temporário e cleanup: [docs/qa/test_data_contract.md](../../qa/test_data_contract.md)
- Plano T9: [docs/qa/t9_integration_plan.md](../../qa/t9_integration_plan.md)

---

## Riscos / decisões

1. **test:int FAIL:** O schema `foundation` existe no banco mas não está exposto na API REST do Supabase (PostgREST). É necessário expor o schema `foundation` nas configurações do projeto (Dashboard → API → Expose schema) para os testes de integração passarem sem alterar código dos testes.
2. **Seed (005):** Não executado no fechamento; decisão de gate humano para qualquer alteração de dados. Seed demo pode ser aplicado posteriormente com GO explícito.
3. **Working tree:** No momento do fechamento havia alterações locais (003_functions.sql, 004_rls.sql, .cursor/mcp.json, src/i18n/index.ts, pasta scripts/). Commit de fechamento inclui apenas docs.

---

## Próximos passos

- Expor schema `foundation` na API do projeto Supabase (configuração PostgREST) para test:int passar.
- Opcional: executar 005_seed_demo.sql com GO do comandante para ambiente demo.
- Revisão humana das evidências; depois merge/tag conforme ritual.

---

## Confirmação

- **Nenhuma policy foi alterada nesta execução; somente leitura + testes.**
- **Seed apenas se GO explícito do comandante.**

---

## Fechamento canônico (safe mode)

### Resumo executivo

- T9 encerrado em modo seguro: **somente leitura + organização + evidências**. Nenhuma migration, SQL, DROP/CREATE, alteração de policies/RLS ou Supabase.
- Repo: `.cursor/mcp.json` e `src/i18n/index.ts` restaurados; script de migrations movido para `docs/qa/evidence/` (histórico).

### O que foi validado

- **MCP:** query listar schemas — foundation, core, strategy, public presentes.
- **Banco:** intacto (nenhuma alteração).
- **Policies:** intactas (81 no foundation).
- **test:int:** FAIL até expor schema `foundation` na API (Supabase Dashboard → API → Expose schemas).

### Riscos eliminados

- Nenhuma alteração de banco ou policies nesta execução.
- Nenhum script de migration executado no fechamento.

### Decisão

**T9 encerrado.** Evidências versionadas em docs. test:int ficará verde após expor schemas no Supabase (ação manual). Aguardar validação humana antes de merge/tag.
