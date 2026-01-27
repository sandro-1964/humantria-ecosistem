# HUMANTRÍA — ROUTING CONTRACT (LOCAL) — V1

Status: BLOQUEANTE  
Escopo: rotas do app UI (Foundation + DIAG + Tools)

━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRINCÍPIO
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Roteamento é parte do runtime governado:
- deve ser previsível
- deve ser auditável (incident log em erros relevantes)
- nunca gera tela em branco

━━━━━━━━━━━━━━━━━━━━━━━━━━━
ROTAS CANÔNICAS (V1)
━━━━━━━━━━━━━━━━━━━━━━━━━━━

### DIAG (permanente)
- `/__diag`
- `/__diag/meta`

### Auth
- `/auth` (login)
- `/auth/callback` (callback opcional)
- `/auth/logout`

### Foundation (admin/runtime)
- `/foundation`
- `/foundation/tenants` (list)
- `/foundation/tenants/:tenantId` (detail)
- `/foundation/admin/settings` (tenant settings)
- `/foundation/admin/users-roles` (users & roles)
- `/foundation/audit` (timeline)
- `/foundation/wizard/bootstrap` (wizard mínimo; UI guided)

### Tools (menu global, não produto)
- `/tools/docs`
- `/tools/legacy-integrations`

━━━━━━━━━━━━━━━━━━━━━━━━━━━
GUARDS OBRIGATÓRIOS
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Todas as rotas em `/foundation/*` e `/tools/*` devem aplicar:
- `RequireAuth` (sessão)
- `RequireTenant` (tenant context resolvido, quando aplicável)
- `RequireRole` e/ou `RequirePermission` conforme a página

Regra de ouro: RLS manda. UI nunca deve assumir acesso apenas por “esconder menu”.

━━━━━━━━━━━━━━━━━━━━━━━━━━━
ESTADOS OBRIGATÓRIOS POR ROTA
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Toda rota deve ter componentes/fluxo explícito para:
- loading
- empty
- error
- success

O AppReadyGate é o único lugar autorizado a fazer gating global (boot).

