-- HUMANTRÍA — BRIDGES — GS-PATCH V1 — UI Ops
-- Arquivo: 003_patch_grants_rls.sql
-- Status: PATCH
--
-- Objetivo: grants mínimos e auditáveis para consumo via Supabase (authenticated).
-- Regra: NÃO relaxar RLS (nenhuma policy alterada).

SET search_path TO bridges, foundation, public;

-- Fechar superfície padrão
REVOKE ALL ON SCHEMA bridges FROM PUBLIC;
GRANT USAGE ON SCHEMA bridges TO authenticated;

-- Funções: retirar EXECUTE de PUBLIC e liberar apenas para authenticated
REVOKE ALL ON FUNCTION bridges._gs_patch_v1_ui_ops_get_correlation_id() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION bridges._gs_patch_v1_ui_ops_get_correlation_id() TO authenticated;

REVOKE ALL ON FUNCTION bridges._gs_patch_v1_ui_ops_assert_tenant(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION bridges._gs_patch_v1_ui_ops_assert_tenant(UUID) TO authenticated;

REVOKE ALL ON FUNCTION bridges.list_outbox_events(UUID, INT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION bridges.list_outbox_events(UUID, INT, TEXT) TO authenticated;

REVOKE ALL ON FUNCTION bridges.get_outbox_event(UUID, UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION bridges.get_outbox_event(UUID, UUID) TO authenticated;

REVOKE ALL ON FUNCTION bridges.list_failed_events(UUID, INT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION bridges.list_failed_events(UUID, INT) TO authenticated;

REVOKE ALL ON FUNCTION bridges.request_event_replay(UUID, UUID, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION bridges.request_event_replay(UUID, UUID, TEXT) TO authenticated;

