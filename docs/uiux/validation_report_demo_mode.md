# Relatório de validação — DEMO MODE (UI/UX V3)

**Data:** 2026-01-29  
**Objetivo:** Habilitar DEMO MODE (sem Supabase) para testes de UI/UX + RBAC/menus + tenants, com persistência e evidência.

---

## Objetivo

- Permitir entrar em modo DEMO a partir da tela de Acesso (login).
- Simular 4 perfis: Admin, Gestor, Analista, Auditor.
- Persistir sessão DEMO em localStorage (`humantria_demo_session_v1`).
- Exibir indicadores claros (badge DEMO, footer, /__diag/meta).
- Guardas RBAC e menu efetivos por perfil (admin total; manager/analyst/auditor com restrições).

---

## Evidências e rotas

| Evidência | Onde |
|-----------|------|
| Badge "DEMO" no shell | Sidebar, ao lado do nome do tenant |
| Simulação de Perfil (DEMO) | Sidebar: dropdown de perfil + "Sair do DEMO" |
| Footer | "DEMO • &lt;role&gt; • &lt;tenant&gt;" no rodapé da área principal |
| Meta diag | `/__diag/meta`: `demo.enabled`, `demo.role`, `tenantId`, `userEmail`, `buildCommit` |

---

## Passos de teste (validação manual)

### Teste 1 — Entrar em DEMO e confirmar /foundation e badge DEMO

1. Abrir a aplicação (ex.: `npm run dev`).
2. Garantir que não há sessão DEMO (localStorage sem `humantria_demo_session_v1` ou "Sair do DEMO" para limpar).
3. Na tela de Acesso (login), clicar em **"Entrar em DEMO"**.
4. **Resultado esperado:** redirecionamento para `/foundation` (ou rota equivalente), sidebar com badge "DEMO", tenant "Humantría Demo", footer "DEMO • admin • Humantría Demo".
5. Abrir `/__diag/meta` e confirmar `demo.enabled: true`, `demo.role: "admin"`, `tenantId: "tenant_demo"`, `userEmail: "demo+admin@humantria.local"`.

### Teste 2 — Trocar perfil para Auditor e confirmar restrição de menu

1. Com DEMO ativo (perfil Admin), na sidebar em **"Simulação de Perfil (DEMO)"** escolher **Auditor** no dropdown.
2. **Resultado esperado:** menu atualiza; itens como "Tenants", "Settings", "Users & Roles", "Wizard", "Integrações com Legados" não devem aparecer (ou ficam restritos). "Audit Timeline" e "Documentação" devem permanecer visíveis.
3. Footer deve mostrar "DEMO • auditor • Humantría Demo".
4. Acessar `/__diag/meta` e confirmar `demo.role: "auditor"`.

### Teste 3 — Sair do DEMO

1. Com DEMO ativo, clicar em **"Sair do DEMO"** na sidebar.
2. **Resultado esperado:** volta à tela de Acesso (login); localStorage sem `humantria_demo_session_v1`.

---

## Resultado

- [ ] Teste 1 executado e passou
- [ ] Teste 2 executado e passou
- [ ] Teste 3 executado e passou

*(Preencher após execução manual; incluir prints ou anotações se necessário.)*

---

## Pendências

- Playwright não está no projeto; validação é manual. Se for adicionada infra de testes E2E, criar em `tests/ui` os dois smoke tests descritos no prompt (Entrar DEMO → /home e trocar perfil Auditor → Tools/Settings some ou desabilitado).
- `buildCommit` em `/__diag/meta` depende de `VITE_BUILD_COMMIT` no build; em dev pode ser `null`.
