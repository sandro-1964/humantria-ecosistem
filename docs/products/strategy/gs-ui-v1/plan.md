Strategy UI Integration (Lovable → App)
Current state (findings)
Repo: Vite + React app; no React Router, no Shell, no Strategy pages, no Lovable kit under src/ yet. src/ui/lovable/ and src/app/pages/strategy/ are absent or empty.
Canon: docs/_canon/05_ui_contract.md requires renderValue()/toText() for all displayed data; no raw objects/arrays in JSX. docs/products/strategy/gs-ui-v1/contracts.md reuses existing RPCs (e.g. strategy_objectives_list, strategy_objective_create).
Scope (IN): Strategy pages + Shell visual only; adapters under src/app/strategy/. OUT: DB, SQL contracts, new RPCs, other products.
--

Phase A — Bridge / adapters (no UI changes yet)
Lovable barrel  
Add src/ui/lovable/index.ts that re-exports from the kit’s components/ui, components/layout, etc., so the app has a single entry point. Resolve any Lovable @/ aliases via Vite/TS aliases in vite.config.ts and tsconfig so @/ points to src/ (or the path where Lovable expects its modules).

Strategy adapters  
Components: src/app/strategy/components/lovable.ts (or similar) — thin re-exports, e.g. export { Button } from "@/ui/lovable/..." (paths aligned with repo aliases). No new UI logic.  
Optional structure (only if reorganising by product):  
src/app/strategy/pages/ — page components that use Lovable (can re-export from src/app/pages/strategy/* or move gradually).  
src/app/strategy/services/ — composition of existing API/RPC calls only.  
src/app/strategy/hooks/ — UI/state hooks only (e.g. local form state), no new business rules.
Styles  
Ensure Lovable CSS is loaded once (e.g. in src/main.tsx) and does not conflict with existing src/index.css / src/App.css. No new Tailwind install per spec; use the kit’s existing CSS.

Validation  
After Phase A: npm run build passes; no change to route paths or to what’s rendered on Strategy pages yet.

---

Phase B — Apply Lovable to Strategy pages (JSX/layout only)
Apply Lovable components only to layout/JSX. Do not change queries, mutations, RPC calls, or business logic.

Order (as specified):

StrategyHomePage  
ObjectivesListPage  
ObjectiveDetailPage  
ObjectiveApprovePage  
InitiativesListPage  
InitiativeDetailPage  
SnapshotPage  
ObjectiveFormPage, InitiativeFormPage
Per-page rules:

Replace only markup/layout with Lovable primitives (e.g. Card, Table, Button, Sidebar sections).  
Keep all data display through toText() / renderValue() (UI Contract); never render raw objects/arrays/JSON.  
Preserve loading/empty/error states (skeleton/spinner, empty state, error message).  
Keep existing route paths; pages can live under src/app/pages/strategy/* and optionally be re-exported or wrapped from src/app/strategy/pages/ if that structure is used.
---

Phase C — Shell (AppShell)
File: src/shell/AppShell.tsx (or current Shell path).  
Change: Replace only the visual layout with Lovable Shell components (e.g. Sidebar, Header, layout grid).  
Preserve: MenuGate, RequireRole, navigation config, providers, <Outlet />, and any role-based visibility of menu items (no new items for roles that shouldn’t see them).
---

Routing and build
Routes: Strategy paths stay as defined in the router (e.g. in src/app/router/routes.tsx or equivalent). No path renames.  
Build: Run npm run build after each phase; fix any alias/import or type errors so the build stays green.
---

Acceptance (PASS/FAIL)
| Criterion | PASS | FAIL |

|-----------|------|------|

| Build | npm run build succeeds | Any build failure |

| Routes | Strategy routes unchanged and reachable | Path changes or blank Strategy pages |

| UI Contract | All displayed data via toText()/renderValue() | Raw JSON/objects in UI |

| Scope | Only Strategy + Shell visual; no DB/RPC/contract changes | New RPCs, schema, or cross-product changes |

| Shell | Sidebar visibility by role unchanged | Items visible to roles that shouldn’t see them |

---

Evidence to capture (before commit/push)
git diff --stat and list of touched files.  
Log/screenshot of successful npm run build.  
Short compatibility note: how @/ (or other Lovable aliases) was resolved (e.g. vite.config/tsconfig alias).
---

Risks and mitigations
| Risk | Mitigation |

|------|------------|

| Lovable @/ breaks in app | Use adapters + repo-wide path alias so all Lovable imports go through one place. |

| CSS/Tailwind conflicts | Do not add Tailwind; use Lovable’s shipped CSS and a single import in main.tsx. |

| Scope creep to other products | Restrict changes to Strategy pages and Shell; no Foundation/Core/Bridges UI. |

---

Out of scope (do not do)
New or changed DB tables, RLS, SQL in contracts/.  
New RPCs or changes to existing RPC signatures.  
New “full” CRUD beyond existing Strategy flows.  
Global app architecture or provider changes.  
Integrating Lovable into non-Strategy areas (except Shell layout).
---