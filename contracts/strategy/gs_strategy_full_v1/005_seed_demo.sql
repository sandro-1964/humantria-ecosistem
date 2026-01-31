-- HUMANTRÍA — STRATEGY GS FULL V1 — Seed Demo
-- Idempotente: checa existencia por code antes de inserir

SET search_path TO strategy, foundation, core, public;

DO $$
DECLARE
    v_tenant_id UUID := '00000000-0000-0000-0000-000000000001'::uuid;
    v_person_id UUID := 'c3000000-0000-0000-0000-000000000001'::uuid;
    v_obj1_id UUID; v_obj2_id UUID;
BEGIN
    -- Objective 1 (draft)
    IF NOT EXISTS (SELECT 1 FROM strategy.objectives WHERE tenant_id = v_tenant_id AND code = 'STRAT-DEMO-001') THEN
        INSERT INTO strategy.objectives (tenant_id, code, title, description, methodology_type, cycle_type, cycle_start_date, cycle_end_date, status, owner_person_id)
        VALUES (v_tenant_id, 'STRAT-DEMO-001', 'Aumentar receita 20%', 'Objetivo demo: crescimento de receita', 'okr', 'annual', '2025-01-01'::date, '2025-12-31'::date, 'draft', v_person_id);
    END IF;
    SELECT id INTO v_obj1_id FROM strategy.objectives WHERE tenant_id = v_tenant_id AND code = 'STRAT-DEMO-001' LIMIT 1;

    -- Objective 2 (active)
    IF NOT EXISTS (SELECT 1 FROM strategy.objectives WHERE tenant_id = v_tenant_id AND code = 'STRAT-DEMO-002') THEN
        INSERT INTO strategy.objectives (tenant_id, code, title, description, methodology_type, cycle_type, cycle_start_date, cycle_end_date, status, owner_person_id)
        VALUES (v_tenant_id, 'STRAT-DEMO-002', 'Reduzir churn em 15%', 'Objetivo demo: retenção', 'okr', 'annual', '2025-01-01'::date, '2025-12-31'::date, 'active', v_person_id);
    END IF;
    SELECT id INTO v_obj2_id FROM strategy.objectives WHERE tenant_id = v_tenant_id AND code = 'STRAT-DEMO-002' LIMIT 1;

    -- Initiatives
    IF v_obj1_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM strategy.initiatives WHERE objective_id = v_obj1_id AND code = 'INIT-DEMO-001') THEN
        INSERT INTO strategy.initiatives (tenant_id, objective_id, code, title, description, status, owner_person_id)
        VALUES (v_tenant_id, v_obj1_id, 'INIT-DEMO-001', 'Lançar produto X', 'Iniciativa demo 1', 'draft', v_person_id);
        INSERT INTO strategy.initiatives (tenant_id, objective_id, code, title, description, status, owner_person_id)
        VALUES (v_tenant_id, v_obj1_id, 'INIT-DEMO-002', 'Expandir canais de venda', 'Iniciativa demo 2', 'active', v_person_id);
    END IF;
    IF v_obj2_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM strategy.initiatives WHERE objective_id = v_obj2_id AND code = 'INIT-DEMO-003') THEN
        INSERT INTO strategy.initiatives (tenant_id, objective_id, code, title, description, status, owner_person_id)
        VALUES (v_tenant_id, v_obj2_id, 'INIT-DEMO-003', 'Programa de fidelidade', 'Iniciativa demo 3', 'draft', v_person_id);
    END IF;
END;
$$;
