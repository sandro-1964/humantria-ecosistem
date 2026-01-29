# Decisões — DEMO MODE (UI/UX V3)

**Data:** 2026-01-29  
**Escopo:** DEMO MODE canônico para validação UI/UX sem Supabase

---

## Decisões registradas

1. **DEMO MODE é ferramenta de validação UI/UX, não feature final.**  
   Objetivo: permitir testes de fluxos, RBAC, menus e tenant sem integração real com Supabase/Auth. Não substitui o fluxo de autenticação em produção.

2. **DEMO MODE usa localStorage e pode ser desativado por flag.**  
   Chave: `humantria_demo_session_v1`. Ao clicar em "Sair do DEMO" ou "Reset DEMO", a sessão é removida e o usuário volta à tela de Acesso. Nenhuma integração Supabase é chamada enquanto o DEMO está ativo.

3. **Perfis DEMO são determinísticos e hardcoded.**  
   Roles: `admin`, `manager`, `analyst`, `auditor`. Tenant fixo: `tenant_demo` / "Humantría Demo". Matriz RBAC para DEMO está em código (RbacProvider + DEMO_PERMISSIONS).

4. **Indicadores explícitos no UI.**  
   Badge "DEMO" no shell, footer "DEMO • &lt;role&gt; • &lt;tenant&gt;", e `/__diag/meta` com `demo.enabled`, `demo.role`, `tenantId`, `userEmail`, `buildCommit` para evidência.

5. **Rotas e MenuGate incluem roles DEMO.**  
   Roles canônicos (platform_owner, tenant_admin, auditor) continuam; roles DEMO (admin, manager, analyst, auditor) foram adicionados onde apropriado para que guardas e menu reflitam o perfil simulado.
