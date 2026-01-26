-- HUMANTRÍA — STRATEGY SCHEMA V1
-- Status: BLOQUEANTE
-- Escopo: Produto Strategy (objetivos, orçamento, staffing, simulações, workflows)

-- Schema strategy
CREATE SCHEMA IF NOT EXISTS strategy;

-- Extensões necessárias (já devem existir em foundation/core, mas garantindo)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Comentários
COMMENT ON SCHEMA strategy IS 'Produto Strategy: objetivos & metas (OKR/BSC), orçamento, staffing plan, simulações & IA, workflows de aprovação, dashboards executivos';
