# GS-UI-V1 — Relatório canônico "ONDE ESTAMOS AGORA"

**Tipo:** Somente diagnóstico; sem implementar features.  
**Branch esperada:** feat/strategy-ui-integration-v1  
**Fonte de verdade:** docs/_canon/*, PRD.md, plan.md, contracts.md.

---

## PASSO A — Git e árvore do repositório (evidências)

### 1) Branch e upstream

```text
## feat/strategy-ui-integration-v1...origin/feat/strategy-ui-integration-v1
```

- **git branch -vv** (trecho da branch atual):
```text
* feat/strategy-ui-integration-v1  b91b5a9 [origin/feat/strategy-ui-integration-v1] fix(build): tsconfig include glob + keep lovable excluded until gradual integration
```

- **git remote -v**:
```text
origin	https://github.com/sandro-1964/humantria-ecosistem.git (fetch)
origin	https://github.com/sandro-1964/humantria-ecosistem.git (push)
```

**Conclusão:** Branch atual é `feat/strategy-ui-integration-v1`, em sync com `origin/feat/strategy-ui-integration-v1`.

---

### 2) Log curto — commits mais relevantes

```text
b91b5a9 (HEAD -> feat/strategy-ui-integration-v1, origin/feat/strategy-ui-integration-v1) fix(build): tsconfig include glob + keep lovable excluded until gradual integration
02379b1 fix(css): move Inter font import to index.html (postcss-safe)
d94180f fix(build): freeze typecheck to app entrypoints; keep lovable kit excluded for gradual integration
ae8f2bf chore(ui): bring lovable kit from ui-lovable-import into strategy integration branch
9e1b4ab wip: scaffold strategy ui integration v1 (docs + ui wiring)
5618f1c (main) BASE V1: Canon + Foundation V1 + Core V1 + Release Pack + Cursor rules
1365918 init: Humantria frontend + supabase env template + mcp setup
```

---

### 3) Diferenças (working tree)

- **git diff --stat:** (vazio — sem alterações não commitadas)
- **git diff:** (vazio — working tree limpo)

---

## PASSO B — Build / toolchain (evidências)

### 4) Versões

```text
node: v24.12.0
npm:  11.6.2
```

### 5) Instalação e build limpos

- **npm ci:**
```text
added 311 packages, and audited 312 packages in 10s
49 packages are looking for funding
  run `npm fund` for details
found 0 vulnerabilities
```

- **npm run build:**
```text
> humantria@0.0.0 build
> tsc -b && vite build

vite v7.3.1 building client environment for production...
transforming...
✓ 46 modules transformed.
rendering chunks...
computing gzip size...
dist/index.html                   0.71 kB │ gzip:  0.39 kB
dist/assets/index-CWefSiri.css    7.63 kB │ gzip:  2.38 kB
dist/assets/index-CGyU4dV5.js   229.90 kB │ gzip: 73.69 kB
✓ built in 832ms
```

**Registro:** Nenhum warning registrado na execução. Build **PASS**.

---

## PASSO C — Estrutura Lovable/Strategy/Shell/Router (evidências)

### 6) Listagem de diretórios

| Caminho | Conteúdo listado |
|--------|-------------------|
| **src\ui\lovable** | app-standalone, assets, components, contexts, hooks, lib, pages, styles, index.ts |
| **src\app\pages\strategy** | initiatives, objectives, ApprovalsPage.tsx, DashboardPage.tsx, ObjectivesPage.tsx, StrategyHomePage.tsx |
| **src\app\router** | AppRouter.tsx, routes.tsx |
| **src\shell** | AppShell.tsx |
| **docs\products\strategy\gs-ui-v1** | contracts.md, plan.md, PRD.md, RELATORIO_ESTADO_GS_UI_V1.md, validation_report.md |

### 7) O que o App está renderizando hoje

- **src/App.tsx:**
```tsx
import AppRouter from './app/router/AppRouter'
import './App.css'

export default function App() {
  return <AppRouter />
}
```

- **src/app/router/AppRouter.tsx:**
```tsx
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import StrategyHomePage from '../pages/strategy/StrategyHomePage'
import DiagnosticsPage from '../pages/DiagnosticsPage'

export default function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/strategy" replace />} />
        <Route path="/strategy" element={<StrategyHomePage />} />
        <Route path="/__diag" element={<DiagnosticsPage />} />
      </Routes>
    </BrowserRouter>
  )
}
```

- **src/app/pages/strategy/StrategyHomePage.tsx** (conteúdo relevante):  
  Página mínima com título "Strategy", texto "Home — plataforma Humantría", bloco com "Página Strategy real. Router ativo." e link para `/__diag`. **Não** usa layout Lovable (layout inline mínimo; fallback canônico).

- **src/shell/AppShell.tsx:**  
  Existe e usa `Outlet` + `AppLayout` de `@/components/layout/AppLayout` (kit Lovable). **Não está** usado no router atual (AppRouter não envolve rotas com `<AppShell>`).

---

## PASSO D — Dependências do kit Lovable (evidências)

### 8) package.json e npm ls

- **Trecho dependencies (package.json):**  
  Inclui React 19, react-router-dom, @radix-ui/* (vários), @supabase/supabase-js, lucide-react, recharts, react-hook-form, sonner, tailwind-merge, vaul, cmdk, etc. — alinhado a um kit UI moderno (Lovable).

- **npm ls --depth=0:**  
  Executado com sucesso; lista 50+ pacotes (react, react-dom, vite, typescript, @radix-ui/*, etc.). Nenhuma falha registrada.

---

## PASSO E — Checagem de FKs no repositório (SQL) (evidências)

**Comando usado:** Busca por `FOREIGN KEY` e `REFERENCES` em `contracts/**/*.sql`.  
**Pasta migrations:** Não existe no repositório (0 arquivos em migrations/**/*.sql).

### Resultado da busca em contracts/

| Arquivo | Linhas (ex.) | O que referencia o quê | Classificação |
|---------|--------------|-------------------------|---------------|
| contracts/core/002_tables.sql | 14, 15, 38, 39, 45, 60–62, 75, 95–97, 120, 140–141, 161, 179, 203–204, 225–226, 247–252, 274–275, 299, 325–326, 350–352, 376–377 | core.* → foundation.tenants; core.* → core.* (org_units, jobs, people, cost_centers, job_levels, import_jobs, import_job_runs) | FK mesmo schema (core→core): OK. core→foundation: **produto/camada → FOUNDATION (a confirmar contra Canon)** |
| contracts/foundation/002_tables.sql | 31, 52, 70, 88, 133–134, 144, 146, 160, 178, 210–211, 239–240, 257, 273, 289, 291, 306, 310, 321, 337, 351, 371, 396, 425, 447, 464, 498–499, 530, 548, 578–579, 614–615, 630, 646, 660, 664, 677–678, 692–694, 734, 748–750, 764–765, 818 | foundation.* → foundation.* (tenants, roles, permissions, templates, events_outbox, etc.) | FK dentro do mesmo schema foundation: **OK** |

**Resumo:**  
- No repo **não há** contratos do produto Strategy em `contracts/` (apenas core e foundation).  
- **core → foundation.tenants** aparece em vários pontos; Canon proíbe "FK cross-product"; Foundation é camada base — decisão a confirmar se "produto→foundation" é permitido.  
- **Nenhuma FK de produto Strategy** definida nos contracts do repo (schema strategy pode existir apenas no banco).

---

## PASSO F — Checagem de FKs no banco (via MCP)

**Projeto consultado:** Humantria (id: vpsqhmklecjvbnlhktbg). MCP Supabase disponível.

### A) Todas as FKs (resumo por schema)

- **auth:** FKs apenas dentro de `auth` (identities→users, sessions→users, etc.).
- **core:** FKs para `foundation.tenants` (tenant_id) e para tabelas `core` (org_units, jobs, people, cost_centers, job_levels, import_jobs, import_job_runs).
- **foundation:** FKs apenas dentro de `foundation`.
- **storage:** FKs dentro de `storage`.
- **strategy:** FKs para `foundation.tenants`; FKs para **core** (people, org_units, cost_centers, jobs, job_levels).

### B) FKs cross-schema (n1.nspname <> n2.nspname)

Registradas 56 FKs cross-schema:

- **core → foundation:** 22 FKs (ex.: cost_centers, org_units, people, jobs, etc. → foundation.tenants).
- **strategy → foundation:** 28+ FKs (tenant_id → foundation.tenants).
- **strategy → core:** 14 FKs, entre elas:
  - approval_history.approver_person_id → core.people
  - budget_approvals.approver_person_id → core.people
  - budget_items.org_unit_id → core.org_units, budget_items.cost_center_id → core.cost_centers
  - initiatives.owner_person_id → core.people
  - key_results.owner_person_id → core.people
  - objectives.owner_person_id → core.people
  - staffing_demands (org_unit_id, cost_center_id, job_id, job_level_id) → core.org_units, core.cost_centers, core.jobs, core.job_levels

### C) Classificação cross-product (naming convention: schemas = products)

| Origem | Destino | Quantidade (aprox.) | Classificação |
|--------|---------|----------------------|---------------|
| core | foundation | 22 | Produto/camada → FOUNDATION (a confirmar contra Canon) |
| strategy | foundation | 28+ | Produto → FOUNDATION (a confirmar contra Canon) |
| strategy | core | 14 | **Cross-product (proibido pelo Canon: "produto depender de tabela do outro produto")** |

**Conclusão MCP:** No banco existem FKs **strategy → core**, que violam a regra canônica de não criar FKs cross-product. Core→foundation e strategy→foundation são decisão a confirmar (foundation como camada base).

---

## PASSO G — Conclusão e "onde estamos"

### Estado atual

| Item | Resultado |
|------|-----------|
| **Build** | **PASS** (tsc -b && vite build; 46 modules; 0 vulnerabilities) |
| **Branch** | feat/strategy-ui-integration-v1 (sync com origin) |
| **Working tree** | Limpo (sem diff) |

### O que está integrado de fato

- **Router:** Ativo em `App.tsx` → `AppRouter` (BrowserRouter, Routes).
- **Rota /strategy:** Existe e renderiza `StrategyHomePage` (layout mínimo, sem Lovable).
- **Rota /__diag:** Existe e renderiza `DiagnosticsPage` (conforme 05_ui_contract).
- **Redirect / → /strategy:** Configurado.
- **Strategy "visível":** Sim — ao abrir a app, o usuário cai em /strategy.

### Kit Lovable vs uso

- **Importado:** Kit completo em `src/ui/lovable/` (components, layout, pages/strategy, styles). CSS Lovable carregado em `main.tsx`.
- **Usado pelo app de entrada:** Apenas indiretamente (CSS). O router atual **não** usa `AppShell` nem páginas do kit; usa `StrategyHomePage` e `DiagnosticsPage` em `src/app/pages/`, com layout mínimo.
- **AppShell:** Existe em `src/shell/AppShell.tsx` e importa layout Lovable (`AppLayout`), mas está **fora** do fluxo atual do router e está no **exclude** do tsconfig (não entra no typecheck do build).

### tsconfig (include/exclude)

- **tsconfig.app.json:**  
  - **include:** `src/main.tsx`, `src/App.tsx`, `src/app/router/**/*`, `src/app/pages/**/*` — apenas entrypoints + router + páginas do app.  
  - **exclude:** `src/ui/lovable`, `src/app/strategy`, `src/app/diag`, `src/app/ui_contract`, `src/shell`, entre outros.  
- **Motivo:** Manter typecheck restrito ao que o build usa e integrar o kit Lovable de forma gradual, sem quebrar o build com código ainda não conectado.

### Riscos atuais

1. **FKs cross-product no banco:** strategy → core (people, org_units, cost_centers, jobs, job_levels) — em desacordo com docs/_canon (02_db_contract_global, 10_product_rules). Sem alterar contratos/schemas neste relatório; apenas registrado.
2. **core/strategy → foundation:** Existência de FKs para foundation.tenants; decisão a confirmar contra Canon (foundation como base permitida).
3. **AppShell excluído:** Código em `src/shell` não é typechecked; ao integrar no router, pode expor erros.
4. **Divergência com relatório anterior:** O relatório anterior indicava ausência de `src/app/pages/strategy` e de Shell; hoje as páginas strategy e o AppShell existem, mas o router ainda não usa o Shell.

### Próximo passo mínimo (1)

**Para manter Strategy visível sem abrir avalanche:**  
Colocar a rota `/strategy` (e opcionalmente as demais rotas do app) **dentro** do `AppShell` (layout Lovable), de forma que o usuário continue vendo Strategy, mas dentro do layout Sidebar/Header. Isso implica: (1) incluir `src/shell` no typecheck (remover do exclude ou criar build que o inclua) ou aceitar risco temporário; (2) no `AppRouter`, envolver as rotas em um layout que use `<AppShell>` e `<Outlet />` para o conteúdo. Sem criar novas features nem alterar contratos SQL/schemas.

---

**Evidências:** Todas as saídas de comandos e trechos de código acima foram copiados dos outputs obtidos na data do relatório.  
**Arquivo:** `docs/products/strategy/gs-ui-v1/RELATORIO_ESTADO_GS_UI_V1.md`
