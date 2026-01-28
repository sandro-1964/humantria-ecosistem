# 2026-01-27 — bridges_patch_v1_ui_ops_scope

## Contexto

A fase 1 precisa de **UI troubleshooting real** para Bridge-first: inspecionar o `foundation.events_outbox` e pedir replay de forma **auditável**, sem criar engine novo e sem relaxar RLS.

## Decisão (escopo fechado)

- **Criar** um GS-PATCH dedicado em `contracts/bridges/gs_patch_v1_ui_ops/` com funções **SECURITY INVOKER**, **multi-tenant** e compatíveis com RLS existente.
- **Adicionar** apenas RPCs mínimas para UI Ops (troubleshooting), todas no schema `bridges`:
  - `bridges.list_outbox_events(p_tenant_id uuid, p_limit int default 50, p_status text default null)`
  - `bridges.get_outbox_event(p_tenant_id uuid, p_event_id uuid)`
  - `bridges.list_failed_events(p_tenant_id uuid, p_limit int default 50)`
  - `bridges.request_event_replay(p_tenant_id uuid, p_event_id uuid, p_reason text)`
- **Não** criar “engine” de replay: `bridges.request_event_replay(...)` **não executa replay**; apenas:
  - registra decisão/evidência (`foundation.audit_log_functional`)
  - publica evento `bridges.replay.requested` no outbox (`foundation.events_outbox`)
- **Não** expor `payload` do outbox via RPC (sem JSON cru para UI); somente colunas primitivas/metadata.
- **Não** alterar tabelas existentes nem relaxar RLS/policies; apenas respeitar o que já está canônico.

## Observações de segurança/tenancy

- RPCs validam `tenant_id` contra o contexto (exceto Platform Owner).
- Erros retornam mensagem curta e incluem `correlation_id` no `DETAIL` (best-effort via headers; fallback UUID).
- Mutação (pedido de replay) é restrita a **Tenant Admin** (ou Platform Owner) para evitar escrita indevida em tabelas críticas.

## Impacto

- **DB**: novas funções no schema `bridges` + grants mínimos (authenticated).
- **Seeds**: nenhum (no-op).

## Rollback

- `DROP FUNCTION` das funções adicionadas no patch (listar no final audit report).

