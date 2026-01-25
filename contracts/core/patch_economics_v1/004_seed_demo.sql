-- HUMANTRÍA — CORE PATCH ECONOMICS V1 — SEED DEMO
-- Status: OBRIGATÓRIO
-- Escopo: Seed idempotente para ambiente DEMO (Workforce Economics Engine)
-- Requisitos: currencies, exchange_rates, salary_structures, cost_parameters, economic_benchmarks

SET search_path TO core, foundation, public;

-- ============================================================================
-- SEED: IDEMPOTENTE (usa ON CONFLICT)
-- ============================================================================

-- Assumindo que o tenant demo já existe (criado em foundation/005_seed_demo.sql)
-- Tenant ID: 00000000-0000-0000-0000-000000000001 (acme-corp)

-- ============================================================================
-- A) CURRENCIES
-- ============================================================================

-- Currencies globais (tenant_id NULL)
INSERT INTO core.currencies (id, tenant_id, code, name, symbol, decimal_places, is_active, is_base_currency)
VALUES 
    ('f0000000-0000-0000-0000-000000000001'::uuid, NULL, 'BRL', 'Real Brasileiro', 'R$', 2, TRUE, FALSE),
    ('f0000000-0000-0000-0000-000000000002'::uuid, NULL, 'USD', 'US Dollar', '$', 2, TRUE, FALSE),
    ('f0000000-0000-0000-0000-000000000003'::uuid, NULL, 'EUR', 'Euro', '€', 2, TRUE, FALSE)
ON CONFLICT (tenant_id, code) DO UPDATE SET
    name = EXCLUDED.name,
    symbol = EXCLUDED.symbol,
    decimal_places = EXCLUDED.decimal_places,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- Currency do tenant (BRL como base)
INSERT INTO core.currencies (id, tenant_id, code, name, symbol, decimal_places, is_active, is_base_currency)
VALUES 
    ('f0000000-0000-0000-0000-000000000010'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'BRL', 'Real Brasileiro', 'R$', 2, TRUE, TRUE)
ON CONFLICT (tenant_id, code) DO UPDATE SET
    name = EXCLUDED.name,
    symbol = EXCLUDED.symbol,
    is_base_currency = EXCLUDED.is_base_currency,
    updated_at = NOW();

-- ============================================================================
-- B) EXCHANGE RATES
-- ============================================================================

-- Exchange rates globais (tenant_id NULL)
INSERT INTO core.exchange_rates (tenant_id, from_currency_code, to_currency_code, rate, effective_from, source)
VALUES 
    (NULL, 'USD', 'BRL', 5.20, CURRENT_DATE, 'manual'),
    (NULL, 'EUR', 'BRL', 5.70, CURRENT_DATE, 'manual'),
    (NULL, 'BRL', 'USD', 0.1923, CURRENT_DATE, 'manual'),
    (NULL, 'BRL', 'EUR', 0.1754, CURRENT_DATE, 'manual')
ON CONFLICT (tenant_id, from_currency_code, to_currency_code, effective_from) DO UPDATE SET
    rate = EXCLUDED.rate,
    source = EXCLUDED.source,
    updated_at = NOW();

-- ============================================================================
-- C) SALARY STRUCTURES
-- ============================================================================

-- Salary structures para jobs/levels existentes
-- Assumindo que os jobs e levels do seed base existem

-- Software Engineer - Senior (SWE-SR)
INSERT INTO core.salary_structures (
    id,
    tenant_id,
    job_id,
    job_level_id,
    currency,
    effective_from,
    base_salary_min,
    base_salary_max,
    base_salary_mid,
    compensation_structure
)
SELECT 
    'a1000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    'c0000000-0000-0000-0000-000000000001'::uuid, -- SWE job
    jl.id, -- SWE-SR level
    'BRL',
    CURRENT_DATE,
    12000.00, -- min
    20000.00, -- max
    16000.00, -- mid
    '{"bonus": {"type": "performance", "range": "10-20%"}, "equity": {"type": "stock_options", "vesting": "4 years"}}'::jsonb
FROM core.job_levels jl
WHERE jl.tenant_id = '00000000-0000-0000-0000-000000000001'::uuid
    AND jl.job_id = 'c0000000-0000-0000-0000-000000000001'::uuid
    AND jl.level_code = 'SWE-SR'
LIMIT 1
ON CONFLICT DO NOTHING;

-- Software Engineer - Mid-level (SWE-MID)
INSERT INTO core.salary_structures (
    id,
    tenant_id,
    job_id,
    job_level_id,
    currency,
    effective_from,
    base_salary_min,
    base_salary_max,
    base_salary_mid,
    compensation_structure
)
SELECT 
    'a1000000-0000-0000-0000-000000000002'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    'c0000000-0000-0000-0000-000000000001'::uuid, -- SWE job
    jl.id, -- SWE-MID level
    'BRL',
    CURRENT_DATE,
    8000.00, -- min
    14000.00, -- max
    11000.00, -- mid
    '{"bonus": {"type": "performance", "range": "5-15%"}}'::jsonb
FROM core.job_levels jl
WHERE jl.tenant_id = '00000000-0000-0000-0000-000000000001'::uuid
    AND jl.job_id = 'c0000000-0000-0000-0000-000000000001'::uuid
    AND jl.level_code = 'SWE-MID'
LIMIT 1
ON CONFLICT DO NOTHING;

-- Product Manager - Mid-level (PM-MID)
INSERT INTO core.salary_structures (
    id,
    tenant_id,
    job_id,
    job_level_id,
    currency,
    effective_from,
    base_salary_min,
    base_salary_max,
    base_salary_mid,
    compensation_structure
)
SELECT 
    'a1000000-0000-0000-0000-000000000003'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    'c0000000-0000-0000-0000-000000000002'::uuid, -- PM job
    jl.id, -- PM-MID level
    'BRL',
    CURRENT_DATE,
    10000.00, -- min
    18000.00, -- max
    14000.00, -- mid
    '{"bonus": {"type": "performance", "range": "10-25%"}}'::jsonb
FROM core.job_levels jl
WHERE jl.tenant_id = '00000000-0000-0000-0000-000000000001'::uuid
    AND jl.job_id = 'c0000000-0000-0000-0000-000000000002'::uuid
    AND jl.level_code = 'PM-MID'
LIMIT 1
ON CONFLICT DO NOTHING;

-- Sales Representative - Senior (SALES-REP-SR)
INSERT INTO core.salary_structures (
    id,
    tenant_id,
    job_id,
    job_level_id,
    currency,
    effective_from,
    base_salary_min,
    base_salary_max,
    base_salary_mid,
    compensation_structure
)
SELECT 
    'a1000000-0000-0000-0000-000000000004'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    'c0000000-0000-0000-0000-000000000003'::uuid, -- SALES-REP job
    jl.id, -- SALES-REP-SR level
    'BRL',
    CURRENT_DATE,
    9000.00, -- min
    16000.00, -- max
    12500.00, -- mid
    '{"bonus": {"type": "commission", "range": "20-40%"}, "quota": {"type": "sales_target"}}'::jsonb
FROM core.job_levels jl
WHERE jl.tenant_id = '00000000-0000-0000-0000-000000000001'::uuid
    AND jl.job_id = 'c0000000-0000-0000-0000-000000000003'::uuid
    AND jl.level_code = 'SALES-REP-SR'
LIMIT 1
ON CONFLICT DO NOTHING;

-- Engineering Manager - Level 1 (ENG-MGR-L1)
INSERT INTO core.salary_structures (
    id,
    tenant_id,
    job_id,
    job_level_id,
    currency,
    effective_from,
    base_salary_min,
    base_salary_max,
    base_salary_mid,
    compensation_structure
)
SELECT 
    'a1000000-0000-0000-0000-000000000005'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    'c0000000-0000-0000-0000-000000000005'::uuid, -- ENG-MGR job
    jl.id, -- ENG-MGR-L1 level
    'BRL',
    CURRENT_DATE,
    15000.00, -- min
    25000.00, -- max
    20000.00, -- mid
    '{"bonus": {"type": "performance", "range": "15-30%"}, "equity": {"type": "stock_options", "vesting": "4 years"}}'::jsonb
FROM core.job_levels jl
WHERE jl.tenant_id = '00000000-0000-0000-0000-000000000001'::uuid
    AND jl.job_id = 'c0000000-0000-0000-0000-000000000005'::uuid
    AND jl.level_code = 'ENG-MGR-L1'
LIMIT 1
ON CONFLICT DO NOTHING;

-- ============================================================================
-- D) COST PARAMETERS
-- ============================================================================

-- Cost parameters para contextos existentes

-- Cost parameter para Software Engineer (job-level)
INSERT INTO core.cost_parameters (
    id,
    tenant_id,
    job_id,
    job_level_id,
    currency,
    effective_from,
    base_cost,
    overhead_rate,
    total_cost_factor,
    cost_breakdown
)
SELECT 
    'a2000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    'c0000000-0000-0000-0000-000000000001'::uuid, -- SWE job
    jl.id, -- SWE-SR level
    'BRL',
    CURRENT_DATE,
    16000.00, -- base_cost (salário mid)
    35.0, -- overhead_rate (35%)
    1.75, -- total_cost_factor (1.75x = salário + overhead + benefícios)
    '{"benefits": {"health_insurance": 2000, "meal_voucher": 800, "transport": 500}, "taxes": {"employer_contribution": 28.8}}'::jsonb
FROM core.job_levels jl
WHERE jl.tenant_id = '00000000-0000-0000-0000-000000000001'::uuid
    AND jl.job_id = 'c0000000-0000-0000-0000-000000000001'::uuid
    AND jl.level_code = 'SWE-SR'
LIMIT 1
ON CONFLICT DO NOTHING;

-- Cost parameter para Engineering org_unit
INSERT INTO core.cost_parameters (
    id,
    tenant_id,
    org_unit_id,
    currency,
    effective_from,
    base_cost,
    overhead_rate,
    total_cost_factor,
    cost_breakdown
)
SELECT 
    'a2000000-0000-0000-0000-000000000002'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    'a0000000-0000-0000-0000-000000000002'::uuid, -- ENG org_unit
    'BRL',
    CURRENT_DATE,
    50000.00, -- base_cost (custo médio do org_unit)
    40.0, -- overhead_rate (40%)
    1.80, -- total_cost_factor
    '{"infrastructure": {"servers": 5000, "tools": 3000}, "overhead": {"management": 10000}}'::jsonb
WHERE EXISTS (
    SELECT 1 FROM core.org_units 
    WHERE id = 'a0000000-0000-0000-0000-000000000002'::uuid 
    AND tenant_id = '00000000-0000-0000-0000-000000000001'::uuid
)
ON CONFLICT DO NOTHING;

-- Cost parameter para Cost Center Engineering
INSERT INTO core.cost_parameters (
    id,
    tenant_id,
    cost_center_id,
    currency,
    effective_from,
    base_cost,
    overhead_rate,
    total_cost_factor,
    cost_breakdown
)
SELECT 
    'a2000000-0000-0000-0000-000000000003'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    'b0000000-0000-0000-0000-000000000001'::uuid, -- CC-001 (Engineering)
    'BRL',
    CURRENT_DATE,
    60000.00, -- base_cost
    35.0, -- overhead_rate
    1.75, -- total_cost_factor
    '{"allocation": {"engineering": 100}}'::jsonb
WHERE EXISTS (
    SELECT 1 FROM core.cost_centers 
    WHERE id = 'b0000000-0000-0000-0000-000000000001'::uuid 
    AND tenant_id = '00000000-0000-0000-0000-000000000001'::uuid
)
ON CONFLICT DO NOTHING;

-- Cost parameter para Sales org_unit
INSERT INTO core.cost_parameters (
    id,
    tenant_id,
    org_unit_id,
    currency,
    effective_from,
    base_cost,
    overhead_rate,
    total_cost_factor,
    cost_breakdown
)
SELECT 
    'a2000000-0000-0000-0000-000000000004'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    'a0000000-0000-0000-0000-000000000003'::uuid, -- SALES org_unit
    'BRL',
    CURRENT_DATE,
    35000.00, -- base_cost
    30.0, -- overhead_rate
    1.65, -- total_cost_factor
    '{"commission": {"rate": "20-40%"}, "overhead": {"management": 5000}}'::jsonb
WHERE EXISTS (
    SELECT 1 FROM core.org_units 
    WHERE id = 'a0000000-0000-0000-0000-000000000003'::uuid 
    AND tenant_id = '00000000-0000-0000-0000-000000000001'::uuid
)
ON CONFLICT DO NOTHING;

-- Cost parameter para Product Manager (job-level)
INSERT INTO core.cost_parameters (
    id,
    tenant_id,
    job_id,
    job_level_id,
    currency,
    effective_from,
    base_cost,
    overhead_rate,
    total_cost_factor,
    cost_breakdown
)
SELECT 
    'a2000000-0000-0000-0000-000000000005'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    'c0000000-0000-0000-0000-000000000002'::uuid, -- PM job
    jl.id, -- PM-MID level
    'BRL',
    CURRENT_DATE,
    14000.00, -- base_cost
    32.0, -- overhead_rate
    1.70, -- total_cost_factor
    '{"benefits": {"health_insurance": 2000, "meal_voucher": 800}, "tools": {"product_tools": 500}}'::jsonb
FROM core.job_levels jl
WHERE jl.tenant_id = '00000000-0000-0000-0000-000000000001'::uuid
    AND jl.job_id = 'c0000000-0000-0000-0000-000000000002'::uuid
    AND jl.level_code = 'PM-MID'
LIMIT 1
ON CONFLICT DO NOTHING;

-- ============================================================================
-- E) ECONOMIC BENCHMARKS
-- ============================================================================

-- Economic benchmarks globais (tenant_id NULL)
INSERT INTO core.economic_benchmarks (
    id,
    tenant_id,
    benchmark_type,
    currency,
    benchmark_value,
    percentile,
    source,
    effective_from
)
VALUES 
    ('a3000000-0000-0000-0000-000000000001'::uuid,
    NULL, -- global
    'salary',
    'BRL',
    15000.00, -- benchmark_value
    50, -- percentile (mediana)
    'market_survey',
    CURRENT_DATE),
    ('a3000000-0000-0000-0000-000000000002'::uuid,
    NULL, -- global
    'salary',
    'BRL',
    20000.00, -- benchmark_value
    75, -- percentile (75º)
    'market_survey',
    CURRENT_DATE),
    ('a3000000-0000-0000-0000-000000000003'::uuid,
    NULL, -- global
    'cost',
    'BRL',
    25000.00, -- benchmark_value
    50, -- percentile
    'industry_report',
    CURRENT_DATE)
ON CONFLICT DO NOTHING;

-- Economic benchmarks do tenant
INSERT INTO core.economic_benchmarks (
    id,
    tenant_id,
    benchmark_type,
    job_id,
    job_level_id,
    currency,
    benchmark_value,
    percentile,
    source,
    effective_from
)
SELECT 
    'a3000000-0000-0000-0000-000000000010'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    'salary',
    'c0000000-0000-0000-0000-000000000001'::uuid, -- SWE job
    jl.id, -- SWE-SR level
    'BRL',
    18000.00, -- benchmark_value
    50, -- percentile
    'internal_survey',
    CURRENT_DATE
FROM core.job_levels jl
WHERE jl.tenant_id = '00000000-0000-0000-0000-000000000001'::uuid
    AND jl.job_id = 'c0000000-0000-0000-0000-000000000001'::uuid
    AND jl.level_code = 'SWE-SR'
LIMIT 1
ON CONFLICT DO NOTHING;

-- ============================================================================
-- VALIDAÇÃO
-- ============================================================================

DO $$
DECLARE
    v_currency_count INTEGER;
    v_exchange_rate_count INTEGER;
    v_salary_structure_count INTEGER;
    v_cost_parameter_count INTEGER;
    v_benchmark_count INTEGER;
BEGIN
    -- Valida currencies
    SELECT COUNT(*) INTO v_currency_count
    FROM core.currencies
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid OR tenant_id IS NULL;
    
    IF v_currency_count < 3 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado >= 3 currencies, encontrado %', v_currency_count;
    END IF;
    
    -- Valida exchange_rates
    SELECT COUNT(*) INTO v_exchange_rate_count
    FROM core.exchange_rates
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid OR tenant_id IS NULL;
    
    IF v_exchange_rate_count < 4 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado >= 4 exchange_rates, encontrado %', v_exchange_rate_count;
    END IF;
    
    -- Valida salary_structures
    SELECT COUNT(*) INTO v_salary_structure_count
    FROM core.salary_structures
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;
    
    IF v_salary_structure_count < 5 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado >= 5 salary_structures, encontrado %', v_salary_structure_count;
    END IF;
    
    -- Valida cost_parameters
    SELECT COUNT(*) INTO v_cost_parameter_count
    FROM core.cost_parameters
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;
    
    IF v_cost_parameter_count < 5 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado >= 5 cost_parameters, encontrado %', v_cost_parameter_count;
    END IF;
    
    -- Valida economic_benchmarks
    SELECT COUNT(*) INTO v_benchmark_count
    FROM core.economic_benchmarks
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid OR tenant_id IS NULL;
    
    IF v_benchmark_count < 4 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado >= 4 economic_benchmarks, encontrado %', v_benchmark_count;
    END IF;
    
    RAISE NOTICE 'Seed demo concluído: currencies=%, exchange_rates=%, salary_structures=%, cost_parameters=%, benchmarks=%', 
        v_currency_count, v_exchange_rate_count, v_salary_structure_count, v_cost_parameter_count, v_benchmark_count;
END;
$$;
