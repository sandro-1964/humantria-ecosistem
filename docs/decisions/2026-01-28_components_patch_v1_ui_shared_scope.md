# Decision — 2026-01-28 — components patch v1 ui shared (scope)

## Contexto

Necessidade de padronizar runtime de UI (estados, microcopy mínima, safe rendering e menu gating) sem introduzir features novas e sem qualquer alteração de SQL/MCP.

Fontes canônicas:
- `docs/_canon/05_ui_contract.md`
- `docs/_canon/04_dev_non_stop_method.md`
- `docs/_canon/07_observability.md`
- `contracts/ui/*`

## Decisão

Implementar um GS-PATCH V1 de UI Shared com:
- componentes padrão de estados em `src/components/states/*` (API: `title`, `message`, `actions?`, `icon?`, `testid?`)
- consolidação/fortalecimento de `toText()` em `src/lib/to-text.ts`
- chaves mínimas de i18n para estados e permissão
- `MenuGate` (`src/components/guards/MenuGate.tsx`) para esconder itens do menu conforme RBAC (UI-only)
- aplicação mínima em 3 páginas existentes

## Não-escopo (bloqueante)

- Sem SQL / sem MCP.
- Sem rotas/páginas novas.
- Sem alteração estrutural de arquitetura.
- UI não substitui RLS/RBAC.

## Evidências esperadas

- `npm run build` passa.
- 3 páginas usando os componentes padrão de estado.
- Evidência de menu escondendo itens restritos para role não-admin (descrição + screenshot).

