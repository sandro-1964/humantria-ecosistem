-- HUMANTRÍA — STRATEGY — GS-PATCH V1 — UI APIs (READ-ONLY)
-- Arquivo: 003_patch_grants_rls.sql
-- Status: PATCH-ONLY
--
-- Objetivo: grants mínimos e auditáveis para consumo via Supabase (authenticated).
-- Regra: NÃO relaxar RLS (nenhuma policy deve ser criada/alterada).
--
SET search_path TO strategy, foundation, public;

-- Schema existente (produto Strategy V1): não revogar USAGE global do schema por risco.
-- Conceder apenas o mínimo necessário para RPCs via Supabase.
GRANT USAGE ON SCHEMA strategy TO authenticated;

-- Fechar superfície: retirar EXECUTE de PUBLIC (inclui helpers internos).
REVOKE ALL ON FUNCTION strategy._gs_patch_v1_ui_apis_get_correlation_id() FROM PUBLIC;
REVOKE ALL ON FUNCTION strategy._gs_patch_v1_ui_apis_assert_tenant(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION strategy._gs_patch_v1_ui_apis_cycle_id(UUID, TEXT, DATE, DATE) FROM PUBLIC;

REVOKE ALL ON FUNCTION strategy.list_cycles(UUID, INT) FROM PUBLIC;
REVOKE ALL ON FUNCTION strategy.get_cycle(UUID, UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION strategy.list_initiatives(UUID, UUID, INT) FROM PUBLIC;
REVOKE ALL ON FUNCTION strategy.get_initiative(UUID, UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION strategy.get_portfolio_snapshot(UUID, UUID) FROM PUBLIC;

-- Funções públicas: liberar apenas para authenticated (UI/RPC via Supabase).
GRANT EXECUTE ON FUNCTION strategy.list_cycles(UUID, INT) TO authenticated;
GRANT EXECUTE ON FUNCTION strategy.get_cycle(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION strategy.list_initiatives(UUID, UUID, INT) TO authenticated;
GRANT EXECUTE ON FUNCTION strategy.get_initiative(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION strategy.get_portfolio_snapshot(UUID, UUID) TO authenticated;


