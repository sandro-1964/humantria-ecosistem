# GS-AUTHZ Membership V1 — Validation Report

**Data:** 2026-02-08  
**Objetivo:** RLS por membership canônico (user_id ↔ tenant_id ↔ role) para /strategy deixar de retornar 0 linhas quando JWT não traz tenant/role.  
**Projeto Supabase:** vpsqhmklecjvbnlhktbg (Humantria)

---

## Pre-flight

### git status -sb

```
## feat/strategy-ui-integration-v1...origin/feat/strategy-ui-integration-v1
?? contracts/core/gs_patch_fk_cleanup_v1/
?? contracts/strategy/
?? docs/products/strategy/gs-db-patch-fk-cleanup/
```

### npm run build

```
> tsc -b && vite build
✓ 1735 modules transformed.
✓ built in 2.50s
```

**Resultado:** PASS (exit 0).

---

## Introspecção

### A) Tabela de membership

- **foundation.user_memberships:** não existe.
- **foundation.memberships:** existe. Colunas: id, tenant_id, user_id, status, joined_at, left_at, metadata, created_at, updated_at. Sem coluna `role` (role está em foundation.user_role_assignments via role_id → foundation.roles).
- **foundation.user_role_assignments:** existe (user_id, tenant_id, role_id, assigned_by, assigned_at, revoked_at, metadata, created_at, updated_at).
- **foundation.roles:** existe; códigos: platform_owner, tenant_admin, gestor, colaborador, auditor.
- **foundation_authz:** schema não existe. Será criado em 007_gs_patch_memberships_v1 com tabela user_memberships (user_id, tenant_id, role text) como superfície canônica para RLS.

### B) Policies atuais de strategy.objectives (USING)

| policyname | cmd | qual (resumo) |
|------------|-----|----------------|
| policy_strategy_objectives_platform_owner_all | ALL | foundation.is_platform_owner() |
| policy_strategy_objectives_tenant_admin_all | ALL | tenant_id = get_current_tenant_id() AND JWT role = 'tenant_admin' |
| policy_strategy_objectives_gestor_all | ALL | tenant_id = get_current_tenant_id() AND JWT role = 'gestor' |
| policy_strategy_objectives_analyst_select | SELECT | tenant_id = get_current_tenant_id() AND JWT role IN ('especialista','auditor') |

Todas dependem de `get_current_tenant_id()` e/ou `current_setting('request.jwt.claims')::json->>'role'`. Quando o JWT não traz tenant_id/role (ex.: login Supabase Auth padrão), RLS retorna 0 linhas.

---

## Migrações aplicadas

- `gs_patch_memberships_v1` — schema foundation_authz, tabela user_memberships, RLS, policies.
- `gs_patch_strategy_policies_membership_v1` — policies de strategy.objectives alteradas para usar foundation_authz.user_memberships + auth.uid().

---

## Seed DEV

Inserido (upsert) em foundation_authz.user_memberships:

| user_id | tenant_id | role | created_at |
|---------|-----------|------|-------------|
| efe5f770-ac33-4d69-88f8-17a000de8ebd | 00000000-0000-0000-0000-000000000001 | tenant_admin | 2026-02-08 21:44:52.41668+00 |

---

## Validação MCP

- **Membership:** 1 linha para user_id = efe5f770-ac33-4d69-88f8-17a000de8ebd, tenant_id = 00000000-0000-0000-0000-000000000001. OK.
- **Policies strategy.objectives:** policy_strategy_objectives_platform_owner_all (ALL), policy_strategy_objectives_membership_select (SELECT), policy_strategy_objectives_membership_all (ALL). OK.

---

## Smoke (App)

- Executar `npm run dev`, fazer login com o usuário cujo auth.uid() = efe5f770-ac33-4d69-88f8-17a000de8ebd (ou conta com membership no tenant).
- /__diag: confirmar sessão present e RPC set_current_tenant_id: ok.
- /strategy: confirmar que a lista de objectives mostra 11 linhas. (Nota: a rota /strategy atual pode renderizar o Dashboard Lovable; a página que exibe “Visíveis (RLS): N” é ObjectivesDashboardPage. Se o router não a exibir em /strategy, validar via chamada ao RPC objectives_list_for_tenant ou abrindo uma view que use fetchObjectivesForTenant.)
- [ ] /__diag: sessão present
- [ ] /strategy (ou RPC): 11 linhas visíveis (RLS)

---

## Checklist final

- [x] Pre-flight ok
- [x] Introspecção registrada
- [x] Membership criado/confirmado
- [x] Policies Strategy ajustadas
- [x] Seed DEV aplicado
- [ ] Smoke /strategy ok (validar manualmente)
