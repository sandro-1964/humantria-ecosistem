GS-UI-V1 — PRD (Strategy UI Integration Lovable)
Objetivo

Aplicar o design do Lovable (layout + componentes + estilos) ao Strategy e ao AppShell, mantendo 100% do comportamento atual (rotas, dados, permissões, RPCs, testes).

Contexto

O kit Lovable foi importado para src/ui/lovable/** e o export standalone foi arquivado em ui/lovable/_archived_root/**.

O Strategy já possui páginas funcionais em src/app/pages/strategy/**.

Esta GS é visual/UX apenas.

Escopo IN

Adaptação/Ligação (Bridge)

Criar adapters de import (ex.: src/app/strategy/components/lovable.ts) para centralizar imports do kit Lovable.

Resolver alias @/ do Lovable sem espalhar mudanças (preferir config + adapter).

Aplicar Lovable nas páginas Strategy (somente JSX/layout)
Ordem:

StrategyHomePage

ObjectivesListPage

ObjectiveDetailPage

ObjectiveApprovePage

InitiativesListPage

InitiativeDetailPage

SnapshotPage

ObjectiveFormPage + InitiativeFormPage (por último, pois são placeholders)

Aplicar Lovable no AppShell

Trocar apenas o layout visual (Sidebar/Header/Layout).

Preservar MenuGate/RequireRole/Outlet e regras de visibilidade por role.

Escopo OUT

Qualquer alteração em: DB, SQL contracts, RPCs, hooks de dados, regras de negócio, seeds, RLS.

Integrar Lovable em outros produtos (Foundation/Core/Bridges) nesta GS.

Regras (não negociáveis)

UI Contract: renderização de dados só via toText()/renderValue().

Rotas/paths não mudam.

Calls RPC não mudam.

Build deve permanecer verde continuamente.

Entregáveis

Páginas Strategy com componentes Lovable (skin aplicada).

AppShell com layout Lovable.

docs/products/strategy/gs-ui-v1/plan.md

docs/products/strategy/gs-ui-v1/validation_report.md

Critérios de Aceite

npm run build PASS

Navegação Strategy sem mudanças de path

Nenhum objeto cru em JSX (UI Contract) PASS

Sidebar visibilidade por role inalterada