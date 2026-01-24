-- HUMANTRÍA — CORE SEED DEMO V1
-- Status: OBRIGATÓRIO
-- Escopo: Seed idempotente para ambiente DEMO
-- Requisitos: 1 tenant demo, org_units exemplo, 10 people exemplo, 5 jobs + levels exemplo, 2 cost_centers exemplo, 1 import_job exemplo

SET search_path TO core, foundation, public;

-- ============================================================================
-- SEED: IDEMPOTENTE (usa ON CONFLICT)
-- ============================================================================

-- Assumindo que o tenant demo já existe (criado em foundation/005_seed_demo.sql)
-- Tenant ID: 00000000-0000-0000-0000-000000000001 (acme-corp)

-- ============================================================================
-- A) ORGANIZAÇÃO: Org Units Exemplo
-- ============================================================================

-- Org Units (hierarquia exemplo)
INSERT INTO core.org_units (id, tenant_id, code, name, description, org_unit_type, is_active)
VALUES 
    -- Raiz
    ('a0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'ACME', 'Acme Corporation', 'Organização raiz', 'company', TRUE),
    -- Filhos nível 1
    ('a0000000-0000-0000-0000-000000000002'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'ENG', 'Engineering', 'Departamento de Engenharia', 'department', TRUE),
    ('a0000000-0000-0000-0000-000000000003'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'SALES', 'Sales', 'Departamento de Vendas', 'department', TRUE),
    ('a0000000-0000-0000-0000-000000000004'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'HR', 'Human Resources', 'Recursos Humanos', 'department', TRUE),
    -- Filhos nível 2 (sub-departamentos)
    ('a0000000-0000-0000-0000-000000000005'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'ENG-BE', 'Backend Engineering', 'Time de Backend', 'team', TRUE),
    ('a0000000-0000-0000-0000-000000000006'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'ENG-FE', 'Frontend Engineering', 'Time de Frontend', 'team', TRUE)
ON CONFLICT (tenant_id, code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    org_unit_type = EXCLUDED.org_unit_type,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- Atualizar parent_id após inserção
UPDATE core.org_units SET parent_id = 'a0000000-0000-0000-0000-000000000001'::uuid WHERE code IN ('ENG', 'SALES', 'HR') AND tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;
UPDATE core.org_units SET parent_id = 'a0000000-0000-0000-0000-000000000002'::uuid WHERE code IN ('ENG-BE', 'ENG-FE') AND tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;

-- Cost Centers (2 exemplos)
INSERT INTO core.cost_centers (id, tenant_id, code, name, description, is_active)
VALUES 
    ('b0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'CC-001', 'Cost Center Engineering', 'Centro de custo para Engenharia', TRUE),
    ('b0000000-0000-0000-0000-000000000002'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'CC-002', 'Cost Center Sales', 'Centro de custo para Vendas', TRUE)
ON CONFLICT (tenant_id, code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- Links Org Unit ↔ Cost Center
INSERT INTO core.org_unit_cost_center_links (tenant_id, org_unit_id, cost_center_id, effective_from, allocation_percentage)
VALUES 
    ('00000000-0000-0000-0000-000000000001'::uuid, 'a0000000-0000-0000-0000-000000000002'::uuid, 'b0000000-0000-0000-0000-000000000001'::uuid, CURRENT_DATE, 100),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'a0000000-0000-0000-0000-000000000003'::uuid, 'b0000000-0000-0000-0000-000000000002'::uuid, CURRENT_DATE, 100)
ON CONFLICT (tenant_id, org_unit_id, cost_center_id, effective_from) DO UPDATE SET
    allocation_percentage = EXCLUDED.allocation_percentage,
    updated_at = NOW();

-- ============================================================================
-- B) JOBS/LEVELS: 5 Jobs + Levels Exemplo
-- ============================================================================

-- Jobs (5 exemplos)
INSERT INTO core.jobs (id, tenant_id, code, name, description, is_active)
VALUES 
    ('c0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'SWE', 'Software Engineer', 'Engenheiro de Software', TRUE),
    ('c0000000-0000-0000-0000-000000000002'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'PM', 'Product Manager', 'Gerente de Produto', TRUE),
    ('c0000000-0000-0000-0000-000000000003'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'SALES-REP', 'Sales Representative', 'Representante de Vendas', TRUE),
    ('c0000000-0000-0000-0000-000000000004'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'HR-BP', 'HR Business Partner', 'Parceiro de Negócios RH', TRUE),
    ('c0000000-0000-0000-0000-000000000005'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'ENG-MGR', 'Engineering Manager', 'Gerente de Engenharia', TRUE)
ON CONFLICT (tenant_id, code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- Job Levels (3 níveis por job exemplo)
INSERT INTO core.job_levels (tenant_id, job_id, level_code, level_name, level_number, description, is_active)
VALUES 
    -- Software Engineer levels
    ('00000000-0000-0000-0000-000000000001'::uuid, 'c0000000-0000-0000-0000-000000000001'::uuid, 'SWE-JR', 'Junior', 1, 'Software Engineer Junior', TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'c0000000-0000-0000-0000-000000000001'::uuid, 'SWE-MID', 'Mid-level', 2, 'Software Engineer Mid-level', TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'c0000000-0000-0000-0000-000000000001'::uuid, 'SWE-SR', 'Senior', 3, 'Software Engineer Senior', TRUE),
    -- Product Manager levels
    ('00000000-0000-0000-0000-000000000001'::uuid, 'c0000000-0000-0000-0000-000000000002'::uuid, 'PM-JR', 'Junior', 1, 'Product Manager Junior', TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'c0000000-0000-0000-0000-000000000002'::uuid, 'PM-MID', 'Mid-level', 2, 'Product Manager Mid-level', TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'c0000000-0000-0000-0000-000000000002'::uuid, 'PM-SR', 'Senior', 3, 'Product Manager Senior', TRUE),
    -- Sales Representative levels
    ('00000000-0000-0000-0000-000000000001'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, 'SALES-REP-JR', 'Junior', 1, 'Sales Representative Junior', TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, 'SALES-REP-MID', 'Mid-level', 2, 'Sales Representative Mid-level', TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, 'SALES-REP-SR', 'Senior', 3, 'Sales Representative Senior', TRUE),
    -- HR Business Partner levels
    ('00000000-0000-0000-0000-000000000001'::uuid, 'c0000000-0000-0000-0000-000000000004'::uuid, 'HR-BP-JR', 'Junior', 1, 'HR Business Partner Junior', TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'c0000000-0000-0000-0000-000000000004'::uuid, 'HR-BP-MID', 'Mid-level', 2, 'HR Business Partner Mid-level', TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'c0000000-0000-0000-0000-000000000004'::uuid, 'HR-BP-SR', 'Senior', 3, 'HR Business Partner Senior', TRUE),
    -- Engineering Manager levels
    ('00000000-0000-0000-0000-000000000001'::uuid, 'c0000000-0000-0000-0000-000000000005'::uuid, 'ENG-MGR-L1', 'Level 1', 1, 'Engineering Manager Level 1', TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'c0000000-0000-0000-0000-000000000005'::uuid, 'ENG-MGR-L2', 'Level 2', 2, 'Engineering Manager Level 2', TRUE)
ON CONFLICT (tenant_id, job_id, level_code) DO UPDATE SET
    level_name = EXCLUDED.level_name,
    level_number = EXCLUDED.level_number,
    description = EXCLUDED.description,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- ============================================================================
-- C) PEOPLE: 10 People Exemplo
-- ============================================================================

-- People (10 exemplos)
INSERT INTO core.people (id, tenant_id, person_id, first_name, last_name, display_name, date_of_birth, gender, is_active)
VALUES 
    ('d0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'P001', 'John', 'Doe', 'John Doe', '1990-01-15', 'male', TRUE),
    ('d0000000-0000-0000-0000-000000000002'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'P002', 'Jane', 'Smith', 'Jane Smith', '1992-03-20', 'female', TRUE),
    ('d0000000-0000-0000-0000-000000000003'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'P003', 'Bob', 'Johnson', 'Bob Johnson', '1988-07-10', 'male', TRUE),
    ('d0000000-0000-0000-0000-000000000004'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'P004', 'Alice', 'Williams', 'Alice Williams', '1991-05-25', 'female', TRUE),
    ('d0000000-0000-0000-0000-000000000005'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'P005', 'Charlie', 'Brown', 'Charlie Brown', '1989-11-30', 'male', TRUE),
    ('d0000000-0000-0000-0000-000000000006'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'P006', 'Diana', 'Davis', 'Diana Davis', '1993-09-12', 'female', TRUE),
    ('d0000000-0000-0000-0000-000000000007'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'P007', 'Eve', 'Miller', 'Eve Miller', '1990-12-05', 'female', TRUE),
    ('d0000000-0000-0000-0000-000000000008'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'P008', 'Frank', 'Wilson', 'Frank Wilson', '1987-04-18', 'male', TRUE),
    ('d0000000-0000-0000-0000-000000000009'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'P009', 'Grace', 'Moore', 'Grace Moore', '1994-08-22', 'female', TRUE),
    ('d0000000-0000-0000-0000-000000000010'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'P010', 'Henry', 'Taylor', 'Henry Taylor', '1992-02-14', 'male', TRUE)
ON CONFLICT (tenant_id, person_id) DO UPDATE SET
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    display_name = EXCLUDED.display_name,
    date_of_birth = EXCLUDED.date_of_birth,
    gender = EXCLUDED.gender,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- Person Contacts (emails obrigatórios)
INSERT INTO core.person_contacts (tenant_id, person_id, contact_type, contact_value, is_primary, is_verified)
VALUES 
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000001'::uuid, 'email', 'john.doe@acme.com', TRUE, TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000002'::uuid, 'email', 'jane.smith@acme.com', TRUE, TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000003'::uuid, 'email', 'bob.johnson@acme.com', TRUE, TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000004'::uuid, 'email', 'alice.williams@acme.com', TRUE, TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000005'::uuid, 'email', 'charlie.brown@acme.com', TRUE, TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000006'::uuid, 'email', 'diana.davis@acme.com', TRUE, TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000007'::uuid, 'email', 'eve.miller@acme.com', TRUE, TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000008'::uuid, 'email', 'frank.wilson@acme.com', TRUE, TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000009'::uuid, 'email', 'grace.moore@acme.com', TRUE, TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000010'::uuid, 'email', 'henry.taylor@acme.com', TRUE, TRUE),
    -- Alguns telefones opcionais
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000001'::uuid, 'phone', '+1-555-0101', FALSE, FALSE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000002'::uuid, 'mobile', '+1-555-0102', FALSE, FALSE)
ON CONFLICT (tenant_id, person_id, contact_type, contact_value) DO UPDATE SET
    is_primary = EXCLUDED.is_primary,
    is_verified = EXCLUDED.is_verified,
    updated_at = NOW();

-- Person Org Assignments (vínculos)
INSERT INTO core.person_org_assignments (tenant_id, person_id, org_unit_id, job_id, job_level_id, cost_center_id, effective_from, assignment_type, is_active)
VALUES 
    -- Engenheiros
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000001'::uuid, 'a0000000-0000-0000-0000-000000000005'::uuid, 'c0000000-0000-0000-0000-000000000001'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000001'::uuid AND level_code = 'SWE-SR' LIMIT 1), 'b0000000-0000-0000-0000-000000000001'::uuid, CURRENT_DATE, 'primary', TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000002'::uuid, 'a0000000-0000-0000-0000-000000000006'::uuid, 'c0000000-0000-0000-0000-000000000001'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000001'::uuid AND level_code = 'SWE-MID' LIMIT 1), 'b0000000-0000-0000-0000-000000000001'::uuid, CURRENT_DATE, 'primary', TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000003'::uuid, 'a0000000-0000-0000-0000-000000000002'::uuid, 'c0000000-0000-0000-0000-000000000005'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000005'::uuid AND level_code = 'ENG-MGR-L1' LIMIT 1), 'b0000000-0000-0000-0000-000000000001'::uuid, CURRENT_DATE, 'primary', TRUE),
    -- Vendas
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000004'::uuid, 'a0000000-0000-0000-0000-000000000003'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000003'::uuid AND level_code = 'SALES-REP-SR' LIMIT 1), 'b0000000-0000-0000-0000-000000000002'::uuid, CURRENT_DATE, 'primary', TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000005'::uuid, 'a0000000-0000-0000-0000-000000000003'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000003'::uuid AND level_code = 'SALES-REP-MID' LIMIT 1), 'b0000000-0000-0000-0000-000000000002'::uuid, CURRENT_DATE, 'primary', TRUE),
    -- RH
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000006'::uuid, 'a0000000-0000-0000-0000-000000000004'::uuid, 'c0000000-0000-0000-0000-000000000004'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000004'::uuid AND level_code = 'HR-BP-SR' LIMIT 1), NULL, CURRENT_DATE, 'primary', TRUE),
    -- Product Manager
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000007'::uuid, 'a0000000-0000-0000-0000-000000000002'::uuid, 'c0000000-0000-0000-0000-000000000002'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000002'::uuid AND level_code = 'PM-MID' LIMIT 1), 'b0000000-0000-0000-0000-000000000001'::uuid, CURRENT_DATE, 'primary', TRUE),
    -- Mais pessoas
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000008'::uuid, 'a0000000-0000-0000-0000-000000000005'::uuid, 'c0000000-0000-0000-0000-000000000001'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000001'::uuid AND level_code = 'SWE-JR' LIMIT 1), 'b0000000-0000-0000-0000-000000000001'::uuid, CURRENT_DATE, 'primary', TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000009'::uuid, 'a0000000-0000-0000-0000-000000000006'::uuid, 'c0000000-0000-0000-0000-000000000001'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000001'::uuid AND level_code = 'SWE-MID' LIMIT 1), 'b0000000-0000-0000-0000-000000000001'::uuid, CURRENT_DATE, 'primary', TRUE),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'd0000000-0000-0000-0000-000000000010'::uuid, 'a0000000-0000-0000-0000-000000000003'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, (SELECT id FROM core.job_levels WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid AND job_id = 'c0000000-0000-0000-0000-000000000003'::uuid AND level_code = 'SALES-REP-JR' LIMIT 1), 'b0000000-0000-0000-0000-000000000002'::uuid, CURRENT_DATE, 'primary', TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- D) IMPORTS: 1 Import Job Exemplo (com run e resultados fictícios)
-- ============================================================================

-- Import Job
INSERT INTO core.import_jobs (id, tenant_id, job_name, import_type, source_type, status, total_rows, processed_rows, error_rows, started_at, completed_at)
VALUES 
    ('e0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'Import People Demo', 'people', 'file', 'completed', 10, 8, 2, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day' + INTERVAL '5 minutes')
ON CONFLICT DO NOTHING;

-- Import Job Run
INSERT INTO core.import_job_runs (id, tenant_id, import_job_id, run_number, status, total_rows, processed_rows, error_rows, started_at, completed_at)
VALUES 
    ('f0000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'e0000000-0000-0000-0000-000000000001'::uuid, 1, 'completed', 10, 8, 2, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day' + INTERVAL '5 minutes')
ON CONFLICT DO NOTHING;

-- Import Row Results (8 válidos, 2 com erro)
INSERT INTO core.import_row_results (tenant_id, import_job_id, import_job_run_id, row_number, row_data, status, entity_type, entity_id)
VALUES 
    -- Válidos
    ('00000000-0000-0000-0000-000000000001'::uuid, 'e0000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000001'::uuid, 1, '{"person_id": "P001", "first_name": "John", "last_name": "Doe", "email": "john.doe@acme.com"}'::jsonb, 'processed', 'person', 'd0000000-0000-0000-0000-000000000001'::uuid),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'e0000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000001'::uuid, 2, '{"person_id": "P002", "first_name": "Jane", "last_name": "Smith", "email": "jane.smith@acme.com"}'::jsonb, 'processed', 'person', 'd0000000-0000-0000-0000-000000000002'::uuid),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'e0000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000001'::uuid, 3, '{"person_id": "P003", "first_name": "Bob", "last_name": "Johnson", "email": "bob.johnson@acme.com"}'::jsonb, 'processed', 'person', 'd0000000-0000-0000-0000-000000000003'::uuid),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'e0000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000001'::uuid, 4, '{"person_id": "P004", "first_name": "Alice", "last_name": "Williams", "email": "alice.williams@acme.com"}'::jsonb, 'processed', 'person', 'd0000000-0000-0000-0000-000000000004'::uuid),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'e0000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000001'::uuid, 5, '{"person_id": "P005", "first_name": "Charlie", "last_name": "Brown", "email": "charlie.brown@acme.com"}'::jsonb, 'processed', 'person', 'd0000000-0000-0000-0000-000000000005'::uuid),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'e0000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000001'::uuid, 6, '{"person_id": "P006", "first_name": "Diana", "last_name": "Davis", "email": "diana.davis@acme.com"}'::jsonb, 'processed', 'person', 'd0000000-0000-0000-0000-000000000006'::uuid),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'e0000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000001'::uuid, 7, '{"person_id": "P007", "first_name": "Eve", "last_name": "Miller", "email": "eve.miller@acme.com"}'::jsonb, 'processed', 'person', 'd0000000-0000-0000-0000-000000000007'::uuid),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'e0000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000001'::uuid, 8, '{"person_id": "P008", "first_name": "Frank", "last_name": "Wilson", "email": "frank.wilson@acme.com"}'::jsonb, 'processed', 'person', 'd0000000-0000-0000-0000-000000000008'::uuid),
    -- Com erro
    ('00000000-0000-0000-0000-000000000001'::uuid, 'e0000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000001'::uuid, 9, '{"person_id": "P999", "first_name": "Invalid", "last_name": "Person", "email": "invalid-email"}'::jsonb, 'error', NULL, NULL),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'e0000000-0000-0000-0000-000000000001'::uuid, 'f0000000-0000-0000-0000-000000000001'::uuid, 10, '{"person_id": "", "first_name": "Missing", "last_name": "Data"}'::jsonb, 'error', NULL, NULL)
ON CONFLICT DO NOTHING;

-- Atualizar error_message e error_details para linhas com erro
UPDATE core.import_row_results 
SET error_message = 'Email inválido',
    error_details = '{"field": "email", "value": "invalid-email"}'::jsonb
WHERE row_number = 9 AND import_job_id = 'e0000000-0000-0000-0000-000000000001'::uuid;

UPDATE core.import_row_results 
SET error_message = 'Campos obrigatórios ausentes',
    error_details = '{"fields": ["person_id", "email"]}'::jsonb
WHERE row_number = 10 AND import_job_id = 'e0000000-0000-0000-0000-000000000001'::uuid;

-- Import Mappings (exemplo)
INSERT INTO core.import_mappings (tenant_id, import_job_id, source_column, target_field, target_entity_type, is_required, default_value)
VALUES 
    ('00000000-0000-0000-0000-000000000001'::uuid, 'e0000000-0000-0000-0000-000000000001'::uuid, 'person_id', 'person_id', 'person', TRUE, NULL),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'e0000000-0000-0000-0000-000000000001'::uuid, 'first_name', 'first_name', 'person', TRUE, NULL),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'e0000000-0000-0000-0000-000000000001'::uuid, 'last_name', 'last_name', 'person', TRUE, NULL),
    ('00000000-0000-0000-0000-000000000001'::uuid, 'e0000000-0000-0000-0000-000000000001'::uuid, 'email', 'email', 'person_contact', TRUE, NULL)
ON CONFLICT (import_job_id, source_column) DO UPDATE SET
    target_field = EXCLUDED.target_field,
    target_entity_type = EXCLUDED.target_entity_type,
    is_required = EXCLUDED.is_required,
    default_value = EXCLUDED.default_value,
    updated_at = NOW();

-- ============================================================================
-- VALIDAÇÃO
-- ============================================================================

DO $$
DECLARE
    v_org_unit_count INTEGER;
    v_cost_center_count INTEGER;
    v_job_count INTEGER;
    v_job_level_count INTEGER;
    v_people_count INTEGER;
    v_import_job_count INTEGER;
BEGIN
    -- Valida org_units
    SELECT COUNT(*) INTO v_org_unit_count
    FROM core.org_units
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;
    
    IF v_org_unit_count < 6 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado 6 org_units, encontrado %', v_org_unit_count;
    END IF;
    
    -- Valida cost_centers
    SELECT COUNT(*) INTO v_cost_center_count
    FROM core.cost_centers
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;
    
    IF v_cost_center_count < 2 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado 2 cost_centers, encontrado %', v_cost_center_count;
    END IF;
    
    -- Valida jobs
    SELECT COUNT(*) INTO v_job_count
    FROM core.jobs
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;
    
    IF v_job_count < 5 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado 5 jobs, encontrado %', v_job_count;
    END IF;
    
    -- Valida job_levels
    SELECT COUNT(*) INTO v_job_level_count
    FROM core.job_levels
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;
    
    IF v_job_level_count < 14 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado 14 job_levels, encontrado %', v_job_level_count;
    END IF;
    
    -- Valida people
    SELECT COUNT(*) INTO v_people_count
    FROM core.people
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;
    
    IF v_people_count < 10 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado 10 people, encontrado %', v_people_count;
    END IF;
    
    -- Valida import_job
    SELECT COUNT(*) INTO v_import_job_count
    FROM core.import_jobs
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid;
    
    IF v_import_job_count < 1 THEN
        RAISE EXCEPTION 'Seed demo falhou: esperado 1 import_job, encontrado %', v_import_job_count;
    END IF;
    
    RAISE NOTICE 'Seed demo concluído: org_units=%, cost_centers=%, jobs=%, job_levels=%, people=%, import_jobs=%', 
        v_org_unit_count, v_cost_center_count, v_job_count, v_job_level_count, v_people_count, v_import_job_count;
END;
$$;
