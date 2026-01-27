# HUMANTRÍA — CORE — GS-PATCH V1 — UI/APIs mínimas — Migration Execution Log

**Data:** 2026-01-27  
**Branch:** `core-gs-patch-v1-ui-apis`  
**Executor:** Cursor DEV (MCP)  

## Ordem canônica de execução (MCP)

1. `contracts/core/gs_patch_v1_ui_apis/001_patch_schema.sql`
2. `contracts/core/gs_patch_v1_ui_apis/002_patch_functions.sql`
3. `contracts/core/gs_patch_v1_ui_apis/003_patch_grants_rls.sql`
4. `contracts/core/gs_patch_v1_ui_apis/004_patch_seed_demo.sql`

## Log (preencher com evidência)

### Execução 001 — schema (no-op)
- **Timestamp:** 2026-01-27
- **MCP command:** `apply_migration` (project_id: `vpsqhmklecjvbnlhktbg`, name: `core_gs_patch_v1_ui_apis_001_patch_schema`)
- **Resultado:** `{"success":true}`

### Execução 002 — functions
- **Timestamp:** 2026-01-27
- **MCP command:** `apply_migration` (project_id: `vpsqhmklecjvbnlhktbg`, name: `core_gs_patch_v1_ui_apis_002_patch_functions`)
- **Resultado:** `{"success":true}`
-
- **Reexecução (fix compatibilidade DB)**:
  - **Motivo:** coluna `core.job_levels.level_number` não existe no DB alvo; o canônico implantado usa `seniority_level`.
  - **MCP command:** `apply_migration` (project_id: `vpsqhmklecjvbnlhktbg`, name: `core_gs_patch_v1_ui_apis_002_patch_functions_fix_job_levels_column`)
  - **Resultado:** `{"success":true}`

### Execução 003 — grants/rls (no-op)
- **Timestamp:** 2026-01-27
- **MCP command:** `apply_migration` (project_id: `vpsqhmklecjvbnlhktbg`, name: `core_gs_patch_v1_ui_apis_003_patch_grants_rls`)
- **Resultado:** `{"success":true}`

### Execução 004 — seed (no-op)
- **Timestamp:** 2026-01-27
- **MCP command:** `apply_migration` (project_id: `vpsqhmklecjvbnlhktbg`, name: `core_gs_patch_v1_ui_apis_004_patch_seed_demo`)
- **Resultado:** `{"success":true}`

## Observações

- Proibido executar SQL manual fora dos contratos.
- Se houver erro, registrar o `correlation_id` reportado (quando disponível) e anexar no validation report.

