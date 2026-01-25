-- HUMANTRÍA — CORE PATCH ECONOMICS V1 — TABLES
-- Status: PATCH (Core V1 frozen)
-- Escopo: Workforce Economics Engine (parâmetros econômicos estruturais)
-- Regras: Apenas novas tabelas, schema core, multi-tenant, RLS obrigatório

SET search_path TO core, foundation, public;

-- ============================================================================
-- A) CURRENCIES & EXCHANGE RATES
-- ============================================================================

-- Currencies (catálogo de moedas)
CREATE TABLE IF NOT EXISTS core.currencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES foundation.tenants(id) ON DELETE CASCADE, -- NULL = global
    code TEXT NOT NULL, -- ISO 4217 (BRL, USD, EUR, etc.)
    name TEXT NOT NULL,
    symbol TEXT,
    decimal_places INTEGER DEFAULT 2,
    is_active BOOLEAN DEFAULT TRUE,
    is_base_currency BOOLEAN DEFAULT FALSE, -- Moeda base do tenant
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE INDEX IF NOT EXISTS idx_currencies_tenant_id ON core.currencies(tenant_id);
CREATE INDEX IF NOT EXISTS idx_currencies_code ON core.currencies(code);
CREATE INDEX IF NOT EXISTS idx_currencies_is_active ON core.currencies(is_active);

COMMENT ON TABLE core.currencies IS 'Catálogo de moedas (global ou por tenant)';
COMMENT ON COLUMN core.currencies.tenant_id IS 'NULL = catálogo global, UUID = moeda específica do tenant';

-- Exchange Rates (taxas de câmbio)
CREATE TABLE IF NOT EXISTS core.exchange_rates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES foundation.tenants(id) ON DELETE CASCADE, -- NULL = global
    from_currency_code TEXT NOT NULL, -- Moeda origem
    to_currency_code TEXT NOT NULL, -- Moeda destino
    rate NUMERIC NOT NULL CHECK (rate > 0), -- Taxa de câmbio (1 from = rate to)
    effective_from DATE NOT NULL,
    effective_to DATE, -- NULL = vigente
    source TEXT, -- Fonte da taxa (manual, api, etc.)
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    UNIQUE(tenant_id, from_currency_code, to_currency_code, effective_from)
);

CREATE INDEX IF NOT EXISTS idx_exchange_rates_tenant_id ON core.exchange_rates(tenant_id);
CREATE INDEX IF NOT EXISTS idx_exchange_rates_currencies ON core.exchange_rates(from_currency_code, to_currency_code);
CREATE INDEX IF NOT EXISTS idx_exchange_rates_effective ON core.exchange_rates(effective_from, effective_to);

COMMENT ON TABLE core.exchange_rates IS 'Taxas de câmbio (com effective dating)';
COMMENT ON COLUMN core.exchange_rates.rate IS 'Taxa: 1 from_currency = rate to_currency';

-- ============================================================================
-- B) SALARY STRUCTURES
-- ============================================================================

-- Salary Structures (estruturas de remuneração por job/level)
CREATE TABLE IF NOT EXISTS core.salary_structures (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    job_id UUID REFERENCES core.jobs(id) ON DELETE SET NULL, -- NULL = global para job
    job_level_id UUID REFERENCES core.job_levels(id) ON DELETE SET NULL, -- NULL = global para level
    currency TEXT NOT NULL, -- Código da moeda (BRL, USD, etc.)
    effective_from DATE NOT NULL,
    effective_to DATE, -- NULL = vigente
    base_salary_min NUMERIC NOT NULL CHECK (base_salary_min >= 0),
    base_salary_max NUMERIC NOT NULL CHECK (base_salary_max >= base_salary_min),
    base_salary_mid NUMERIC CHECK (base_salary_mid >= base_salary_min AND base_salary_mid <= base_salary_max), -- Midpoint
    compensation_structure JSONB DEFAULT '{}'::jsonb, -- Estrutura de compensação (bonus, equity, etc.)
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

CREATE INDEX IF NOT EXISTS idx_salary_structures_tenant_id ON core.salary_structures(tenant_id);
CREATE INDEX IF NOT EXISTS idx_salary_structures_job_id ON core.salary_structures(job_id);
CREATE INDEX IF NOT EXISTS idx_salary_structures_job_level_id ON core.salary_structures(job_level_id);
CREATE INDEX IF NOT EXISTS idx_salary_structures_effective ON core.salary_structures(effective_from, effective_to);
CREATE INDEX IF NOT EXISTS idx_salary_structures_currency ON core.salary_structures(currency);

COMMENT ON TABLE core.salary_structures IS 'Estruturas de remuneração por job/level (faixas salariais)';
COMMENT ON COLUMN core.salary_structures.job_id IS 'NULL = estrutura global para o job';
COMMENT ON COLUMN core.salary_structures.job_level_id IS 'NULL = estrutura global para o level';
COMMENT ON COLUMN core.salary_structures.compensation_structure IS 'JSONB: {bonus: {...}, equity: {...}, benefits: {...}}';

-- Salary Structure History (histórico de mudanças)
CREATE TABLE IF NOT EXISTS core.salary_structure_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    salary_structure_id UUID NOT NULL REFERENCES core.salary_structures(id) ON DELETE CASCADE,
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    effective_from DATE NOT NULL,
    effective_to DATE,
    base_salary_min NUMERIC NOT NULL,
    base_salary_max NUMERIC NOT NULL,
    base_salary_mid NUMERIC,
    compensation_structure JSONB DEFAULT '{}'::jsonb,
    changed_by UUID,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_salary_structure_history_salary_structure_id ON core.salary_structure_history(salary_structure_id);
CREATE INDEX IF NOT EXISTS idx_salary_structure_history_tenant_id ON core.salary_structure_history(tenant_id);
CREATE INDEX IF NOT EXISTS idx_salary_structure_history_effective ON core.salary_structure_history(effective_from, effective_to);

COMMENT ON TABLE core.salary_structure_history IS 'Histórico de mudanças em estruturas salariais (auditoria)';

-- ============================================================================
-- C) COST PARAMETERS
-- ============================================================================

-- Cost Parameters (parâmetros de custo por job/level/org_unit)
CREATE TABLE IF NOT EXISTS core.cost_parameters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    job_id UUID REFERENCES core.jobs(id) ON DELETE SET NULL,
    job_level_id UUID REFERENCES core.job_levels(id) ON DELETE SET NULL,
    org_unit_id UUID REFERENCES core.org_units(id) ON DELETE SET NULL,
    cost_center_id UUID REFERENCES core.cost_centers(id) ON DELETE SET NULL,
    currency TEXT NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    base_cost NUMERIC NOT NULL CHECK (base_cost >= 0), -- Custo base
    overhead_rate NUMERIC CHECK (overhead_rate >= 0 AND overhead_rate <= 100), -- Taxa de overhead (%)
    total_cost_factor NUMERIC CHECK (total_cost_factor > 0), -- Fator de custo total (multiplicador)
    cost_breakdown JSONB DEFAULT '{}'::jsonb, -- Breakdown de custos (benefícios, impostos, etc.)
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

CREATE INDEX IF NOT EXISTS idx_cost_parameters_tenant_id ON core.cost_parameters(tenant_id);
CREATE INDEX IF NOT EXISTS idx_cost_parameters_job_id ON core.cost_parameters(job_id);
CREATE INDEX IF NOT EXISTS idx_cost_parameters_job_level_id ON core.cost_parameters(job_level_id);
CREATE INDEX IF NOT EXISTS idx_cost_parameters_org_unit_id ON core.cost_parameters(org_unit_id);
CREATE INDEX IF NOT EXISTS idx_cost_parameters_cost_center_id ON core.cost_parameters(cost_center_id);
CREATE INDEX IF NOT EXISTS idx_cost_parameters_effective ON core.cost_parameters(effective_from, effective_to);
CREATE INDEX IF NOT EXISTS idx_cost_parameters_currency ON core.cost_parameters(currency);

COMMENT ON TABLE core.cost_parameters IS 'Parâmetros de custo por job/level/org_unit/cost_center';
COMMENT ON COLUMN core.cost_parameters.cost_breakdown IS 'JSONB: {benefits: {...}, taxes: {...}, overhead: {...}}';

-- Cost Parameter History (histórico de mudanças)
CREATE TABLE IF NOT EXISTS core.cost_parameter_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cost_parameter_id UUID NOT NULL REFERENCES core.cost_parameters(id) ON DELETE CASCADE,
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    effective_from DATE NOT NULL,
    effective_to DATE,
    base_cost NUMERIC NOT NULL,
    overhead_rate NUMERIC,
    total_cost_factor NUMERIC,
    cost_breakdown JSONB DEFAULT '{}'::jsonb,
    changed_by UUID,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_cost_parameter_history_cost_parameter_id ON core.cost_parameter_history(cost_parameter_id);
CREATE INDEX IF NOT EXISTS idx_cost_parameter_history_tenant_id ON core.cost_parameter_history(tenant_id);
CREATE INDEX IF NOT EXISTS idx_cost_parameter_history_effective ON core.cost_parameter_history(effective_from, effective_to);

COMMENT ON TABLE core.cost_parameter_history IS 'Histórico de mudanças em parâmetros de custo';

-- ============================================================================
-- D) ECONOMIC BENCHMARKS
-- ============================================================================

-- Economic Benchmarks (benchmarks de mercado)
CREATE TABLE IF NOT EXISTS core.economic_benchmarks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES foundation.tenants(id) ON DELETE CASCADE, -- NULL = global
    benchmark_type TEXT NOT NULL CHECK (benchmark_type IN ('salary', 'cost', 'market_rate')),
    job_id UUID REFERENCES core.jobs(id) ON DELETE SET NULL,
    job_level_id UUID REFERENCES core.job_levels(id) ON DELETE SET NULL,
    region TEXT, -- Região geográfica
    industry TEXT, -- Setor/indústria
    currency TEXT NOT NULL,
    benchmark_value NUMERIC NOT NULL CHECK (benchmark_value >= 0),
    percentile INTEGER CHECK (percentile IN (25, 50, 75, 90)), -- Percentil do benchmark
    source TEXT, -- Fonte do benchmark (survey, api, manual, etc.)
    effective_from DATE NOT NULL,
    effective_to DATE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

CREATE INDEX IF NOT EXISTS idx_economic_benchmarks_tenant_id ON core.economic_benchmarks(tenant_id);
CREATE INDEX IF NOT EXISTS idx_economic_benchmarks_type ON core.economic_benchmarks(benchmark_type);
CREATE INDEX IF NOT EXISTS idx_economic_benchmarks_job_id ON core.economic_benchmarks(job_id);
CREATE INDEX IF NOT EXISTS idx_economic_benchmarks_job_level_id ON core.economic_benchmarks(job_level_id);
CREATE INDEX IF NOT EXISTS idx_economic_benchmarks_effective ON core.economic_benchmarks(effective_from, effective_to);
CREATE INDEX IF NOT EXISTS idx_economic_benchmarks_currency ON core.economic_benchmarks(currency);

COMMENT ON TABLE core.economic_benchmarks IS 'Benchmarks de mercado (global ou por tenant)';
COMMENT ON COLUMN core.economic_benchmarks.tenant_id IS 'NULL = benchmark global, UUID = benchmark específico do tenant';

-- ============================================================================
-- TRIGGERS: updated_at automático
-- ============================================================================

-- Aplicar trigger updated_at em todas as tabelas com updated_at
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT table_name 
        FROM information_schema.columns 
        WHERE table_schema = 'core' 
        AND column_name = 'updated_at'
        AND table_name IN (
            'currencies',
            'exchange_rates',
            'salary_structures',
            'cost_parameters',
            'economic_benchmarks'
        )
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS trigger_%s_updated_at ON core.%I', r.table_name, r.table_name);
        EXECUTE format('CREATE TRIGGER trigger_%s_updated_at BEFORE UPDATE ON core.%I FOR EACH ROW EXECUTE FUNCTION core.update_updated_at()', r.table_name, r.table_name);
    END LOOP;
END;
$$;
