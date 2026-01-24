-- HUMANTRÍA — FOUNDATION SCHEMA
-- Status: BLOQUEANTE
-- Escopo: Infraestrutura transversal (tenancy, security, audit, events)

-- Schema foundation
CREATE SCHEMA IF NOT EXISTS foundation;

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Comentários
COMMENT ON SCHEMA foundation IS 'Infraestrutura transversal: tenancy, security, audit, events, privacy, ia governance, billing infra, flags/quotas, templates';
