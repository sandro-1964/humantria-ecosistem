# GS-AUTHZ Membership V1 — Decisões

**Data:** 2026-02-08

---

## Decisão canônica: RLS por membership, não por JWT custom claim (por enquanto)

- **Problema:** As policies de strategy.objectives (e outras que usam get_current_tenant_id() e role no JWT) retornam 0 linhas quando o Supabase Auth não envia custom claims (tenant_id, role) no JWT. O app já chamava set_current_tenant_id() na sessão e usava RPC objectives_list_for_tenant, mas a avaliação de RLS continua dependendo do JWT em cada row.
- **Decisão:** Usar uma tabela canônica de membership (foundation_authz.user_memberships: user_id, tenant_id, role) e fazer as policies de Strategy permitirem acesso quando EXISTS (membership com auth.uid(), tenant_id da linha, role permitida). Assim o acesso não depende de JWT custom claim; depende apenas de auth.uid() (que o Supabase Auth sempre envia) e dos dados na base.
- **Motivo:** JWT custom claims exigiriam que todo login/sessão fosse enriquecido com tenant_id e role (via trigger, Edge Function ou backend). Membership na base é uma única fonte de verdade, auditável e provisionável de forma independente do fluxo de login.

---

## Riscos e mitigação

- **Risco:** Duplicação de noção de “role” (foundation.roles + user_role_assignments vs foundation_authz.user_memberships.role).  
  **Mitigação:** foundation_authz.user_memberships é a superfície “para RLS”; sincronização com foundation.memberships / user_role_assignments fica como próximo passo (automatizar provisionamento).
- **Risco:** INSERT/UPDATE/DELETE em user_memberships só para platform_owner; tenant_admin não pode ainda gerir memberships.  
  **Mitigação:** Registrado em decisions; policy pode ser estendida depois para permitir tenant_admin no próprio tenant.

---

## Próximos passos (registrado)

- Automatizar provisionamento: ao criar/atribuir membership em foundation.memberships e user_role_assignments, manter foundation_authz.user_memberships em sync (trigger ou job).
- Opcional: estender policies de outros produtos (key_results, initiatives) para usar membership quando trivial.
- Avaliar enriquecimento de JWT com tenant_id/role a partir de user_memberships (para get_current_tenant_id() e compatibilidade com código que ainda lê JWT), sem obrigar o RLS a depender disso.
