-- HUMANTRÍA — CORE — GS-PATCH V1 — UI/APIs mínimas
-- Arquivo: 003_patch_grants_rls.sql
-- Status: PATCH (Core V1 frozen)
--
-- Objetivo: ajustes mínimos de grants/RLS, apenas se necessário.
-- Regra: NÃO relaxar RLS.

SET search_path TO core, foundation, public;

-- Nota:
-- - Este patch cria apenas funções SECURITY INVOKER e lê tabelas que já possuem RLS/policies canônicas.
-- - Nenhum ajuste de RLS/grants é necessário no momento.

