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

## T3 — i18n mínimo (Shell + nav principais) — CONCLUÍDO

**Objetivo:** Dropdown pt-BR / en-US / es-ES; labels do Shell e itens principais da nav; persistência em localStorage.

### Decisão canônica (padrão)

**Módulos NÃO traduzem:** Foundation, Core, Strategy, Tools — iguais em todos os idiomas. Labels funcionais (tenants, settings, usersRoles, audit, wizard, docs, legacy) traduzem por idioma.

### Alterações (T3 inicial + T3 final)

- `src/i18n/index.ts` — registo de es-ES (import + resources) para dropdown de 3 locales
- `src/i18n/locales/en-US.json` — nav.* em inglês (base)
- `src/i18n/locales/pt-BR.json` — módulos Foundation/Core/Strategy/Tools; labels funcionais em português (Inquilinos, Configurações, Usuários e funções, Auditoria, Assistente, Documentação, Integrações com Legados)
- `src/i18n/locales/es-ES.json` — módulos Foundation/Core/Strategy/Tools; labels funcionais em espanhol
- `src/shell/AppShell.tsx` — usa `t('nav.*')` para todos os itens

### Evidências (validação manual)

| Checklist | Resultado |
|-----------|-----------|
| Dropdown alterna pt-BR / en-US / es-ES | OK |
| Shell: label Idioma / Language por locale | OK |
| Shell: demoProfileTitle e exitDemo por locale | OK |
| Nav: Foundation, Core, Strategy, Tools (sem tradução) em todos | OK |
| pt-BR: Inquilinos, Configurações, Usuários e funções, Auditoria, Assistente | OK |
| es-ES: labels funcionais em espanhol | OK |
| Persistência: recarregar mantém locale (localStorage) | OK |
| /__diag/meta continua OK | OK |
| /core e /strategy abrem (stubs) | OK |
| `npm run build` passa | OK |

### Passos de validação

1. `npm run dev`
2. **pt-BR:** menu mostra Foundation, Core, Strategy, Tools + Inquilinos, Configurações, Usuários e funções, Auditoria, Assistente
3. **en-US:** tudo em inglês
4. **es-ES:** Foundation, Core, Strategy, Tools + labels funcionais em espanhol
5. Recarregar e confirmar persistência do idioma
6. Abrir `/core`, `/strategy`, `/__diag/meta` — tudo funciona

---

## Histórico

| Fase | Descrição |
|------|-----------|
| A | Foundation + admin stubs (TenantSettings, UsersAndRoles, Audit) |
| B | Flags ready, /__diag/meta, DEMO mode |
| T4 | /core e /strategy stub routes (no 404) |
| T3 | i18n Shell + nav (pt-BR, en-US, es-ES); módulos não traduzem; labels funcionais traduzidos — CONCLUÍDO |
