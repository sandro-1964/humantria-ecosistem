-- HUMANTRÍA — STRATEGY GS FULL V1 — Seed Realistic
-- Idempotente: cenários reais, volumes médios

SET search_path TO strategy, foundation, core, public;

DO $$
DECLARE
    v_tenant_id UUID := '00000000-0000-0000-0000-000000000001'::uuid;
    v_person_id UUID := 'c3000000-0000-0000-0000-000000000001'::uuid;
    v_obj UUID;
    v_codes TEXT[] := ARRAY['STRAT-R01','STRAT-R02','STRAT-R03','STRAT-R04','STRAT-R05','STRAT-R06'];
    v_titles TEXT[] := ARRAY['Crescimento receita Q1','Eficiência operacional','Satisfação do cliente','Inovação produto','Talentos e cultura','Sustentabilidade'];
    v_statuses TEXT[] := ARRAY['draft','active','active','completed','active','draft'];
    i INT;
BEGIN
    FOR i IN 1..6 LOOP
        IF NOT EXISTS (SELECT 1 FROM strategy.objectives WHERE tenant_id = v_tenant_id AND code = v_codes[i]) THEN
            INSERT INTO strategy.objectives (tenant_id, code, title, description, methodology_type, cycle_type, cycle_start_date, cycle_end_date, status, owner_person_id)
            VALUES (v_tenant_id, v_codes[i], v_titles[i], 'Objetivo realista ' || i, 'okr', 'quarterly', ('2025-01-01'::date + (i-1)*30), ('2025-03-31'::date + (i-1)*30), v_statuses[i], v_person_id);
        END IF;
    END LOOP;

    FOR v_obj IN SELECT id FROM strategy.objectives WHERE tenant_id = v_tenant_id AND code LIKE 'STRAT-R%' LOOP
        IF NOT EXISTS (SELECT 1 FROM strategy.initiatives i WHERE i.objective_id = v_obj AND i.code = 'INIT-R-1') THEN
            INSERT INTO strategy.initiatives (tenant_id, objective_id, code, title, description, status, owner_person_id)
            VALUES (v_tenant_id, v_obj, 'INIT-R-1', 'Iniciativa realista A', 'Descrição', 'active', v_person_id);
        END IF;
        IF NOT EXISTS (SELECT 1 FROM strategy.initiatives i WHERE i.objective_id = v_obj AND i.code = 'INIT-R-2') THEN
            INSERT INTO strategy.initiatives (tenant_id, objective_id, code, title, description, status, owner_person_id)
            VALUES (v_tenant_id, v_obj, 'INIT-R-2', 'Iniciativa realista B', 'Descrição', 'draft', v_person_id);
        END IF;
    END LOOP;
END;
$$;
