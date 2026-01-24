# HUMANTRÍA — Project Rules (Canonical)

## Repository structure (immutable)
- docs/_canon = immutable canonical rules
- contracts/* = SQL contracts executed via Supabase MCP
- ui/* = UI runtime and pages
- data/seed/* = seed datasets (technical/functional/demo/edge)
- prompts/* = operational prompts (PLAN/DEV/AUDIT/HANDOFF/DESIGN)

## Execution rules
- No manual DB edits; only via MCP + SQL under contracts/.
- All changes must be traceable to a canon rule or a PRD/decision.
- New functionality never reopens closed scope; use new version or patch rituals.

## UI runtime rules
- Providers: Structural always mounted; Functional gated.
- Add global Loading + System Messages.
- DIAG routes must exist and never be removed.

## Evidence requirements
- Each implemented step includes a short validation section (what was tested and how).
