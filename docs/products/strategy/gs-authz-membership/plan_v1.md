# GS-AUTHZ Membership V1 — Plano

**Data:** 2026-02-08  
**Objetivo:** Corrigir RLS retornando 0 linhas em /strategy por ausência de tenant/role no JWT, implementando membership canônico (user_id ↔ tenant_id ↔ role) e adaptando policies de Strategy para usar auth.uid() + membership.

---

## O que foi feito

1. **Pre-flight** — `git status -sb`, `npm run build` (PASS). Registrado em validation_report.md.

2. **Introspecção** — Verificado: não existe foundation.user_memberships; existe foundation.memberships (sem role) e foundation.user_role_assignments (role_id). Policies de strategy.objectives usam get_current_tenant_id() e JWT role; quando JWT não traz tenant_id/role, RLS retorna 0 linhas. Resultados em validation_report.md.

3. **Membership canônico (Foundation)** — [contracts/foundation/007_gs_patch_memberships_v1.sql](../../../contracts/foundation/007_gs_patch_memberships_v1.sql): schema foundation_authz, tabela user_memberships (user_id, tenant_id, role com CHECK), RLS, policy SELECT (próprio user_id = auth.uid()), policy ALL (platform_owner). Seed DEV em [008_gs_patch_membership_seed_dev_v1.sql](../../../contracts/foundation/008_gs_patch_membership_seed_dev_v1.sql): upsert user_id efe5f770-ac33-4d69-88f8-17a000de8ebd, tenant_id 00000000-0000-0000-0000-000000000001, role tenant_admin.

4. **Policies Strategy** — [contracts/strategy/007_gs_patch_strategy_policies_membership_v1.sql](../../../contracts/strategy/007_gs_patch_strategy_policies_membership_v1.sql): removidas 3 policies de strategy.objectives baseadas em JWT (analyst_select, gestor_all, tenant_admin_all); mantida platform_owner_all; criadas policy_strategy_objectives_membership_select (SELECT por membership + auth.uid()) e policy_strategy_objectives_membership_all (ALL por membership tenant_admin/gestor).

5. **Validação** — Membership confirmada (1 linha para o user/tenant). Policies atuais: policy_strategy_objectives_platform_owner_all, policy_strategy_objectives_membership_select, policy_strategy_objectives_membership_all. Smoke: npm run dev, login, /__diag, /strategy (validar manualmente que “Visíveis (RLS)” mostra 11 linhas).

6. **Docs** — plan_v1.md (este), decisions.md, validation_report.md.

---

## Entregáveis

| Arquivo | Descrição |
|---------|-----------|
| contracts/foundation/007_gs_patch_memberships_v1.sql | Schema foundation_authz, user_memberships, RLS, policies |
| contracts/foundation/008_gs_patch_membership_seed_dev_v1.sql | Seed DEV (upsert 1 membership) |
| contracts/strategy/007_gs_patch_strategy_policies_membership_v1.sql | Policies strategy.objectives por membership |
| docs/products/strategy/gs-authz-membership/plan_v1.md | Este plano |
| docs/products/strategy/gs-authz-membership/validation_report.md | Evidências e checklist |
| docs/products/strategy/gs-authz-membership/decisions.md | Decisões canônicas |

---

## Pausa canônica

Antes de commit/tag, responder exatamente:  
“Pre-flight ok. Introspecção ok. Membership criado/confirmado. Policies ajustadas. Seed DEV aplicado. Smoke /strategy ok. Posso commitar e tagear?”  
E parar.
