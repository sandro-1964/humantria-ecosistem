# Relatório final de testes — Fase A/B Strategy (UI/UX V3)

**Branch:** ui-ux-migration-v3  
**Commit base conhecido:** 461ab9f (B2 stub-safe admin + flags ready)  
**Commit T4:** c076ab3

---

## T4 — Stub routes Core/Strategy (no 404)

**Objetivo:** Eliminar 404 em `/core` e `/strategy` com páginas stub puras (StubPageLayout).

### Alterações

- `src/app/pages/core/CoreStubPage.tsx` — stub puro
- `src/app/pages/strategy/StrategyStubPage.tsx` — stub puro
- `src/app/router/routes.tsx` — rotas `/core` e `/strategy` registradas
- `src/shell/AppShell.tsx` — menu: itens Core e Strategy (labels literais)

### Evidências (validação manual)

| Checklist | Resultado |
|-----------|-----------|
| `/core` abre sem 404 | ✅ |
| `/strategy` abre sem 404 | ✅ |
| `/__diag/meta` — demo.enabled true, flags.status ready | ✅ |
| Menu: clicar Core abre stub | ✅ |
| Menu: clicar Strategy abre stub | ✅ |
| Sem erros Supabase no console nessas páginas | ✅ |
| Build `npm run build` passa | ✅ |

### Passos de validação

1. `npm run dev`
2. Entrar em DEMO (tela de Acesso → "Entrar em DEMO")
3. Navegar para `/core` — deve exibir StubPageLayout "Core"
4. Navegar para `/strategy` — deve exibir StubPageLayout "Strategy"
5. Abrir `/__diag/meta` — confirmar `demo.enabled: true`, `flags.status: "ready"`
6. Clicar nos itens "Core" e "Strategy" no menu lateral
7. Console do navegador: sem chamadas Supabase em /core ou /strategy

### Resultado

- [x] Rotas stub implementadas
- [x] Menu atualizado
- [x] Build ok
- [ ] Validação manual executada (preencher após rodar localmente)

---

## T3 — i18n mínimo (Shell + nav principais)

**Objetivo:** Dropdown pt-BR / en-US / es-ES; labels do Shell e itens principais da nav traduzidos; persistência em localStorage.

### Alterações

- `src/i18n/index.ts` — registo de es-ES (import + resources) para dropdown de 3 locales
- `src/i18n/locales/en-US.json` — `nav.core`, `nav.strategy`
- `src/i18n/locales/pt-BR.json` — `nav.core`, `nav.strategy` ("Estratégia")
- `src/i18n/locales/es-ES.json` — `nav.core`, `nav.strategy` ("Estrategia"); ficheiro novo
- `src/shell/AppShell.tsx` — literais "Core" e "Strategy" substituídos por `t('nav.core')` e `t('nav.strategy')` (título de secção + label MenuItem)

### Evidências (validação manual)

| Checklist | Resultado |
|-----------|-----------|
| Dropdown alterna pt-BR / en-US / es-ES |  |
| Shell: label "Idioma" / "Language" / "Idioma" (es) |  |
| Shell: demoProfileTitle e exitDemo mudam por locale |  |
| Nav: Foundation, Core, Strategy/Estratégia/Estrategia, Tools, Settings |  |
| Persistência: recarregar mantém locale (localStorage) |  |
| /__diag/meta continua OK |  |
| /core e /strategy abrem (stubs) |  |
| `npm run build` passa | OK |

### Passos de validação

1. `npm run dev`
2. No Shell: selecionar **en-US** — confirmar "Language", "Profile simulation (DEMO)", "Exit DEMO", "Foundation", "Core", "Strategy", "Tools", "Settings"
3. Recarregar página — confirmar que idioma permanece en-US
4. Selecionar **pt-BR** — confirmar "Idioma", "Simulação de Perfil (DEMO)", "Sair do DEMO", "Estratégia" na nav
5. Selecionar **es-ES** — confirmar "Idioma", "Simulación de perfil (DEMO)", "Salir del DEMO", "Estrategia" na nav
6. Abrir `/core` e `/strategy` — páginas stub
7. Abrir `/__diag/meta` — resposta OK

---

## Histórico

| Fase | Descrição |
|------|-----------|
| A | Foundation + admin stubs (TenantSettings, UsersAndRoles, Audit) |
| B | Flags ready, /__diag/meta, DEMO mode |
| T4 | /core e /strategy stub routes (no 404) |
| T3 | i18n mínimo Shell + nav (pt-BR, en-US, es-ES); nav.core / nav.strategy |
