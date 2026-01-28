-- HUMANTRÍA — STRATEGY — GS-PATCH V1 — UI APIs (READ-ONLY)
-- Arquivo: 001_patch_schema.sql
-- Status: PATCH-ONLY (sem features; sem engine nova)
--
-- Objetivo:
-- - No-op por padrão (zero risco).
-- - NÃO criar schema novo “strategy” se o produto no DB usa outro schema (ex.: strategy_rewards).
-- - Se o schema real existir no DB alvo, este patch não cria nada.
--
-- Regras:
-- - SECURITY INVOKER nas funções (definidas em 002).
-- - Não relaxar RLS.

-- no-op

