# GS-UI-V1 — Validation Report

## Pre-flight (hotfix CSS)

- **Branch:** feat/strategy-ui-integration-v1
- **git status -sb:** (at hotfix start) M package-lock.json, package.json, src/App.tsx, src/app/router/AppRouter.tsx, tsconfig.app.json; untracked files present
- **git rev-parse --abbrev-ref HEAD:** feat/strategy-ui-integration-v1
- **git log --oneline -5:** d94180f fix(build): freeze typecheck…, ae8f2bf chore(ui): bring lovable kit…, 9e1b4ab wip: scaffold…, 5618f1c BASE V1…, 1365918 init…
- **node -v:** v24.12.0
- **npm -v:** 11.6.2

## Evidence

### Hotfix: PostCSS @import warning

**Problema:** `[vite:css][postcss] @import must precede all other statements` — o CSS do Lovable (`src/ui/lovable/styles/index.css`) tinha `@import url('https://fonts.googleapis.com/...')` após `@tailwind` e antes de `@layer base`. O PostCSS exige que `@import` venha antes de qualquer outra regra; em CSS com `@layer` isso tende a quebrar.

**Solução:** Mover o carregamento da fonte Inter para o HTML (estável no Vite).
- **index.html:** Adicionados no `<head>`: `<link rel="preconnect" href="https://fonts.googleapis.com">`, `<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>`, `<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">`.
- **src/ui/lovable/styles/index.css:** Removida a linha `@import url('https://fonts.googleapis.com/css2?family=Inter...');` e adicionado comentário indicando que a fonte é carregada via index.html.

**Verificação:** `rg "fonts\.googleapis\.com" src/ui/lovable/styles/index.css` → sem matches (nenhum @import do Google Fonts restante no CSS).

### Diffs relevantes

- **index.html:** +3 linhas (preconnect + link stylesheet Inter).
- **src/ui/lovable/styles/index.css:** -1 linha (@import), +1 linha (comentário).

### Validações (PASSO 2)

- **npm ci:** PASS (312 packages, 0 vulnerabilities).
- **npm run build:** PASS. Saída sem warning do PostCSS; build concluído com sucesso (✓ 2313 modules transformed, ✓ built in 4.36s). Aviso de chunk size (>500 kB) permanece (Rollup), não relacionado ao CSS.
- **Smoke runtime:** Dev server em 127.0.0.1:5173; requisições locais:
  - **GET /strategy:** StatusCode 200, HTML do SPA (index.html).
  - **GET /__diag:** StatusCode 200, HTML do SPA (index.html).

### Evidências finais (PASSO 3)

**git diff --stat (após hotfix CSS):**
```
 index.html                          | 4 ++++
 src/ui/lovable/styles/index.css     | 3 +--
 2 files changed, 5 insertions(+), 2 deletions(-)
```

**npm run build output (trecho):**
```
> tsc -b && vite build
vite v7.3.1 building client environment for production...
transforming...
✓ 2313 modules transformed.
...
✓ built in 4.36s
```
(Nenhum `[vite:css][postcss] @import must precede` na saída.)

**PostCSS:** Warning eliminado; fonte Inter carregada via index.html.

**Rotas:** /strategy e /__diag respondem 200 com o shell HTML do app (SPA).

---

*Relatório atualizado no hotfix CSS (move Inter font to index.html).*
