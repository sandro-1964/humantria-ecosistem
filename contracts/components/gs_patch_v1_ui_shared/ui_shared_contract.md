# HUMANTRÍA — COMPONENTS — GS-PATCH V1 — UI Shared Contract

Status: OBRIGATÓRIO (Patch-only V1)
Escopo: componentes transversais de UI (runtime), microcopy e gating de menu

## Objetivo

Padronizar:
- **estados de UI** (loading/empty/error/access denied),
- **microcopy mínima** (curta, reutilizável, sem marketing),
- **safe rendering** (nunca renderizar objeto/array cru),
- **menu gating** por role/permissão (UI-only).

## Regras canônicas (fonte de verdade)

- `docs/_canon/05_ui_contract.md` (soberano)
- `docs/_canon/04_dev_non_stop_method.md`
- `docs/_canon/07_observability.md`
- `contracts/ui/ui_contract.md`
- `contracts/ui/states_contract.md`
- `contracts/ui/routing_contract.md`
- `contracts/ui/responsive_contract.md`

## Não-escopo (bloqueante)

- ❌ Não criar/alterar SQL.
- ❌ Não executar MCP.
- ❌ Não reestruturar o app nem alterar arquitetura.
- ❌ Não criar features/páginas novas.
- ❌ UI não substitui RLS/RBAC: **RLS manda**; UI só “esconde” e “bloqueia” visualmente via guards.

## Safe rendering (obrigatório)

- A UI **nunca** renderiza JSON/objeto/array cru.
- Todo valor potencialmente não-primitivo deve passar por `toText(value)` antes de ir para JSX.

## Microcopy (obrigatório)

- Centralizar chaves mínimas em `src/i18n/locales/{pt-BR,en-US}.json`.
- Textos **curtos e reutilizáveis** para estados padrão e mensagens de permissão.

## Menu gating (obrigatório, UI-only)

- `MenuGate` decide se um item do menu é renderizado (ou `null`).
- Não altera rotas nem garante acesso; apenas evita expor itens para roles/perms não autorizados.

