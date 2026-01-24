-- HUMANTRÍA — CORE SCHEMA
-- Status: BLOQUEANTE
-- Escopo: Semântica canônica do cliente (org, people, jobs/levels, cost centers, vínculos, import)

-- Schema core
CREATE SCHEMA IF NOT EXISTS core;

-- Extensões necessárias (já devem existir em foundation, mas garantindo)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Comentários
COMMENT ON SCHEMA core IS 'Semântica canônica do cliente: org, people, jobs/levels, cost centers, vínculos, import';
