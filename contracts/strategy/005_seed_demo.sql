-- HUMANTRÍA — STRATEGY SEED DEMO V1
-- Status: OBRIGATÓRIO
-- Escopo: Seed idempotente para ambiente DEMO
-- Requisitos: 3 objectives + KRs, 1 budget_version baseline + ~10 items, 1 staffing_plan base + ~10 demands, 2 ai_suggestions, 1 risk_alert, 1 workflow + 2 approval_requests

SET search_path TO strategy, core, foundation, public;

-- ============================================================================
-- SEED: IDEMPOTENTE (usa ON CONFLICT ou DELETE + INSERT)
-- ============================================================================

-- Assumindo que o tenant demo já existe (criado em foundation/005_seed_demo.sql)
-- Tenant ID: 00000000-0000-0000-0000-000000000001 (acme-corp)
-- Assumindo que Core seed já foi executado (org_units, people, jobs, cost_centers)

-- ============================================================================
-- A) OBJETIVOS & METAS
-- ============================================================================

-- Objective Templates (global e tenant-specific)
INSERT INTO strategy.objective_templates (id, tenant_id, code, name, description, methodology_type, structure, is_active, is_global)
VALUES 
    -- Template global OKR
    ('e0000000-0000-0000-0000-000000000001'::uuid, NULL, 'OKR-Q1', 'OKR Template Q1', 'Template padrão de OKR para Q1', 'okr', '{"objectives": 3, "key_results_per_objective": 3}'::jsonb, TRUE, TRUE),
    -- Template tenant-specific BSC
    ('e0000000-0000-0000-0000-000000000002'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'BSC-2026', 'BSC Template 2026', 'Template BSC para 2026', 'bsc', '{"perspectives": 4}'::jsonb, TRUE, FALSE)
ON CONFLICT (tenant_id, code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    structure = EXCLUDED.structure,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- Objectives (3 exemplos: 2 OKR + 1 BSC)
INSERT INTO strategy.objectives (id, tenant_id, template_id, code, title, description, methodology_type, cycle_type, cycle_start_date, cycle_end_date, owner_person_id, status)
VALUES 
    -- OKR Q1 2026
    ('f0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'e0000000-0000-0000-0000-000000000001'::uuid, 'OKR-Q1-2026', 'Crescer receita em 30% no Q1', 'Objetivo de crescimento de receita para Q1 2026', 'okr', 'quarterly', '2026-01-01', '2026-03-31', 'd0000000-0000-0000-0000-000000000001'::uuid, 'active'),
    -- OKR Q1 2026 - Engenharia
    ('f0000000-0000-0000-0000-000000000002'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'e0000000-0000-0000-0000-000000000001'::uuid, 'OKR-ENG-Q1-2026', 'Melhorar qualidade do produto', 'Objetivo de qualidade para time de Engenharia', 'okr', 'quarterly', '2026-01-01', '2026-03-31', 'd0000000-0000-0000-0000-000000000002'::uuid, 'active'),
    -- BSC 2026
    ('f0000000-0000-0000-0000-000000000003'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'e0000000-0000-0000-0000-000000000002'::uuid, 'BSC-2026', 'BSC Corporativo 2026', 'Balanced Scorecard corporativo para 2026', 'bsc', 'annual', '2026-01-01', '2026-12-31', 'd0000000-0000-0000-0000-000000000001'::uuid, 'active')
ON CONFLICT (tenant_id, code) DO UPDATE SET
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    status = EXCLUDED.status,
    updated_at = NOW();

-- Key Results (3 KRs para cada objective)
INSERT INTO strategy.key_results (id, tenant_id, objective_id, code, title, description, metric_type, current_value, target_value, unit, owner_person_id, status)
VALUES 
    -- KRs para OKR-Q1-2026 (receita)
    ('g0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000001'::uuid, 'KR-001', 'Aumentar MRR para R$ 500k', 'MRR mensal recorrente', 'currency', 350000, 500000, 'BRL', 'd0000000-0000-0000-0000-000000000001'::uuid, 'active'),
    ('g0000000-0000-0000-0000-000000000002'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000001'::uuid, 'KR-002', 'Fechar 20 novos clientes', 'Número de novos clientes', 'count', 8, 20, 'unidades', 'd0000000-0000-0000-0000-000000000003'::uuid, 'active'),
    ('g0000000-0000-0000-0000-000000000003'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000001'::uuid, 'KR-003', 'Reduzir churn para 2%', 'Taxa de churn mensal', 'percentage', 5.5, 2.0, '%', 'd0000000-0000-0000-0000-000000000004'::uuid, 'active'),
    -- KRs para OKR-ENG-Q1-2026 (qualidade)
    ('g0000000-0000-0000-0000-000000000004'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000002'::uuid, 'KR-004', 'Reduzir bugs críticos para 0', 'Bugs críticos em produção', 'count', 3, 0, 'unidades', 'd0000000-0000-0000-0000-000000000002'::uuid, 'active'),
    ('g0000000-0000-0000-0000-000000000005'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000002'::uuid, 'KR-005', 'Aumentar cobertura de testes para 80%', 'Cobertura de testes automatizados', 'percentage', 65, 80, '%', 'd0000000-0000-0000-0000-000000000005'::uuid, 'active'),
    ('g0000000-0000-0000-0000-000000000006'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000002'::uuid, 'KR-006', 'Reduzir tempo de deploy para 10min', 'Tempo médio de deploy', 'duration', 25, 10, 'minutos', 'd0000000-0000-0000-0000-000000000006'::uuid, 'active'),
    -- Indicadores para BSC-2026
    ('g0000000-0000-0000-0000-000000000007'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000003'::uuid, 'IND-001', 'Satisfação do cliente (NPS)', 'Net Promoter Score', 'score', 45, 60, 'pontos', 'd0000000-0000-0000-0000-000000000007'::uuid, 'active'),
    ('g0000000-0000-0000-0000-000000000008'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000003'::uuid, 'IND-002', 'Receita anual recorrente (ARR)', 'Annual Recurring Revenue', 'currency', 4200000, 6000000, 'BRL', 'd0000000-0000-0000-0000-000000000008'::uuid, 'active'),
    ('g0000000-0000-0000-0000-000000000009'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000003'::uuid, 'IND-003', 'Engajamento de colaboradores', 'Taxa de engajamento', 'percentage', 72, 85, '%', 'd0000000-0000-0000-0000-000000000009'::uuid, 'active')
ON CONFLICT (tenant_id, objective_id, code) DO UPDATE SET
    title = EXCLUDED.title,
    current_value = EXCLUDED.current_value,
    target_value = EXCLUDED.target_value,
    status = EXCLUDED.status,
    updated_at = NOW();

-- Objective History (histórico de alterações)
INSERT INTO strategy.objective_history (id, tenant_id, objective_id, version, changed_at, changes, justification)
VALUES 
    ('h0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000001'::uuid, 1, NOW() - INTERVAL '5 days', '{"action": "created"}'::jsonb, 'Objective criado'),
    ('h0000000-0000-0000-0000-000000000002'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000001'::uuid, 2, NOW() - INTERVAL '2 days', '{"status": {"old": "draft", "new": "active"}}'::jsonb, 'Objective ativado após aprovação')
ON CONFLICT DO NOTHING;

-- Objective Evidence (evidências)
INSERT INTO strategy.objective_evidence (id, tenant_id, objective_id, evidence_type, title, description, attachment_url, attachment_type)
VALUES 
    ('i0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000001'::uuid, 'document', 'Plano de ação Q1', 'Documento com plano de ação detalhado', 'https://example.com/docs/plano-q1.pdf', 'pdf'),
    ('i0000000-0000-0000-0000-000000000002'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000001'::uuid, 'link', 'Dashboard de métricas', 'Link para dashboard de acompanhamento', 'https://analytics.example.com/dashboard/q1', 'url')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- B) ORÇAMENTO
-- ============================================================================

-- Budget Currencies (moedas)
INSERT INTO strategy.budget_currencies (id, tenant_id, code, name, symbol, exchange_rate_to_base, is_active, is_global)
VALUES 
    -- Moedas globais
    ('j0000000-0000-0000-0000-000000000001'::uuid, NULL, 'BRL', 'Real Brasileiro', 'R$', 1.0, TRUE, TRUE),
    ('j0000000-0000-0000-0000-000000000002'::uuid, NULL, 'USD', 'Dólar Americano', '$', 5.2, TRUE, TRUE),
    ('j0000000-0000-0000-0000-000000000003'::uuid, NULL, 'EUR', 'Euro', '€', 5.8, TRUE, TRUE)
ON CONFLICT (tenant_id, code) DO UPDATE SET
    exchange_rate_to_base = EXCLUDED.exchange_rate_to_base,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- Budget Versions (baseline)
INSERT INTO strategy.budget_versions (id, tenant_id, code, name, description, version_number, status, approved_at, approved_by)
VALUES 
    ('k0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'BUDGET-2026-BASE', 'Orçamento 2026 Baseline', 'Orçamento base para 2026', 1, 'approved', NOW() - INTERVAL '30 days', 'd0000000-0000-0000-0000-000000000001'::uuid)
ON CONFLICT (tenant_id, code) DO UPDATE SET
    status = EXCLUDED.status,
    approved_at = EXCLUDED.approved_at,
    updated_at = NOW();

-- Budget Items (~10 itens)
INSERT INTO strategy.budget_items (id, tenant_id, budget_version_id, item_type, org_unit_id, cost_center_id, category, amount_base_currency, currency_code, amount_original_currency, period_start, period_end)
VALUES 
    -- Orçamento por org_unit (Engineering)
    ('l0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'k0000000-0000-0000-0000-000000000001'::uuid, 'org_unit', 'a0000000-0000-0000-0000-000000000002'::uuid, 'b0000000-0000-0000-0000-000000000001'::uuid, 'salaries', 1200000, 'BRL', 1200000, '2026-01-01', '2026-12-31'),
    ('l0000000-0000-0000-0000-000000000002'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'k0000000-0000-0000-0000-000000000001'::uuid, 'org_unit', 'a0000000-0000-0000-0000-000000000002'::uuid, 'b0000000-0000-0000-0000-000000000001'::uuid, 'infrastructure', 300000, 'BRL', 300000, '2026-01-01', '2026-12-31'),
    -- Orçamento por org_unit (Sales)
    ('l0000000-0000-0000-0000-000000000003'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'k0000000-0000-0000-0000-000000000001'::uuid, 'org_unit', 'a0000000-0000-0000-0000-000000000003'::uuid, 'b0000000-0000-0000-0000-000000000002'::uuid, 'salaries', 800000, 'BRL', 800000, '2026-01-01', '2026-12-31'),
    ('l0000000-0000-0000-0000-000000000004'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'k0000000-0000-0000-0000-000000000001'::uuid, 'org_unit', 'a0000000-0000-0000-0000-000000000003'::uuid, 'b0000000-0000-0000-0000-000000000002'::uuid, 'marketing', 200000, 'BRL', 200000, '2026-01-01', '2026-12-31'),
    -- Orçamento por cost_center
    ('l0000000-0000-0000-0000-000000000005'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'k0000000-0000-0000-0000-000000000001'::uuid, 'cost_center', NULL, 'b0000000-0000-0000-0000-000000000001'::uuid, 'training', 50000, 'BRL', 50000, '2026-01-01', '2026-12-31'),
    ('l0000000-0000-0000-0000-000000000006'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'k0000000-0000-0000-0000-000000000001'::uuid, 'cost_center', NULL, 'b0000000-0000-0000-0000-000000000002'::uuid, 'commissions', 150000, 'BRL', 150000, '2026-01-01', '2026-12-31'),
    -- Orçamento multi-moeda (USD)
    ('l0000000-0000-0000-0000-000000000007'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'k0000000-0000-0000-0000-000000000001'::uuid, 'org_unit', 'a0000000-0000-0000-0000-000000000002'::uuid, 'b0000000-0000-0000-0000-000000000001'::uuid, 'software_licenses', 520000, 'BRL', 100000, '2026-01-01', '2026-12-31'),
    -- Orçamento por período (Q1)
    ('l0000000-0000-0000-0000-000000000008'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'k0000000-0000-0000-0000-000000000001'::uuid, 'org_unit', 'a0000000-0000-0000-0000-000000000004'::uuid, NULL, 'recruitment', 100000, 'BRL', 100000, '2026-01-01', '2026-03-31'),
    -- Orçamento por período (Q2)
    ('l0000000-0000-0000-0000-000000000009'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'k0000000-0000-0000-0000-000000000001'::uuid, 'org_unit', 'a0000000-0000-0000-0000-000000000004'::uuid, NULL, 'recruitment', 100000, 'BRL', 100000, '2026-04-01', '2026-06-30'),
    -- Orçamento geral
    ('l0000000-0000-0000-0000-000000000010'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'k0000000-0000-0000-0000-000000000001'::uuid, 'org_unit', 'a0000000-0000-0000-0000-000000000001'::uuid, NULL, 'general', 500000, 'BRL', 500000, '2026-01-01', '2026-12-31')
ON CONFLICT DO NOTHING;

-- Budget Approvals (aprovações)
INSERT INTO strategy.budget_approvals (id, tenant_id, budget_version_id, approver_person_id, approval_level, status, approved_at, comments)
VALUES 
    ('m0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'k0000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000001'::uuid, 1, 'approved', NOW() - INTERVAL '30 days', 'Aprovado pelo CFO')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- C) STAFFING PLAN
-- ============================================================================

-- Staffing Plans (base case)
INSERT INTO strategy.staffing_plans (id, tenant_id, code, name, description, scenario_type, period_start, period_end, status, approved_at, approved_by)
VALUES 
    ('n0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'STAFF-2026-BASE', 'Staffing Plan 2026 Base Case', 'Plano de staffing base para 2026', 'base', '2026-01-01', '2026-12-31', 'approved', NOW() - INTERVAL '25 days', 'd0000000-0000-0000-0000-000000000001'::uuid)
ON CONFLICT (tenant_id, code) DO UPDATE SET
    status = EXCLUDED.status,
    approved_at = EXCLUDED.approved_at,
    updated_at = NOW();

-- Staffing Demands (~10 demands)
INSERT INTO strategy.staffing_demands (id, tenant_id, staffing_plan_id, org_unit_id, job_id, job_level_id, period_start, period_end, headcount, cost_center_id)
VALUES 
    -- Engineering - Software Engineers
    ('o0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'n0000000-0000-0000-0000-000000000001'::uuid, 'a0000000-0000-0000-0000-000000000002'::uuid, 'c0000000-0000-0000-0000-000000000001'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000001'::uuid AND level_code = 'SWE-SR' LIMIT 1), '2026-01-01', '2026-12-31', 5, 'b0000000-0000-0000-0000-000000000001'::uuid),
    ('o0000000-0000-0000-0000-000000000002'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'n0000000-0000-0000-0000-000000000001'::uuid, 'a0000000-0000-0000-0000-000000000002'::uuid, 'c0000000-0000-0000-0000-000000000001'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000001'::uuid AND level_code = 'SWE-MID' LIMIT 1), '2026-01-01', '2026-12-31', 8, 'b0000000-0000-0000-0000-000000000001'::uuid),
    ('o0000000-0000-0000-0000-000000000003'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'n0000000-0000-0000-0000-000000000001'::uuid, 'a0000000-0000-0000-0000-000000000002'::uuid, 'c0000000-0000-0000-0000-000000000001'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000001'::uuid AND level_code = 'SWE-JR' LIMIT 1), '2026-01-01', '2026-12-31', 3, 'b0000000-0000-0000-0000-000000000001'::uuid),
    -- Engineering - Managers
    ('o0000000-0000-0000-0000-000000000004'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'n0000000-0000-0000-0000-000000000001'::uuid, 'a0000000-0000-0000-0000-000000000002'::uuid, 'c0000000-0000-0000-0000-000000000005'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000005'::uuid AND level_code = 'ENG-MGR-L1' LIMIT 1), '2026-01-01', '2026-12-31', 2, 'b0000000-0000-0000-0000-000000000001'::uuid),
    -- Sales
    ('o0000000-0000-0000-0000-000000000005'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'n0000000-0000-0000-0000-000000000001'::uuid, 'a0000000-0000-0000-0000-000000000003'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000003'::uuid AND level_code = 'SALES-REP-SR' LIMIT 1), '2026-01-01', '2026-12-31', 4, 'b0000000-0000-0000-0000-000000000002'::uuid),
    ('o0000000-0000-0000-0000-000000000006'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'n0000000-0000-0000-0000-000000000001'::uuid, 'a0000000-0000-0000-0000-000000000003'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000003'::uuid AND level_code = 'SALES-REP-MID' LIMIT 1), '2026-01-01', '2026-12-31', 6, 'b0000000-0000-0000-0000-000000000002'::uuid),
    -- Product Managers
    ('o0000000-0000-0000-0000-000000000007'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'n0000000-0000-0000-0000-000000000001'::uuid, 'a0000000-0000-0000-0000-000000000002'::uuid, 'c0000000-0000-0000-0000-000000000002'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000002'::uuid AND level_code = 'PM-SR' LIMIT 1), '2026-01-01', '2026-12-31', 2, 'b0000000-0000-0000-0000-000000000001'::uuid),
    -- HR
    ('o0000000-0000-0000-0000-000000000008'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'n0000000-0000-0000-0000-000000000001'::uuid, 'a0000000-0000-0000-0000-000000000004'::uuid, 'c0000000-0000-0000-0000-000000000004'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000004'::uuid AND level_code = 'HR-BP-MID' LIMIT 1), '2026-01-01', '2026-12-31', 2, NULL),
    -- Demanda por período (Q1)
    ('o0000000-0000-0000-0000-000000000009'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'n0000000-0000-0000-0000-000000000001'::uuid, 'a0000000-0000-0000-0000-000000000005'::uuid, 'c0000000-0000-0000-0000-000000000001'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000001'::uuid AND level_code = 'SWE-MID' LIMIT 1), '2026-01-01', '2026-03-31', 2, 'b0000000-0000-0000-0000-000000000001'::uuid),
    -- Demanda por período (Q2)
    ('o0000000-0000-0000-0000-000000000010'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'n0000000-0000-0000-0000-000000000001'::uuid, 'a0000000-0000-0000-0000-000000000006'::uuid, 'c0000000-0000-0000-0000-000000000001'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000001'::uuid AND level_code = 'SWE-JR' LIMIT 1), '2026-04-01', '2026-06-30', 1, 'b0000000-0000-0000-0000-000000000001'::uuid)
ON CONFLICT DO NOTHING;

-- Staffing Calculated Costs (custos calculados - placeholder, pois calculate_staffing_costs está bloqueado)
-- NOTA: Estes valores são placeholders. Quando economics existir, serão calculados automaticamente
INSERT INTO strategy.staffing_calculated_costs (id, tenant_id, staffing_demand_id, calculated_cost_base_currency, calculated_cost_original_currency, currency_code, calculation_date)
VALUES 
    ('p0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'o0000000-0000-0000-0000-000000000001'::uuid, 600000, 600000, 'BRL', NOW() - INTERVAL '20 days'),
    ('p0000000-0000-0000-0000-000000000002'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'o0000000-0000-0000-0000-000000000002'::uuid, 480000, 480000, 'BRL', NOW() - INTERVAL '20 days'),
    ('p0000000-0000-0000-0000-000000000003'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'o0000000-0000-0000-0000-000000000003'::uuid, 120000, 120000, 'BRL', NOW() - INTERVAL '20 days')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- D) SIMULAÇÕES & IA
-- ============================================================================

-- AI Suggestions (2 exemplos: aprovada + rejeitada)
INSERT INTO strategy.ai_suggestions (id, tenant_id, suggestion_type, entity_type, entity_id, suggestion_data, explanation, confidence_score, model_provider, model_name, status, approved_by, approved_at)
VALUES 
    -- Sugestão aprovada
    ('q0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'goal', 'objective', 'f0000000-0000-0000-0000-000000000001'::uuid, '{"suggested_target": 550000}'::jsonb, 'Baseado no histórico de crescimento de 15% ao trimestre, sugerimos aumentar o target de MRR para R$ 550k para manter crescimento sustentável', 0.85, 'openai', 'gpt-4', 'approved', 'd0000000-0000-0000-0000-000000000001'::uuid, NOW() - INTERVAL '10 days'),
    -- Sugestão rejeitada
    ('q0000000-0000-0000-0000-000000000002'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'budget', 'budget_version', 'k0000000-0000-0000-0000-000000000001'::uuid, '{"suggested_reduction": 200000}'::jsonb, 'Análise de custos sugere redução de R$ 200k no orçamento de infraestrutura baseado em otimizações identificadas', 0.65, 'openai', 'gpt-4', 'rejected', NULL, NULL)
ON CONFLICT DO NOTHING;

-- Risk Alerts (1 exemplo)
INSERT INTO strategy.risk_alerts (id, tenant_id, alert_type, severity, title, description, entity_type, entity_id, detected_at)
VALUES 
    ('r0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'budget_variance', 'high', 'Desvio de orçamento detectado', 'Orçamento de Engineering está 15% acima do previsto no primeiro trimestre', 'budget_version', 'k0000000-0000-0000-0000-000000000001'::uuid, NOW() - INTERVAL '5 days')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- E) WORKFLOWS DE APROVAÇÃO
-- ============================================================================

-- Approval Workflows (1 exemplo)
INSERT INTO strategy.approval_workflows (id, tenant_id, code, name, description, entity_type, approval_levels, is_active)
VALUES 
    ('s0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'BUDGET-APPROVAL', 'Aprovação de Orçamento', 'Workflow de aprovação para orçamentos', 'budget_version', '[{"level": 1, "role": "gestor"}, {"level": 2, "role": "tenant_admin"}]'::jsonb, TRUE)
ON CONFLICT (tenant_id, code) DO UPDATE SET
    approval_levels = EXCLUDED.approval_levels,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- Approval Requests (2 exemplos: aprovada + pendente)
INSERT INTO strategy.approval_requests (id, tenant_id, workflow_id, entity_type, entity_id, requested_by, requested_at, current_level, status, approved_at)
VALUES 
    -- Request aprovada
    ('t0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 's0000000-0000-0000-0000-000000000001'::uuid, 'budget_version', 'k0000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000001'::uuid, NOW() - INTERVAL '30 days', 2, 'approved', NOW() - INTERVAL '28 days'),
    -- Request pendente
    ('t0000000-0000-0000-0000-000000000002'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 's0000000-0000-0000-0000-000000000001'::uuid, 'budget_version', 'k0000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000002'::uuid, NOW() - INTERVAL '2 days', 1, 'pending', NULL)
ON CONFLICT DO NOTHING;

-- Approval History (histórico de aprovações)
INSERT INTO strategy.approval_history (id, tenant_id, approval_request_id, approver_person_id, approval_level, action, comments, approved_at)
VALUES 
    ('u0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 't0000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000001'::uuid, 1, 'approved', 'Aprovado pelo gestor', NOW() - INTERVAL '29 days'),
    ('u0000000-0000-0000-0000-000000000002'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 't0000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000001'::uuid, 2, 'approved', 'Aprovado pelo tenant admin', NOW() - INTERVAL '28 days')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- VALIDAÇÃO DO SEED
-- ============================================================================

DO $$
DECLARE
    v_objective_count INTEGER;
    v_key_result_count INTEGER;
    v_budget_item_count INTEGER;
    v_staffing_demand_count INTEGER;
    v_ai_suggestion_count INTEGER;
    v_risk_alert_count INTEGER;
    v_approval_request_count INTEGER;
BEGIN
    -- Valida objectives
    SELECT COUNT(*) INTO v_objective_count
    FROM strategy.objectives
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;
    
    IF v_objective_count < 3 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado 3 objectives, encontrado %', v_objective_count;
    END IF;
    
    -- Valida key_results
    SELECT COUNT(*) INTO v_key_result_count
    FROM strategy.key_results
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;
    
    IF v_key_result_count < 9 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado 9 key_results, encontrado %', v_key_result_count;
    END IF;
    
    -- Valida budget_items
    SELECT COUNT(*) INTO v_budget_item_count
    FROM strategy.budget_items
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;
    
    IF v_budget_item_count < 10 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado 10 budget_items, encontrado %', v_budget_item_count;
    END IF;
    
    -- Valida staffing_demands
    SELECT COUNT(*) INTO v_staffing_demand_count
    FROM strategy.staffing_demands
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;
    
    IF v_staffing_demand_count < 10 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado 10 staffing_demands, encontrado %', v_staffing_demand_count;
    END IF;
    
    -- Valida ai_suggestions
    SELECT COUNT(*) INTO v_ai_suggestion_count
    FROM strategy.ai_suggestions
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;
    
    IF v_ai_suggestion_count < 2 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado 2 ai_suggestions, encontrado %', v_ai_suggestion_count;
    END IF;
    
    -- Valida risk_alerts
    SELECT COUNT(*) INTO v_risk_alert_count
    FROM strategy.risk_alerts
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;
    
    IF v_risk_alert_count < 1 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado 1 risk_alert, encontrado %', v_risk_alert_count;
    END IF;
    
    -- Valida approval_requests
    SELECT COUNT(*) INTO v_approval_request_count
    FROM strategy.approval_requests
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;
    
    IF v_approval_request_count < 2 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado 2 approval_requests, encontrado %', v_approval_request_count;
    END IF;
    
    RAISE NOTICE 'Seed demo Strategy concluído: objectives=%, key_results=%, budget_items=%, staffing_demands=%, ai_suggestions=%, risk_alerts=%, approval_requests=%', 
        v_objective_count, v_key_result_count, v_budget_item_count, v_staffing_demand_count, v_ai_suggestion_count, v_risk_alert_count, v_approval_request_count;
END;
$$;
