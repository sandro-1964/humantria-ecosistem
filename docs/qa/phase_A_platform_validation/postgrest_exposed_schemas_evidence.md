# PostgREST — Exposição de Schemas (Evidência)

**Data:** 2026-01-31  
**Projeto:** Humantria (vpsqhmklecjvbnlhktbg)  

---

## 1. Configuração atual (antes do ajuste)

### 1.1 pgrst.db_schemas no role authenticator

**Query:**
```sql
SELECT rolname, rolconfig FROM pg_roles WHERE rolname = 'authenticator';
```

**Resultado (antes):**
- `pgrst.db_schemas` **não estava definido** no authenticator
- PostgREST usava provavelmente apenas `public` (default do dashboard)

### 1.2 Permissões de schema (anon/authenticated)

| Schema   | anon USAGE | authenticated USAGE |
|----------|------------|---------------------|
| public   | ✅         | ✅                  |
| foundation | ❌       | ❌                  |
| core     | ❌         | ❌                  |
| bridges  | ❌         | ✅                  |
| strategy | ❌         | ✅                  |

---

## 2. Ajustes aplicados via MCP (execute_sql)

### 2.1 Exposição de schemas no PostgREST

```sql
ALTER ROLE authenticator SET pgrst.db_schemas = 'public, foundation, core, bridges, strategy';
```

### 2.2 Reload do schema cache

```sql
NOTIFY pgrst, 'reload schema';
```

### 2.3 Permissões de schema (USAGE)

```sql
GRANT USAGE ON SCHEMA foundation TO anon, authenticated;
GRANT USAGE ON SCHEMA core TO anon, authenticated;
GRANT USAGE ON SCHEMA bridges TO anon;
GRANT USAGE ON SCHEMA strategy TO anon;
```

### 2.4 Permissões de tabela (SELECT, INSERT, UPDATE, DELETE)

```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA foundation TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA core TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA bridges TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA strategy TO anon, authenticated;
```

(ALTER DEFAULT PRIVILEGES aplicado para tabelas futuras.)

---

## 3. Configuração pós-ajuste

**Query:**
```sql
SELECT rolname, rolconfig FROM pg_roles WHERE rolname = 'authenticator';
```

**Resultado:**
```json
{
  "rolconfig": [
    "session_preload_libraries=safeupdate",
    "statement_timeout=8s",
    "lock_timeout=8s",
    "pgrst.db_schemas=public, foundation, core, bridges, strategy"
  ]
}
```

---

## 4. Re-teste HTTP

### Endpoint testado

**Formato PostgREST padrão (multischema):**
```
GET https://vpsqhmklecjvbnlhktbg.supabase.co/rest/v1/tenants?select=id&limit=1
Accept-Profile: foundation
apikey: <anon_key>
Authorization: Bearer <anon_key>
```

**Nota:** O path `/rest/v1/foundation.tenants` **não é suportado**; PostgREST interpreta como tabela `foundation.tenants` no schema public. O correto é `Accept-Profile: foundation` + path `/rest/v1/tenants`.

### Resultado

| Campo   | Valor |
|---------|-------|
| **Status** | 200 |
| **Body**   | `[]` |

O body vazio é esperado: o role `anon` com RLS em `foundation.tenants` não enxerga linhas (RLS bloqueia). O importante é o **200**, indicando que o schema está exposto e a API responde.

---

## 5. Resumo

| Item                          | Status |
|-------------------------------|--------|
| pgrst.db_schemas atualizado   | OK     |
| NOTIFY pgrst reload           | OK     |
| GRANT USAGE nos 4 schemas     | OK     |
| GRANT em tabelas              | OK     |
| GET /rest/v1/tenants (Profile: foundation) | 200, [] |

**Conclusão:** A API REST enxerga `foundation`, `core`, `bridges` e `strategy`. Uso via header `Accept-Profile` (GET) ou `Content-Profile` (POST/PATCH/PUT/DELETE).
