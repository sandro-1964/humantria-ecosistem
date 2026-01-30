# T9 — Integration report (evidências)

## Data / execução

- **Data:** 2026-01-30
- **Branch:** qa-t9-supabase-integration
- **PROJECT_REF:** vpsqhmklecjvbnlhktbg (sem chaves impressas)
- **Método:** MCP Supabase (execute_sql) + terminal Cursor

---

## Gates e validações (somente leitura)

### 1.1 — Schemas relevantes existem

```sql
SELECT schema_name FROM information_schema.schemata
WHERE schema_name IN ('foundation','core','strategy') ORDER BY schema_name;
```

**Output:** `[{"schema_name":"core"},{"schema_name":"foundation"},{"schema_name":"strategy"}]`

### 1.2 — Tabelas essenciais foundation

```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema='foundation'
  AND table_name IN ('tenants','tenant_profiles','memberships','events_outbox','audit_log')
ORDER BY table_name;
```

**Output:** `[{"table_name":"audit_log"},{"table_name":"events_outbox"},{"table_name":"memberships"},{"table_name":"tenant_profiles"},{"table_name":"tenants"}]`

### 1.3 — Policies foundation = 81

```sql
SELECT COUNT(*) AS policies FROM pg_policies WHERE schemaname='foundation';
```

**Output:** `[{"policies":81}]`

### 1.4 — Policies da tabela tenants (2 esperadas)

```sql
SELECT tablename, policyname, cmd, roles
FROM pg_policies WHERE schemaname='foundation' AND tablename='tenants' ORDER BY policyname;
```

**Output:** `[{"tablename":"tenants","policyname":"policy_tenants_platform_owner_all","cmd":"ALL","roles":"{authenticated}"},{"tablename":"tenants","policyname":"policy_tenants_tenant_admin_own","cmd":"SELECT","roles":"{authenticated}"}]`

### 1.5 — RLS por tabela (foundation)

Consultado via `pg_tables` (schemaname, tablename, rowsecurity). 48 tabelas: 33 com RLS true, 15 com RLS false (catálogos globais). OK conforme contrato.

### 1.6 — Dados não tocados

- **foundation.tenants:** `SELECT COUNT(*) AS tenants_count FROM foundation.tenants;` → `[{"tenants_count":1}]`
- **strategy.objectives:** `SELECT COUNT(*) AS strategy_objectives_count FROM strategy.objectives;` → `[{"strategy_objectives_count":3}]`

---

## DIAG (/__diag/meta)

- Rota SPA: `/__diag` e `/__diag/meta` (React Router).
- `supabaseConfigured` vem de `VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY` no build.
- Requisição HTTP direta a `/__diag/meta` retorna HTML da SPA; o JSON é renderizado no cliente.
- **Evidência:** DIAG disponível; valor de `supabaseConfigured` depende do env de build (não impresso).

---

## test:int — resultado

**Comando:** `npm run test:int`

**Resultado:** **FAIL**

**Output (trecho):**

```
createTemporaryTenant error: Invalid schema: foundation
FAIL  tests/integration/supabase/foundation.spec.ts > foundation integration
Unknown Error: Invalid schema: foundation
FAIL  tests/integration/supabase/strategy.spec.ts > strategy integration
Unknown Error: Invalid schema: foundation
Test Files  2 failed (2)
Tests  3 skipped (3)
```

**Causa provável:** O schema `foundation` existe no banco (confirmado via MCP) mas não está exposto na API REST do Supabase (PostgREST). Por padrão o PostgREST expõe apenas o schema `public`; schemas customizados precisam ser expostos nas configurações do projeto (API / Expose schema).

**Nenhuma policy foi alterada nesta execução; somente leitura + testes.**

---

## SQLs aplicados (sessões anteriores)

- 001_schema.sql, 002_tables.sql, 003_functions.sql, 004_rls.sql, 005_seed_demo.sql (aplicados via script Management API em sessão anterior).
- Nesta execução de fechamento: **nenhum SQL aplicado**; apenas validações read-only.

---

## Status final

| Check              | Resultado |
|--------------------|-----------|
| Schemas            | OK (foundation, core, strategy) |
| Tabelas foundation | OK (tenants, tenant_profiles, memberships, events_outbox, audit_log) |
| Policies           | OK (81)   |
| tenants policies   | OK (2)    |
| RLS por tabela     | OK        |
| tenants_count      | 1         |
| strategy.objectives| 3         |
| test:int           | FAIL (Invalid schema: foundation) |
| DIAG               | Disponível (SPA) |

---

## Tenants criados / limpos

- Slug pattern: `int-t9-<timestamp>-<rand>`.
- Cleanup obrigatório em `afterAll` (não executado neste run pois testes falharam antes de criar tenant).

---

## Fechamento canônico (safe mode) — 2026-01-30

- **Branch:** qa-t9-supabase-integration
- **Timestamp:** execução fechamento safe mode
- **MCP — listar schemas (somente leitura):**

```sql
SELECT schema_name FROM information_schema.schemata
WHERE schema_name IN ('foundation','core','strategy','public') ORDER BY schema_name;
```

**Output:** `[{"schema_name":"core"},{"schema_name":"foundation"},{"schema_name":"public"},{"schema_name":"strategy"}]`  
**Critério:** foundation, core, strategy presentes — **OK**.

- **test:int:** **FAIL** — `Invalid schema: foundation` (schema não exposto ao PostgREST).  
  Para test:int verde: Supabase → Settings → API → Expose schemas → incluir `public`, `foundation`, `core`, `strategy`.

- **Commit hash (fechamento canônico):** `8370ca0`
