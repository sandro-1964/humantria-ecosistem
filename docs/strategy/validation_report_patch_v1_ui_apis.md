# HUMANTRÍA — STRATEGY — GS-PATCH V1 — UI APIs (READ-ONLY) — Validation Report

**Data:** 2026-01-28  
**Branch:** `strategy-gs-patch-v1-ui-apis`  
**Contrato:** `contracts/strategy/gs_patch_v1_ui_apis/*`  
**Supabase project:** `vpsqhmklecjvbnlhktbg`

## Escopo validado

- RPCs (read-only; tenant-safe; sem JSON cru):  
  - `strategy.list_cycles(p_tenant_id uuid, p_limit int default 50)`
  - `strategy.get_cycle(p_tenant_id uuid, p_cycle_id uuid)`
  - `strategy.list_initiatives(p_tenant_id uuid, p_cycle_id uuid default null, p_limit int default 50)`
  - `strategy.get_initiative(p_tenant_id uuid, p_initiative_id uuid)`
  - `strategy.get_portfolio_snapshot(p_tenant_id uuid, p_cycle_id uuid)`

## Checklist canônico (pass/fail)

### Contrato e escopo
- [x] Escopo fechado respeitado (patch-only; sem engine nova; read-only)
- [x] Sem FK cross-product
- [x] Sem alterações em tabelas (apenas funções)

### Multi-tenancy e segurança
- [x] Funções novas são `SECURITY INVOKER` (`prosecdef=false`)
- [x] `tenant_id` validado nas RPCs (exceto Platform Owner)
- [x] RLS não foi relaxado (nenhuma policy criada/alterada)
- [x] Grants mínimos (authenticated) + revoke public em funções públicas

### UI Contract / Runtime
- [x] RPCs não retornam `json/jsonb/arrays` (sem “JSON cru”)
- [x] Retornos são colunas primitivas (UUID/TEXT/INT/NUMERIC/BOOLEAN/TIMESTAMPTZ)
- [x] Erros incluem `correlation_id` (best-effort)

## Evidências (DB inspection + queries)

> **Nota:** executar via Supabase MCP.  
> Onde indicado, capturar resultados reais (SQL + output) abaixo.

### A) Descobrir schemas Strategy/Rewards

```sql
select nspname
from pg_namespace
where nspname ilike '%strategy%' or nspname ilike '%reward%'
order by 1;
```

**Resultado (MCP `execute_sql`):**

```json
[{"nspname":"strategy"}]
```

### B) Listar tabelas (por schema)

```sql
select table_schema, table_name
from information_schema.tables
where table_schema = :schema and table_type = 'BASE TABLE'
order by 1,2;
```

**Resultado:** _(preencher por schema)_

Schema `strategy`:

```json
[{"table_schema":"strategy","table_name":"ai_simulations"},{"table_schema":"strategy","table_name":"ai_suggestions"},{"table_schema":"strategy","table_name":"approval_history"},{"table_schema":"strategy","table_name":"approval_requests"},{"table_schema":"strategy","table_name":"approval_workflows"},{"table_schema":"strategy","table_name":"budget_actuals"},{"table_schema":"strategy","table_name":"budget_approvals"},{"table_schema":"strategy","table_name":"budget_currencies"},{"table_schema":"strategy","table_name":"budget_items"},{"table_schema":"strategy","table_name":"budget_templates"},{"table_schema":"strategy","table_name":"budget_versions"},{"table_schema":"strategy","table_name":"dashboard_kpis"},{"table_schema":"strategy","table_name":"executive_dashboards"},{"table_schema":"strategy","table_name":"export_jobs"},{"table_schema":"strategy","table_name":"key_results"},{"table_schema":"strategy","table_name":"objective_evidence"},{"table_schema":"strategy","table_name":"objective_history"},{"table_schema":"strategy","table_name":"objective_templates"},{"table_schema":"strategy","table_name":"objectives"},{"table_schema":"strategy","table_name":"risk_alerts"},{"table_schema":"strategy","table_name":"staffing_actuals"},{"table_schema":"strategy","table_name":"staffing_calculated_costs"},{"table_schema":"strategy","table_name":"staffing_demands"},{"table_schema":"strategy","table_name":"staffing_plans"},{"table_schema":"strategy","table_name":"staffing_templates"}]
```

### C) Mapear tabelas candidatas (fixar nomes reais)

- **STRATEGY_SCHEMA**: _(preencher)_
- **CYCLE_TABLE**: _(preencher)_
- **INITIATIVE_TABLE**: _(preencher)_
- **Relação ciclo↔iniciativa (coluna)**: _(ex.: `cycle_id` / `plan_id` / `null`)_

- **STRATEGY_SCHEMA**: `strategy`
- **CYCLE_TABLE**: `objectives` (derivação por `cycle_type + cycle_start_date + cycle_end_date`)
- **INITIATIVE_TABLE**: `objectives`
- **Relação ciclo↔iniciativa (coluna)**: `cycle_type`, `cycle_start_date`, `cycle_end_date` (o `cycle_id` da API é determinístico e derivado desses campos)

### D) Inspecionar colunas (tabelas escolhidas)

```sql
select table_schema, table_name, column_name, data_type, is_nullable
from information_schema.columns
where table_schema = :schema
  and table_name in (:cycle_table, :initiative_table)
order by table_name, ordinal_position;
```

**Resultado:** _(preencher)_

```json
[{"column_name":"id","data_type":"uuid","is_nullable":"NO"},{"column_name":"tenant_id","data_type":"uuid","is_nullable":"NO"},{"column_name":"template_id","data_type":"uuid","is_nullable":"YES"},{"column_name":"code","data_type":"text","is_nullable":"NO"},{"column_name":"title","data_type":"text","is_nullable":"NO"},{"column_name":"description","data_type":"text","is_nullable":"YES"},{"column_name":"methodology_type","data_type":"text","is_nullable":"NO"},{"column_name":"cycle_type","data_type":"text","is_nullable":"NO"},{"column_name":"cycle_start_date","data_type":"date","is_nullable":"NO"},{"column_name":"cycle_end_date","data_type":"date","is_nullable":"NO"},{"column_name":"owner_person_id","data_type":"uuid","is_nullable":"YES"},{"column_name":"status","data_type":"text","is_nullable":"NO"},{"column_name":"metadata","data_type":"jsonb","is_nullable":"YES"},{"column_name":"created_at","data_type":"timestamp with time zone","is_nullable":"NO"},{"column_name":"updated_at","data_type":"timestamp with time zone","is_nullable":"NO"},{"column_name":"created_by","data_type":"uuid","is_nullable":"YES"},{"column_name":"updated_by","data_type":"uuid","is_nullable":"YES"}]
```

> Nota UI Contract: `objectives.metadata (jsonb)` existe na tabela, mas foi **omitido** das RPCs (sem JSON cru no retorno).

### E) Validar RLS ativo nas tabelas alvo

```sql
select n.nspname as schema, c.relname as table, c.relrowsecurity as rls
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = :schema
  and c.relname in (:cycle_table, :initiative_table);
```

**Resultado:** _(preencher)_

```json
[{"schema":"strategy","table":"objectives","rls":true}]
```

### F) SECURITY INVOKER confirm (catálogo)

```sql
select
  n.nspname as schema,
  p.proname as function_name,
  p.prosecdef as is_security_definer
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = :schema
  and p.proname in (
    '_gs_patch_v1_ui_apis_get_correlation_id',
    '_gs_patch_v1_ui_apis_assert_tenant',
    'list_cycles',
    'get_cycle',
    'list_initiatives',
    'get_initiative',
    'get_portfolio_snapshot'
  )
order by p.proname;
```

**Resultado:** _(preencher; deve ser `false` para todas)_

```json
[{"schema":"strategy","function_name":"_gs_patch_v1_ui_apis_assert_tenant","is_security_definer":false},{"schema":"strategy","function_name":"_gs_patch_v1_ui_apis_cycle_id","is_security_definer":false},{"schema":"strategy","function_name":"_gs_patch_v1_ui_apis_get_correlation_id","is_security_definer":false},{"schema":"strategy","function_name":"get_cycle","is_security_definer":false},{"schema":"strategy","function_name":"get_initiative","is_security_definer":false},{"schema":"strategy","function_name":"get_portfolio_snapshot","is_security_definer":false},{"schema":"strategy","function_name":"list_cycles","is_security_definer":false},{"schema":"strategy","function_name":"list_initiatives","is_security_definer":false}]
```

### G) Smoke tests (tenant demo ou tenant com dados)

> Preferência: tenant demo `00000000-0000-0000-0000-000000000001`.  
> Se não houver dados, escolher um `tenant_id` existente no produto (sem criar seed).

```sql
select * from strategy.list_cycles(:tenant_id, 5);
```

```sql
select * from strategy.list_initiatives(:tenant_id, null, 5);
```

**Parâmetros usados (tenant demo):** `tenant_id = 00000000-0000-0000-0000-000000000001`

**Resultado — `strategy.list_cycles(tenant_id, 5)`**

```json
[{"cycle_id":"a8037120-72c1-e311-f129-2b4927ffa89a","tenant_id":"00000000-0000-0000-0000-000000000001","cycle_type":"annual","start_date":"2026-01-01","end_date":"2026-12-31","objectives_total":1,"created_at_min":"2026-01-26 18:43:39.600727+00","updated_at_max":"2026-01-26 18:43:39.600727+00"},{"cycle_id":"74f89179-2e3c-8de4-6146-d02771aa9b0f","tenant_id":"00000000-0000-0000-0000-000000000001","cycle_type":"quarterly","start_date":"2026-01-01","end_date":"2026-03-31","objectives_total":2,"created_at_min":"2026-01-26 18:43:39.600727+00","updated_at_max":"2026-01-26 18:43:39.600727+00"}]
```

**Resultado — `strategy.list_initiatives(tenant_id, null, 5)`**

```json
[{"initiative_id":"f0000000-0000-0000-0000-000000000001","tenant_id":"00000000-0000-0000-0000-000000000001","cycle_id":"74f89179-2e3c-8de4-6146-d02771aa9b0f","code":"OKR-Q1-2026","title":"Crescer receita em 30% no Q1","description":"Objetivo de crescimento de receita para Q1 2026","status":"active","owner_person_id":"c3000000-0000-0000-0000-000000000001","cycle_type":"quarterly","cycle_start_date":"2026-01-01","cycle_end_date":"2026-03-31","created_at":"2026-01-26 18:43:39.600727+00","updated_at":"2026-01-26 18:43:39.600727+00"},{"initiative_id":"f0000000-0000-0000-0000-000000000002","tenant_id":"00000000-0000-0000-0000-000000000001","cycle_id":"74f89179-2e3c-8de4-6146-d02771aa9b0f","code":"OKR-ENG-Q1-2026","title":"Melhorar qualidade do produto","description":"Objetivo de qualidade para time de Engenharia","status":"active","owner_person_id":"c3000000-0000-0000-0000-000000000002","cycle_type":"quarterly","cycle_start_date":"2026-01-01","cycle_end_date":"2026-03-31","created_at":"2026-01-26 18:43:39.600727+00","updated_at":"2026-01-26 18:43:39.600727+00"},{"initiative_id":"f0000000-0000-0000-0000-000000000003","tenant_id":"00000000-0000-0000-0000-000000000001","cycle_id":"a8037120-72c1-e311-f129-2b4927ffa89a","code":"BSC-2026","title":"BSC Corporativo 2026","description":"Balanced Scorecard corporativo para 2026","status":"active","owner_person_id":"c3000000-0000-0000-0000-000000000001","cycle_type":"annual","cycle_start_date":"2026-01-01","cycle_end_date":"2026-12-31","created_at":"2026-01-26 18:43:39.600727+00","updated_at":"2026-01-26 18:43:39.600727+00"}]
```

**Get (pegar um id retornado):**

```sql
select * from strategy.get_cycle(:tenant_id, :cycle_id);
```

```sql
select * from strategy.get_initiative(:tenant_id, :initiative_id);
```

```sql
select * from strategy.get_portfolio_snapshot(:tenant_id, :cycle_id);
```

**Resultado — `strategy.get_cycle(tenant_id, 74f89179-2e3c-8de4-6146-d02771aa9b0f)`**

```json
[{"cycle_id":"74f89179-2e3c-8de4-6146-d02771aa9b0f","tenant_id":"00000000-0000-0000-0000-000000000001","cycle_type":"quarterly","start_date":"2026-01-01","end_date":"2026-03-31","objectives_total":2,"created_at_min":"2026-01-26 18:43:39.600727+00","updated_at_max":"2026-01-26 18:43:39.600727+00"}]
```

**Resultado — `strategy.get_initiative(tenant_id, f0000000-0000-0000-0000-000000000001)`**

```json
[{"initiative_id":"f0000000-0000-0000-0000-000000000001","tenant_id":"00000000-0000-0000-0000-000000000001","cycle_id":"74f89179-2e3c-8de4-6146-d02771aa9b0f","code":"OKR-Q1-2026","title":"Crescer receita em 30% no Q1","description":"Objetivo de crescimento de receita para Q1 2026","status":"active","owner_person_id":"c3000000-0000-0000-0000-000000000001","cycle_type":"quarterly","cycle_start_date":"2026-01-01","cycle_end_date":"2026-03-31","created_at":"2026-01-26 18:43:39.600727+00","updated_at":"2026-01-26 18:43:39.600727+00"}]
```

**Resultado — `strategy.get_portfolio_snapshot(tenant_id, 74f89179-2e3c-8de4-6146-d02771aa9b0f)`**

```json
[{"tenant_id":"00000000-0000-0000-0000-000000000001","cycle_id":"74f89179-2e3c-8de4-6146-d02771aa9b0f","objectives_total":2,"objectives_active":2,"objectives_completed":0,"objectives_blocked":0,"updated_at_max":"2026-01-26 18:43:39.600727+00"}]
```

### H) Segurança — tenant mismatch (espera erro governado)

> Executar com contexto autenticado do tenant A, passando `p_tenant_id` de tenant B.

```sql
select * from strategy.list_cycles('11111111-1111-1111-1111-111111111111'::uuid, 1);
```

**Esperado:** erro com mensagem curta + `DETAIL` contendo `{"code":"TENANT_MISMATCH","correlation_id":...}`  
**Resultado:**

```json
[{"mismatch_message":"tenant_id inválido","mismatch_detail":"{\"code\": \"TENANT_MISMATCH\", \"correlation_id\": \"bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb\"}"}]
```

### I) Prova “sem JSON cru” (assinatura do retorno)

> Provar que a assinatura `RETURNS TABLE` não contém `json/jsonb` nem `[]`/arrays.

```sql
select
  n.nspname as schema,
  p.proname as function_name,
  pg_get_function_result(p.oid) as result_signature
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = :schema
  and p.proname in ('list_cycles','get_cycle','list_initiatives','get_initiative','get_portfolio_snapshot')
order by p.proname;
```

**Resultado:** _(preencher)_

```json
[{"schema":"strategy","function_name":"get_cycle","result_signature":"TABLE(cycle_id uuid, tenant_id uuid, cycle_type text, start_date date, end_date date, objectives_total integer, created_at_min timestamp with time zone, updated_at_max timestamp with time zone)"},{"schema":"strategy","function_name":"get_initiative","result_signature":"TABLE(initiative_id uuid, tenant_id uuid, cycle_id uuid, code text, title text, description text, status text, owner_person_id uuid, cycle_type text, cycle_start_date date, cycle_end_date date, created_at timestamp with time zone, updated_at timestamp with time zone)"},{"schema":"strategy","function_name":"get_portfolio_snapshot","result_signature":"TABLE(tenant_id uuid, cycle_id uuid, objectives_total integer, objectives_active integer, objectives_completed integer, objectives_blocked integer, updated_at_max timestamp with time zone)"},{"schema":"strategy","function_name":"list_cycles","result_signature":"TABLE(cycle_id uuid, tenant_id uuid, cycle_type text, start_date date, end_date date, objectives_total integer, created_at_min timestamp with time zone, updated_at_max timestamp with time zone)"},{"schema":"strategy","function_name":"list_initiatives","result_signature":"TABLE(initiative_id uuid, tenant_id uuid, cycle_id uuid, code text, title text, description text, status text, owner_person_id uuid, cycle_type text, cycle_start_date date, cycle_end_date date, created_at timestamp with time zone, updated_at timestamp with time zone)"}]
```

## Conclusão

**Status:** ✅ VALIDADO  

**Nota:** se não existir schema/tabelas Strategy no DB alvo, registrar “patch não aplicável (Strategy inexistente no DB)” e não aplicar 002/003.

