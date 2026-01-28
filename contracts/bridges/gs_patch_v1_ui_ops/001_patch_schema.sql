-- HUMANTRÍA — BRIDGES — GS-PATCH V1 — UI Ops
-- Arquivo: 001_patch_schema.sql
-- Status: PATCH (bridge-first; troubleshooting UI fase 1)
--
-- Objetivo: garantir schema `bridges` para RPCs de UI Ops (idempotente).

CREATE SCHEMA IF NOT EXISTS bridges;

COMMENT ON SCHEMA bridges IS 'BRIDGES: integrações e UI Ops (troubleshooting) — GS-PATCH V1';

