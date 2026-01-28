# HUMANTRÍA — Validation Report — GS-PATCH V1 — UI Shared

Data: 2026-01-28
Branch: components-gs-patch-v1-ui-shared
Escopo: componentes transversais de UI (estados, microcopy, menu gating, safe rendering)

## Checklist de validação (obrigatório)

- [ ] `npm run build` (evidência abaixo)
- [ ] Estados padrão aplicados em 3 páginas (evidências abaixo)
- [ ] Menu gating: item restrito não aparece para role não-admin (evidência abaixo)
- [ ] Sem SQL/MCP (confirmado por diff/paths)

## Evidência — build

Comando:
- `npm run build`

Resultado:
- OK (2026-01-28)
- Output (resumo):
  - `tsc -b && vite build` (exit code 0)
  - `✓ built` (vite)

## Evidência — páginas usando estados padrão

### 1) `TenantsListPage`
- Arquivo: `src/app/pages/foundation/tenants/TenantsListPage.tsx`
- Evidência (objetiva):
  - `LoadingState` com `testid="state-loading-tenants"`
  - `EmptyState` com `testid="state-empty-tenants"`
  - `ErrorState` com `testid="state-error-tenants"`

### 2) `AuditTimelinePage`
- Arquivo: `src/app/pages/foundation/audit/AuditTimelinePage.tsx`
- Evidência (objetiva):
  - `LoadingState` com `testid="state-loading-audit"`
  - `EmptyState` com `testid="state-empty-audit"`
  - `ErrorState` com `testid="state-error-audit"`

### 3) `ToolsLegacyIntegrationsPage`
- Arquivo: `src/app/pages/tools/ToolsLegacyIntegrationsPage.tsx`
- Evidência (objetiva):
  - `EmptyState` com `testid="state-empty-legacy-integrations"`

## Evidência — menu gating (RBAC, UI-only)

Caso:
- Role não-admin (ex.: `auditor`) não vê item restrito no sidebar (ex.: “Legacy Integrations”).

Evidência:
- `src/shell/AppShell.tsx` aplica `MenuGate allowRoles={['platform_owner','tenant_admin']}` no item `/tools/legacy-integrations` (não renderiza para `auditor`).
- Observação: evidência visual (screenshot) pendente de captura manual pelo humano, se desejado.

