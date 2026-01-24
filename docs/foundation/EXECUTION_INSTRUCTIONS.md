# HUMANTRÍA — FOUNDATION MIGRATIONS — INSTRUÇÕES DE EXECUÇÃO

**Data:** 2026-01-23  
**Status:** ✅ Arquivos SQL prontos para execução

---

## 📋 ORDEM DE EXECUÇÃO (OBRIGATÓRIA)

Execute os arquivos SQL na ordem abaixo via MCP Supabase ou Supabase Dashboard:

### 1️⃣ `001_schema.sql`
**Arquivo:** `contracts/foundation/001_schema.sql`  
**Ação:** Cria schema `foundation` + extensões (`uuid-ossp`, `pgcrypto`)

### 2️⃣ `002_tables.sql`
**Arquivo:** `contracts/foundation/002_tables.sql`  
**Ação:** Cria 48 tabelas + triggers `updated_at`

### 3️⃣ `003_functions.sql`
**Arquivo:** `contracts/foundation/003_functions.sql`  
**Ação:** Cria 11 funções (SECURITY INVOKER) + views

### 4️⃣ `004_rls.sql`
**Arquivo:** `contracts/foundation/004_rls.sql`  
**Ação:** Habilita RLS + cria 81 políticas

### 5️⃣ `005_seed_demo.sql`
**Arquivo:** `contracts/foundation/005_seed_demo.sql`  
**Ação:** Seed idempotente completo (tenant + RBAC + AI + template + service)

---

## ⚠️ IMPORTANTE

**MCP Supabase configurado:** O servidor MCP Supabase está configurado em `.cursor/mcp.json`, mas não há acesso direto a ferramentas de execução SQL via MCP no ambiente atual.

**Opções de execução:**

1. **Via Supabase Dashboard (SQL Editor)**
   - Acesse: https://supabase.com/dashboard/project/vpsqhmklecjvbnlhktbg/sql
   - Execute cada arquivo na ordem (1 → 5)

2. **Via Supabase CLI** (se configurado)
   ```bash
   supabase db execute --file contracts/foundation/001_schema.sql
   supabase db execute --file contracts/foundation/002_tables.sql
   supabase db execute --file contracts/foundation/003_functions.sql
   supabase db execute --file contracts/foundation/004_rls.sql
   supabase db execute --file contracts/foundation/005_seed_demo.sql
   ```

3. **Via MCP Supabase** (se ferramentas disponíveis)
   - Execute cada arquivo SQL na ordem especificada

---

## ✅ VALIDAÇÕES PÓS-EXECUÇÃO

Após executar todas as migrations, validar:

```sql
-- 1. Schema criado
SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'foundation';

-- 2. Tabelas criadas (deve retornar 48)
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'foundation';

-- 3. Funções criadas (deve retornar 11+)
SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'foundation';

-- 4. Seed executado
SELECT COUNT(*) FROM foundation.tenants WHERE slug = 'acme-corp'; -- deve retornar 1
SELECT COUNT(*) FROM foundation.roles WHERE is_system = TRUE; -- deve retornar 5
SELECT COUNT(*) FROM foundation.permissions; -- deve retornar 4
SELECT COUNT(*) FROM foundation.ai_use_cases WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid; -- deve retornar 1
SELECT COUNT(*) FROM foundation.templates WHERE code = 'default-tenant-setup'; -- deve retornar 1
SELECT COUNT(*) FROM foundation.service_catalog WHERE code = 'onboarding'; -- deve retornar 1
```

---

**Arquivos prontos e validados. Aguardando execução via MCP Supabase ou método alternativo.**
