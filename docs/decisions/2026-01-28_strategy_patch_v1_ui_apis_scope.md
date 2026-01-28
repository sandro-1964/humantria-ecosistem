# 2026-01-28 — strategy_patch_v1_ui_apis_scope

## Contexto

A UI precisa de um conjunto mínimo de RPCs **read-only** para operar Strategy & Rewards V1 de forma determinística e compatível com o **UI Contract** (sem “JSON cru” e com normalização via `toText()`/adapter).

O Core V1 está congelado; este patch não reabre GS fechado e não cria engine nova.

## Decisão (escopo fechado)

- **Criar** um GS-PATCH dedicado em `contracts/strategy/gs_patch_v1_ui_apis/` com funções **SECURITY INVOKER**, **multi-tenant** e compatíveis com RLS existente.
- **Adicionar** apenas RPCs mínimas de leitura para UI:
  - `list_cycles`
  - `get_cycle`
  - `list_initiatives`
  - `get_initiative`
  - `get_portfolio_snapshot` (agregado determinístico sem JSON)
- **Não** criar tabelas/visões novas; **não** alterar tabelas existentes.
- **Não** relaxar RLS; nenhuma policy será criada/alterada.
- **Não** expor `json/jsonb/arrays` no retorno das RPCs. Se houver campo inevitável, converter para `TEXT` sanitizado e truncado; preferir omitir.
- **Não** criar seed; `004_patch_seed_demo.sql` é no-op.

## Critérios de aceite

- Migrations aplicadas via Supabase MCP (001→004), registradas em `docs/strategy/migration_execution_log_patch_v1_ui_apis.md`.
- Evidências objetivas no validation report:
  - `prosecdef=false` (SECURITY INVOKER)
  - smoke tests com tenant demo (ou tenant com dados) e outputs anexados
  - erro governado `TENANT_MISMATCH` com `correlation_id`
  - prova “sem JSON cru” nas assinaturas das funções
- Auditoria final com rollback (`DROP FUNCTION`) em `docs/strategy/final_audit_report_patch_v1_ui_apis.md`.

## Rollback

- `DROP FUNCTION` das funções adicionadas por este patch (listar no audit report).

