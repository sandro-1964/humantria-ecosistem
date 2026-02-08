# GS-UI-V2.2 — Validação: Tenant context (RLS)

**Data:** 2026-02-08  
**Objetivo:** App ver os 11 objectives respeitando RLS, com tenant context canônico (sem SQL manual; via MCP).  
**Restrições respeitadas:** Nenhuma policy alterada; nenhum dado/seed alterado; sem service_role no frontend.

---

## 1) PASSO 1 — Tenant_id real (MCP)

- **Query:** `SELECT DISTINCT tenant_id FROM strategy.objectives ORDER BY tenant_id;`
- **Resultado:** `TENANT_TARGET = 00000000-0000-0000-0000-000000000001`

---

## 2) PASSO 2 — Função setter

- **get_current_tenant_id():** Lê primeiro `request.jwt.claims->>'tenant_id'`, depois fallback `current_setting('app.current_tenant_id', true)`.
- **Setter:** Não existia. Aplicado GS-PATCH via MCP:
  - **foundation.set_current_tenant_id(p_tenant_id uuid)** — faz `set_config('app.current_tenant_id', p_tenant_id::text, true)`.
  - Contrato em repo: `contracts/foundation/006_gs_patch_set_current_tenant_id.sql`
- **RPC para mesma sessão:** Como cada request HTTP usa outra conexão, foi criado **strategy.objectives_list_for_tenant(p_tenant_id uuid)** que na mesma conexão chama `foundation.set_current_tenant_id` e devolve `SELECT * FROM strategy.objectives` (RLS aplicado).

---

## 3) PASSO 3 — Implementação frontend

- **src/lib/supabase.ts** — createClient (env VITE_SUPABASE_*).
- **src/lib/auth.ts** — `TENANT_TARGET`, `getSession()`, `setTenantContext(tenantId)`, `fetchObjectivesForTenant(tenantId)` (usa RPC `strategy.objectives_list_for_tenant`).
- **Após login / ao carregar /strategy:** Em `ObjectivesDashboardPage`, effect chama `setTenantContext(TENANT_TARGET)` e depois `fetchObjectivesForTenant(TENANT_TARGET)`; a tabela exibe as linhas retornadas (toText por UI contract).
- **/__diag:** Exibe TENANT_TARGET e resultado do RPC set_current_tenant_id (ok/erro).

---

## 4) PASSO 4 — Smoke e evidência

### Build

- `npm run build` — **PASS** (exit 0).

### Checklist smoke (executar manualmente)

1. **Login:** Abrir `/login`, informar credenciais de um usuário com acesso ao tenant `00000000-0000-0000-0000-000000000001` (e role compatível com RLS em strategy.objectives); confirmar redirecionamento para `/strategy`.
2. **/strategy:** A lista deixa de ficar vazia por RLS e mostra **11 linhas** (objectives do tenant).
3. **/__diag:** Exibe TENANT_TARGET e RPC set_current_tenant_id: ok.

### Arquivos criados/alterados (tenant context)

| Arquivo | Descrição |
|---------|-----------|
| contracts/foundation/006_gs_patch_set_current_tenant_id.sql | Definição do setter (espelho do aplicado via MCP). |
| src/lib/supabase.ts | Cliente Supabase. |
| src/lib/auth.ts | TENANT_TARGET, getSession, setTenantContext, fetchObjectivesForTenant. |
| src/app/router/RequireAuth.tsx | Proteção de rota; redireciona para /login se sem sessão. |
| src/app/pages/auth/LoginPage.tsx | Página de login (signInWithPassword). |
| src/app/pages/strategy/ObjectivesDashboardPage.tsx | Dashboard que seta tenant e carrega 11 rows via RPC. |
| src/app/pages/DiagnosticsPage.tsx | Exibe TENANT_TARGET e resultado do RPC. |

### Migrations aplicadas (MCP)

- `foundation_set_current_tenant_id` — cria foundation.set_current_tenant_id(uuid).
- `strategy_objectives_list_for_tenant_rpc` — cria strategy.objectives_list_for_tenant(uuid).

---

## Conclusão

O tenant context está definido de forma canônica: setter em foundation + RPC em strategy para mesma conexão. O frontend usa anon key e RPC (sem service_role). Policies e dados não foram alterados. Smoke: fazer login e abrir /strategy para confirmar 11 linhas visíveis.
