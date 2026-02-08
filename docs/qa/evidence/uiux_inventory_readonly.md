# Levantamento UI/UX — Inventário + Fonte ativa (somente leitura)

**Data:** 2026-02-08  
**Escopo:** Listar docs e pastas UI/UX; classificar fonte ativa, duplicados/candidatos a archive, docs por GS.  
**Restrições:** Nenhum arquivo movido ou renomeado; somente leitura + relatório.

---

## A) Fonte ativa (caminho + por quê)

| Caminho | Papel | Por quê |
|---------|--------|---------|
| **src/ui/lovable/** | Kit UI (Lovable) | Fonte canônica do kit: componentes (ui, layout, features), páginas, hooks, contexts, lib, styles, assets. Entrada: `index.ts`. Definido em `docs/products/strategy/gs-ui-v1/contracts.md` e `docs/qa/lovable_import_report.md`. |
| **src/shell/** | Shell da aplicação | Layout global: `AppShell.tsx`. Contrato GS-UI-V1. |
| **src/app/** | Rotas e páginas Strategy (app) | Router (`app/router/**`), páginas de Strategy (`app/pages/strategy/**`), adapters (`app/strategy/components/lovable.ts`), `ui_contract/toText.ts`. Páginas ativas: StrategyHomePage, ObjectivesPage, DashboardPage, ApprovalsPage; diag: DiagPage, DiagnosticsPage. |
| **docs/_canon/05_ui_contract.md** | Regra UI | Contrato obrigatório: toText/renderValue, sem objetos/arrays crus em JSX, rota /__diag. |
| **docs/_canon/09_naming_and_structure.md** | Estrutura/naming | kebab-case, minúsculas. |
| **docs/qa/lovable_import_report.md** | Histórico da estrutura UI | Descreve a consolidação em `src/ui/lovable/` e o que não usar (app-standalone, _archived_root). |

**Não usar em runtime:** `src/ui/lovable/app-standalone/`, `ui/lovable/_archived_root/` (standalone Lovable arquivado).

**Observação:** No estado atual do repositório, `docs/ui/` existe como pasta mas está vazia (sem README_UI_CANON ou INDEX). A referência de “fonte ativa” acima vem de contracts e lovable_import_report.

---

## B) Docs por GS (links)

### GS-UI-V1 (presente no repo)

| Doc | Caminho |
|-----|---------|
| Contracts | [docs/products/strategy/gs-ui-v1/contracts.md](../../products/strategy/gs-ui-v1/contracts.md) |
| Plan | [docs/products/strategy/gs-ui-v1/plan.md](../../products/strategy/gs-ui-v1/plan.md) |
| PRD | [docs/products/strategy/gs-ui-v1/PRD.md](../../products/strategy/gs-ui-v1/PRD.md) |
| Validation report | [docs/products/strategy/gs-ui-v1/validation_report.md](../../products/strategy/gs-ui-v1/validation_report.md) |
| Relatório estado | [docs/products/strategy/gs-ui-v1/RELATORIO_ESTADO_GS_UI_V1.md](../../products/strategy/gs-ui-v1/RELATORIO_ESTADO_GS_UI_V1.md) |

### GS-UI-V2 / V2.1 / V2.2

No inventário atual (listagem recursiva de `docs/`) **não aparecem** pastas ou ficheiros em `docs/products/strategy/gs-ui-v2/`, `gs-ui-v2.1/` ou `gs-ui-v2.2/`. Se existirem noutra branch ou só localmente, devem ser listados aqui à mão e ligados ao mesmo formato de links acima.

---

## C) Duplicados / sobrepostos (caminhos + recomendação)

| Caminho(s) | Tema | Recomendação |
|------------|------|----------------|
| **validation_report.md** em: gs-ui-v1, foundation, core | Nome igual, escopos diferentes (UI Strategy vs Foundation vs Core contracts). | **Manter** os três: não são duplicados de conteúdo; são relatórios de validação por domínio. |
| **RELATORIO_ESTADO_GS_UI_V1.md** (gs-ui-v1) | Estado “onde estamos” GS-UI-V1. | **Manter** como relatório único do V1. |
| **lovable_import_report.md** (qa) | Estrutura final do kit em src/ui/lovable. | **Manter** como referência histórica e de estrutura; candidato a ser referenciado por um futuro README em docs/ui/. |
| **README / INDEX** | Nenhum ficheiro README ou INDEX encontrado em docs/ui/ ou em gs-ui-v2.2 no inventário. | Se forem criados (ex.: README_UI_CANON.md, INDEX.md em gs-ui-v2.2), evitar duplicar o mesmo conteúdo em vários sítios; um índice por GS é suficiente. |
| **docs/ui/** (pasta vazia) | Destino natural para “fonte ativa” UI. | **Manter** pasta; preencher com README_UI_CANON (ou equivalente) quando houver decisão de consolidar. |
| **docs/_archive/ui/** | Pasta para docs UI descontinuados. | **Manter**; usar para arquivar apenas quando um doc for explicitamente descontinuado (com carimbo). |

Não foi identificado nenhum par de documentos com conteúdo duplicado que exija arquivar um deles no estado atual.

---

## D) Proposta de organização (sem executar) — árvore sugerida

```
docs/
  _canon/
    05_ui_contract.md          # já existe
    09_naming_and_structure.md # já existe
  ui/
    README_UI_CANON.md        # criar: 1 página com fonte ativa (src/ui/lovable, src/shell) + regras + links
  _archive/
    ui/
      README.md               # opcional: explicar uso da pasta para descontinuados
  qa/
    lovable_import_report.md   # manter
    evidence/
      uiux_inventory_readonly.md  # este relatório
  products/
    strategy/
      gs-ui-v1/               # manter como está
        contracts.md, plan.md, PRD.md, validation_report.md, RELATORIO_ESTADO_GS_UI_V1.md
      gs-ui-v2/               # se existir: validation_report_step1_shell, step2_one-real-screen
      gs-ui-v2.1/             # se existir: validation_report.md
      gs-ui-v2.2/             # se existir: validation_report.md + INDEX.md (links para validation + docs/ui)
```

Regra sugerida: **não mover nem renomear** ficheiros existentes; apenas **criar** README/INDEX onde faltar e **arquivar** em `docs/_archive/ui/` só quando um doc for descontinuado com carimbo.

---

## E) Evidências — comandos e outputs resumidos

### 1) Listagem de diretórios UI (resumo)

- **src/ui/lovable/** — Contém: app-standalone, assets, components (features, layout, ui), contexts, hooks, lib, pages (bridges, chronos, core, foundation, grc, strategy, talent, tools, …), styles, index.ts.
- **src/shell/** — Contém: AppShell.tsx.
- **src/app/** — Contém: pages (diag, strategy, DiagnosticsPage), router (AppRouter, routes), strategy/components (lovable.ts), ui_contract (toText.ts). Strategy pages: ApprovalsPage, DashboardPage, ObjectivesPage, StrategyHomePage.
- **docs/ui/** — Pasta existe; sem ficheiros listados no inventário.
- **docs/products/strategy/** — Subpastas listadas: gs-ui-v1 (contracts, plan, PRD, RELATORIO_ESTADO_GS_UI_V1, validation_report). gs-ui-v2, gs-ui-v2.1, gs-ui-v2.2 não apareceram na listagem recursiva de ficheiros.

### 2) Comandos usados

- `Get-ChildItem -Path docs -Recurse -File` → lista de 24 ficheiros em docs (sem ficheiros em docs/ui nem em docs/_archive).
- `Test-Path docs/ui`, `Test-Path docs/_archive` → True (pastas existem).
- `list_dir` (LS) em src/ui/lovable, src/shell, src/app, docs/ui, docs/products/strategy.
- `Grep` / `Glob` para README, INDEX, validation_report, RELATORIO, lovable_import, ui_ux_docs em docs.

### 3) Docs por nome/tema (encontrados)

- **validation_report:** docs/products/strategy/gs-ui-v1/validation_report.md, docs/foundation/validation_report.md, docs/core/validation_report.md.
- **RELATORIO_*:** docs/products/strategy/gs-ui-v1/RELATORIO_ESTADO_GS_UI_V1.md.
- **lovable_import_report:** docs/qa/lovable_import_report.md.
- **README / INDEX:** nenhum em docs no inventário.
- **ui_ux_docs_organization:** não encontrado (possível evidência de outra branch ou tarefa anterior).

---

**Fim do relatório. Nenhum ficheiro foi movido ou renomeado.**
