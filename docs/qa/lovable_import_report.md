# Lovable import – consolidation report

**Date:** 2026-01-31  
**Branch:** ui-lovable-import  
**Scope:** Consolidate Lovable export into canonical structure; archive standalone app; no DB/contracts/RPCs/tests/business logic changes.

---

## 1. Estrutura final criada

Canonical UI root:

```
src/ui/lovable/
  components/     # features, layout, ui (shadcn-style)
  pages/         # bridges, chronos, core, foundation, grc, strategy, talent, tools, etc.
  lib/           # i18n, mock-data, utils
  hooks/         # use-mobile, use-toast
  contexts/      # AppContext
  assets/        # logo-dark.svg, logo-humantria.svg, logo-light.jpg, logo-light.svg
  styles/        # index.css, App.css
  app-standalone/ # App.tsx, main.tsx (Lovable standalone entry; not used by main app)
```

---

## 2. O que foi movido

### De `src/ui/` → `src/ui/lovable/`

| Origem | Destino |
|--------|---------|
| `src/ui/components` | `src/ui/lovable/components` |
| `src/ui/lovable-pages` | `src/ui/lovable/pages` |
| `src/ui/lovable-lib` | `src/ui/lovable/lib` |
| `src/ui/lovable-hooks` | `src/ui/lovable/hooks` |
| `src/ui/lovable-contexts` | `src/ui/lovable/contexts` |
| `src/ui/lovable-assets` | `src/ui/lovable/assets` |
| `src/ui/lovable-styles` | `src/ui/lovable/styles` |

### De `ui/lovable/src/` → `src/ui/lovable/`

- `index.css`, `App.css` → `src/ui/lovable/styles/`
- `App.tsx`, `main.tsx` → `src/ui/lovable/app-standalone/`
- Conteúdo de `components`, `pages`, `lib`, `hooks`, `contexts`, `assets` mesclado nas pastas correspondentes em `src/ui/lovable/` (robocopy/move).

---

## 3. O que foi arquivado

Pasta **`ui/lovable/_archived_root/`** contém o app standalone do Lovable (não usado pelo app principal):

- `package.json`, `package-lock.json`, `bun.lockb`
- `vite.config.ts`, `vitest.config.ts`
- `tsconfig.json`, `tsconfig.app.json`, `tsconfig.node.json`
- `tailwind.config.ts`, `postcss.config.js`, `eslint.config.js`
- `components.json`
- `index.html`, `README.md`, `.gitignore`
- `public/` (favicon, placeholder, robots.txt)
- `src/` (cópia restante do export: pages, lib, hooks, contexts, assets, test, vite-env.d.ts)

---

## 4. Outras alterações

- **`src/main.tsx`:** adicionados imports no topo (sem remover nada existente):
  - `import './ui/lovable/styles/index.css';`
  - `import './ui/lovable/styles/App.css';`
- **`tsconfig.app.json`:** adicionado `"exclude": ["src/ui/lovable"]` para o build do app principal não compilar o código Lovable (que usa alias `@/` do Lovable; wiring de imports fica para etapa posterior).
- **`ui/lovable/.git`:** não existia; nenhuma ação.

---

## 5. Resultado do build

- Comando: `npm run build`
- Resultado: **sucesso** (exit 0).
- Saída relevante:
  - `tsc -b && vite build` concluído.
  - `dist/index.html`, `dist/assets/index-*.css`, `dist/assets/index-*.js` gerados.
  - Aviso PostCSS sobre ordem de `@import` em outro CSS (design-system), não em Lovable.

---

## 6. Validação

- [x] Estrutura canônica `src/ui/lovable/{components,pages,lib,hooks,contexts,assets,styles,app-standalone}` criada.
- [x] Conteúdo consolidado por move (não cópia); duplicações removidas da raiz de `src/ui/`.
- [x] App standalone arquivado em `ui/lovable/_archived_root/`.
- [x] Estilos Lovable plugados em `src/main.tsx`.
- [x] Build do app principal passa; `src/ui/lovable` excluído do tsconfig.app para evitar erros de alias até wiring futuro.

---

*Fim do relatório.*
