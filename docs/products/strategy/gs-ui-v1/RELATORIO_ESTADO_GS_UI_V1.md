# GS-UI-V1 — Relatório do que já foi feito e em que momento parou

**Fonte de verdade:** PRD.md, plan.md, contracts.md, 05_ui_contract.md.

---

## 1. O que já foi feito

### 1.1 Alias e config (PASSO 1 — bridge)

- **vite.config.ts**  
  - Adicionado `resolve.alias: { '@': path.resolve(__dirname, 'src') }` para resolver imports `@/` do kit Lovable.
- **tsconfig.app.json**  
  - Adicionado `"baseUrl": "."` e `"paths": { "@/*": ["src/*"] }` para TypeScript.

### 1.2 Kit Lovable no repo

- **Localização:** `src/ui/lovable/**` (conforme contracts).
- O kit completo está presente:
  - `src/ui/lovable/components/ui/*` (button, card, badge, data-table, empty-state, error-state, skeleton, page-header, kpi-card, stats-card, etc.)
  - `src/ui/lovable/components/layout/*` (AppSidebar, AppHeader, AppLayout, sidebar, etc.)
  - `src/ui/lovable/styles/index.css` e `App.css`
  - `src/ui/lovable/pages/strategy/*` (páginas Strategy **dentro do kit** Lovable: DashboardPage, ObjectivesPage, ApprovalsPage, etc.)

### 1.3 Barrel do Lovable

- **Arquivo:** `src/ui/lovable/index.ts`
- Re-exporta hoje: `Button`, `Card`, `Sidebar` (de `./components/ui/button`, `./components/ui/card`, `./components/layout/sidebar`).
- Pode ser ampliado para outros componentes usados nas páginas Strategy e no Shell (Badge, Table, EmptyState, ErrorState, Skeleton, PageHeader, etc.).

### 1.4 Adapter canônico Strategy

- **Arquivo:** `src/app/strategy/components/lovable.ts` (contracts: “Strategy e Shell importam daqui”).
- Re-exporta de `@/ui/lovable`: `Button`, `Card`, `Sidebar` (e tipos).
- Objetivo: centralizar imports; não espalhar paths do Lovable no app.

### 1.5 CSS Lovable no app

- **main.tsx**  
  - Incluído import: `import './ui/lovable/styles/index.css'`.
- Contracts: “CSS Lovable carregado em: src/main.tsx”.

---

## 2. O que ainda não existe no app principal

Os **contracts** definem:

- Páginas Strategy do **app** em: `src/app/pages/strategy/**`
- Shell do app em: `src/shell/AppShell.tsx`
- Router em: `src/app/router/**` (ou equivalente)

**Estado atual:**

- **`src/app/pages/strategy/**`**  
  - **Não existe.** Não há StrategyHomePage, ObjectivesListPage, ObjectiveDetailPage, etc. no app principal. As únicas páginas Strategy estão **dentro do kit** em `src/ui/lovable/pages/strategy/`.
- **`src/shell/AppShell.tsx`**  
  - **Não existe.** Não há Shell, MenuGate, RequireRole nem Outlet no `src`.
- **Router**  
  - O app ainda usa o `App.tsx` padrão do Vite (counter); não há rotas nem `Outlet`.

Por isso:

- **Fase B (aplicar Lovable nas páginas Strategy)** não foi iniciada — não há páginas em `src/app/pages/strategy/*` para adaptar.
- **Fase C (aplicar Lovable no AppShell)** não foi iniciada — não há AppShell.
- **Rota /__diag** (obrigatória pelo 05_ui_contract.md) não existe — depende de haver router.

---

## 3. Em que momento parou

- **Concluído:** Fase A (bridge) em grande parte: alias `@/`, barrel Lovable mínimo, adapter Strategy, CSS Lovable em `main.tsx`. O kit Lovable está em `src/ui/lovable/**`.
- **Parou em:**  
  - Ausência das **páginas Strategy do app** em `src/app/pages/strategy/**` e do **Shell** em `src/shell/AppShell.tsx` (e do router).  
  - Sem essas peças, não há como “trocar apenas JSX/layout” nas páginas Strategy nem no AppShell, conforme PRD/plan/contracts.

---

## 4. Próximos passos (resumido)

1. **Criar router** em `src/app/router/**` e integrar no app (ex.: `main.tsx` / `App.tsx`), mantendo paths de Strategy conforme já definidos.
2. **Criar Shell** em `src/shell/AppShell.tsx` com MenuGate/RequireRole/Outlet e visibilidade por role; depois aplicar layout Lovable (Sidebar/Header/Layout).
3. **Criar páginas Strategy** em `src/app/pages/strategy/**` (ou reapontar/reexportar a partir do kit), usando o adapter `src/app/strategy/components/lovable.ts`, com dados sempre via `toText()`/`renderValue()` (UI Contract).
4. **Garantir rota /__diag** (05_ui_contract).
5. **Ampliar** `src/ui/lovable/index.ts` e `src/app/strategy/components/lovable.ts` com os componentes Lovable necessários (Badge, Table, EmptyState, Skeleton, PageHeader, etc.) conforme uso nas telas e no Shell.
6. **Validar:** `npm run build`, rotas inalteradas, nenhum objeto cru em JSX, sidebar por role inalterada; atualizar `validation_report.md`.

---

## 5. Arquivos tocados até agora

| Arquivo | Alteração |
|--------|-----------|
| `vite.config.ts` | Alias `@` → `src` |
| `tsconfig.app.json` | `baseUrl` e `paths` para `@/*` |
| `src/main.tsx` | Import CSS Lovable `./ui/lovable/styles/index.css` |
| `src/ui/lovable/index.ts` | Barrel (Button, Card, Sidebar) |
| `src/app/strategy/components/lovable.ts` | Adapter re-exportando do Lovable |

*(O kit em `src/ui/lovable/**` foi importado/colocado no repo separadamente; não conta como “alteração” desta GS.)*

---

*Relatório gerado para alinhamento com PRD, plan e contracts. Documentos vencem em caso de divergência.*
