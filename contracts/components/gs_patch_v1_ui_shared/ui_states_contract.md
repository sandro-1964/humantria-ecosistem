# HUMANTRÍA — COMPONENTS — GS-PATCH V1 — UI States Contract

Status: OBRIGATÓRIO (Patch-only V1)
Escopo: componentes reutilizáveis de estado e microcopy mínima associada

## Fonte canônica

- `contracts/ui/states_contract.md` (local)
- `docs/_canon/05_ui_contract.md` (soberano)
- `docs/_canon/07_observability.md`

## Princípio

É proibido “tela em branco”.

Todo async precisa de estados explícitos:
- loading
- empty
- error
- success
- access denied (quando aplicável)

## Componentes (V1)

Local: `src/components/states/*`

Todos os componentes:
- **não renderizam objetos/arrays crus** (qualquer texto passa por `toText()`),
- suportam `testid` (para evidência/teste),
- podem receber `icon` (opcional) como `ReactNode` seguro (não dados crus).

### `LoadingState`

Props:
- `title?: string`
- `message?: string`
- `icon?: ReactNode`
- `testid?: string`

### `EmptyState`

Props:
- `title?: string`
- `message?: string`
- `actions?: ReactNode`
- `icon?: ReactNode`
- `testid?: string`

### `ErrorState`

Props:
- `title?: string`
- `message?: string`
- `details?: string` (texto normalizado; nunca objeto cru)
- `actions?: ReactNode`
- `icon?: ReactNode`
- `testid?: string`

Regras:
- deve oferecer caminho claro para o DIAG (`/__diag`).

### `AccessDeniedState`

Props:
- `title?: string`
- `message?: string`
- `actions?: ReactNode`
- `icon?: ReactNode`
- `testid?: string`

Regras:
- microcopy mínima e reutilizável (i18n).

