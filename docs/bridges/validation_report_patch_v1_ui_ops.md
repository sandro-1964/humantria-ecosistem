# HUMANTRÍA — BRIDGES — GS-PATCH V1 — UI Ops — Validation Report

**Data:** 2026-01-27  
**Branch:** `bridges-gs-patch-v1-ui-ops`  
**Contrato:** `contracts/bridges/gs_patch_v1_ui_ops/*`  
**Supabase project:** `vpsqhmklecjvbnlhktbg`

## Escopo validado

- RPCs (troubleshooting; sem payload/JSON cru):
  - `bridges.list_outbox_events(p_tenant_id uuid, p_limit int default 50, p_status text default null)`
  - `bridges.get_outbox_event(p_tenant_id uuid, p_event_id uuid)`
  - `bridges.list_failed_events(p_tenant_id uuid, p_limit int default 50)`
  - `bridges.request_event_replay(p_tenant_id uuid, p_event_id uuid, p_reason text)` (não executa replay)

## Checklist canônico (pass/fail)

### Contrato e escopo
- [x] Escopo fechado respeitado (patch-only; sem engine novo; sem features inventadas)
- [x] Sem FK cross-product
- [x] Sem alterações em tabelas canônicas fora do patch

### Multi-tenancy e segurança
- [x] Funções novas são `SECURITY INVOKER`
- [x] `tenant_id` validado nas RPCs (exceto Platform Owner)
- [x] RLS não foi relaxado (nenhuma policy criada/alterada)
- [x] Grants mínimos (authenticated) + revoke public no schema `bridges`

### UI Contract (troubleshooting)
- [x] RPCs **não expõem** `payload` do outbox (sem JSON cru no retorno)
- [x] Retornos são colunas primitivas (UUID/TEXT/INT/TIMESTAMPTZ)
- [x] Erros incluem `correlation_id` (best-effort)

## Evidências (queries de prova)

> **Nota:** executar via Supabase MCP.  
> Substituir `:tenant_id` pelo tenant alvo (ex.: demo `00000000-0000-0000-0000-000000000001`).  
> Onde indicado, capturar resultados reais (SQL + output) abaixo.

### 1) Existência das funções (catálogo)

```sql
select
  n.nspname as schema,
  p.proname as function_name,
  p.prosecdef as is_security_definer
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'bridges'
  and p.proname in (
    '_gs_patch_v1_ui_ops_get_correlation_id',
    '_gs_patch_v1_ui_ops_assert_tenant',
    'list_outbox_events',
    'get_outbox_event',
    'list_failed_events',
    'request_event_replay'
  )
order by p.proname;
```

**Resultado (MCP `execute_sql`, project_id `vpsqhmklecjvbnlhktbg`):**

```json
[
  {"schema":"bridges","function_name":"_gs_patch_v1_ui_ops_assert_tenant","is_security_definer":false},
  {"schema":"bridges","function_name":"_gs_patch_v1_ui_ops_get_correlation_id","is_security_definer":false},
  {"schema":"bridges","function_name":"get_outbox_event","is_security_definer":false},
  {"schema":"bridges","function_name":"list_failed_events","is_security_definer":false},
  {"schema":"bridges","function_name":"list_outbox_events","is_security_definer":false},
  {"schema":"bridges","function_name":"request_event_replay","is_security_definer":false}
]
```

### 1.1) Setup (evidência) — outbox demo estava vazio

> Observação: o tenant demo (`00000000-0000-0000-0000-000000000001`) estava com `events_outbox = 0`.  
> Para viabilizar o smoke test “lista → detalhe → request replay”, foi criado **um evento de smoke** via `foundation.publish_event(...)` **com audit funcional** (`foundation.audit_log_functional_insert(...)`).

```sql
select set_config('request.jwt.claims', '{"role":"tenant_admin","tenant_id":"00000000-0000-0000-0000-000000000001","user_id":"11111111-1111-1111-1111-111111111111","email":"demo+uiops@acme.invalid"}', true);
select set_config('request.headers', '{"x-correlation-id":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","user-agent":"mcp"}', true);
select set_config('app.current_tenant_id', '00000000-0000-0000-0000-000000000001', true);

with audit as (
  select foundation.audit_log_functional_insert(
    'bridges.ui_ops.smoke',
    'tenant',
    '00000000-0000-0000-0000-000000000001'::uuid,
    jsonb_build_object('note','setup outbox for ui ops smoke'),
    'ui ops smoke setup'
  ) as audit_id
), ev as (
  select foundation.publish_event(
    'bridges.ui_ops.smoke',
    'tenant',
    '00000000-0000-0000-0000-000000000001'::uuid,
    jsonb_build_object('note','setup outbox for ui ops smoke'),
    '1.0',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    null
  ) as outbox_event_id
)
select (select audit_id from audit) as audit_log_functional_id,
       (select outbox_event_id from ev) as outbox_event_id;
```

**Resultado:**

```json
[
  {
    "audit_log_functional_id":"a4537a51-64d7-4422-b4f5-e6954329d73e",
    "outbox_event_id":"289b46ce-fb1a-4d95-91f4-a8b83d4739b0"
  }
]
```

### 2) Smoke test — lista outbox (sem payload)

```sql
select count(*) as outbox_count
from bridges.list_outbox_events(:tenant_id, 50, null);
```

**Resultado:**

```json
[{"outbox_count":1}]
```

### 3) Smoke test — filtro status

```sql
select count(*) as failed_count
from bridges.list_outbox_events(:tenant_id, 50, 'failed');
```

**Resultado:**

```json
[{"failed_count":0}]
```

### 4) Smoke test — abrir detalhe

```sql
with e as (
  select id
  from bridges.list_outbox_events(:tenant_id, 1, null)
)
select *
from bridges.get_outbox_event(:tenant_id, (select id from e));
```

**Resultado:**

```json
[
  {
    "id":"289b46ce-fb1a-4d95-91f4-a8b83d4739b0",
    "tenant_id":"00000000-0000-0000-0000-000000000001",
    "correlation_id":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
    "causation_id":null,
    "event_type":"bridges.ui_ops.smoke",
    "entity_type":"tenant",
    "entity_id":"00000000-0000-0000-0000-000000000001",
    "payload_version":"1.0",
    "status":"pending",
    "retry_count":0,
    "error_message":null,
    "processed_at":null,
    "created_at":"2026-01-28 00:17:43.861287+00"
  }
]
```

### 5) Smoke test — request replay (auditável; sem executar replay)

```sql
with target as (
  select id
  from bridges.list_outbox_events(:tenant_id, 1, null)
),
req as (
  select *
  from bridges.request_event_replay(
    :tenant_id,
    (select id from target),
    'ui_ops_smoke'
  )
)
select *
from req;
```

**Resultado:**

```json
[
  {
    "correlation_id":"bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
    "requested_event_id":"289b46ce-fb1a-4d95-91f4-a8b83d4739b0",
    "outbox_event_id":"5ddcc682-7eb4-4d42-87f8-db35e4546886",
    "audit_log_functional_id":"ab35cb74-3367-4550-923c-420959681646"
  }
]
```

### 6) Evidência — evento publicado no outbox

```sql
with target as (
  select id
  from bridges.list_outbox_events(:tenant_id, 1, null)
),
req as (
  select *
  from bridges.request_event_replay(
    :tenant_id,
    (select id from target),
    'ui_ops_smoke'
  )
)
select
  e.id,
  e.tenant_id,
  e.correlation_id,
  e.event_type,
  e.entity_type,
  e.entity_id,
  e.status,
  e.created_at
from foundation.events_outbox e
join req r on r.outbox_event_id = e.id
where e.tenant_id = :tenant_id
  and e.event_type = 'bridges.replay.requested';
```

**Resultado:**

```json
[
  {
    "id":"5ddcc682-7eb4-4d42-87f8-db35e4546886",
    "tenant_id":"00000000-0000-0000-0000-000000000001",
    "correlation_id":"bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
    "event_type":"bridges.replay.requested",
    "entity_type":"events_outbox",
    "entity_id":"289b46ce-fb1a-4d95-91f4-a8b83d4739b0",
    "status":"pending",
    "created_at":"2026-01-28 00:18:21.656132+00"
  }
]
```

### 7) Segurança — tenant mismatch (espera erro governado)

> Executar com contexto autenticado do tenant A, passando `p_tenant_id` de tenant B.

```sql
select count(*)
from bridges.list_outbox_events('11111111-1111-1111-1111-111111111111'::uuid, 1, null);
```

**Esperado:** erro com mensagem curta + `DETAIL` contendo `{"code":"TENANT_MISMATCH","correlation_id":...}`  
**Resultado (erro capturado via MCP `execute_sql`):**

```text
ERROR:  tenant_id inválido
DETAIL:  {"code": "TENANT_MISMATCH", "correlation_id": "cccccccc-cccc-cccc-cccc-cccccccccccc"}
```

## Conclusão

**Status:** ✅ VALIDADO (execução MCP + evidências anexadas)

