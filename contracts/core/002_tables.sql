-- HUMANTRÍA — CORE TABLES V1
-- Status: BLOQUEANTE
-- Escopo: Semântica canônica do cliente (multi-tenant + RLS)

SET search_path TO core, foundation, public;

-- ============================================================================
-- A) ORGANIZAÇÃO
-- ============================================================================

-- Org Units (unidades organizacionais com parent_id; suporte a árvore)
CREATE TABLE IF NOT EXISTS core.org_units (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES core.org_units(id) ON DELETE SET NULL,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    org_unit_type TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE INDEX IF NOT EXISTS idx_org_units_tenant_id ON core.org_units(tenant_id);
CREATE INDEX IF NOT EXISTS idx_org_units_parent_id ON core.org_units(parent_id);

COMMENT ON TABLE core.org_units IS 'Unidades organizacionais (suporte a árvore via parent_id)';
COMMENT ON COLUMN core.org_units.parent_id IS 'Referência ao org_unit pai (NULL = raiz)';

-- Org Units History (effective dating simples)
CREATE TABLE IF NOT EXISTS core.org_units_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_unit_id UUID NOT NULL REFERENCES core.org_units(id) ON DELETE CASCADE,
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    effective_from DATE NOT NULL,
    effective_to DATE,
    name TEXT NOT NULL,
    description TEXT,
    org_unit_type TEXT,
    parent_id UUID REFERENCES core.org_units(id) ON DELETE SET NULL,
    changed_by UUID,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_org_units_history_org_unit_id ON core.org_units_history(org_unit_id);
CREATE INDEX IF NOT EXISTS idx_org_units_history_tenant_id ON core.org_units_history(tenant_id);
CREATE INDEX IF NOT EXISTS idx_org_units_history_effective ON core.org_units_history(effective_from, effective_to);

COMMENT ON TABLE core.org_units_history IS 'Histórico de org_units com effective dating (effective_from, effective_to)';

-- TODO v1.5: org_unit_edges para duplo-reporte (se não der, deixar TODO e registrar)
-- CREATE TABLE IF NOT EXISTS core.org_unit_edges (
--     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--     tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
--     org_unit_id UUID NOT NULL REFERENCES core.org_units(id) ON DELETE CASCADE,
--     parent_org_unit_id UUID NOT NULL REFERENCES core.org_units(id) ON DELETE CASCADE,
--     relationship_type TEXT NOT NULL,
--     effective_from DATE NOT NULL,
--     effective_to DATE,
--     metadata JSONB DEFAULT '{}'::jsonb,
--     created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
--     updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
-- );
-- COMMENT: Suporte a duplo-reporte (matrix organization) - implementação futura v1.5

-- Cost Centers (centros de custo)
CREATE TABLE IF NOT EXISTS core.cost_centers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE INDEX IF NOT EXISTS idx_cost_centers_tenant_id ON core.cost_centers(tenant_id);

COMMENT ON TABLE core.cost_centers IS 'Centros de custo';

-- Links Org Unit ↔ Cost Center (se aplicável)
CREATE TABLE IF NOT EXISTS core.org_unit_cost_center_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    org_unit_id UUID NOT NULL REFERENCES core.org_units(id) ON DELETE CASCADE,
    cost_center_id UUID NOT NULL REFERENCES core.cost_centers(id) ON DELETE CASCADE,
    effective_from DATE NOT NULL,
    effective_to DATE,
    allocation_percentage NUMERIC CHECK (allocation_percentage >= 0 AND allocation_percentage <= 100),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, org_unit_id, cost_center_id, effective_from)
);

CREATE INDEX IF NOT EXISTS idx_org_unit_cost_center_links_tenant_id ON core.org_unit_cost_center_links(tenant_id);
CREATE INDEX IF NOT EXISTS idx_org_unit_cost_center_links_org_unit_id ON core.org_unit_cost_center_links(org_unit_id);
CREATE INDEX IF NOT EXISTS idx_org_unit_cost_center_links_cost_center_id ON core.org_unit_cost_center_links(cost_center_id);

COMMENT ON TABLE core.org_unit_cost_center_links IS 'Links entre org_units e cost_centers (com effective dating e allocation)';

-- ============================================================================
-- B) JOBS/LEVELS
-- ============================================================================

-- Jobs (cargos)
CREATE TABLE IF NOT EXISTS core.jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE INDEX IF NOT EXISTS idx_jobs_tenant_id ON core.jobs(tenant_id);

COMMENT ON TABLE core.jobs IS 'Cargos (jobs)';

-- Job Levels (grade simples)
CREATE TABLE IF NOT EXISTS core.job_levels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    job_id UUID NOT NULL REFERENCES core.jobs(id) ON DELETE CASCADE,
    level_code TEXT NOT NULL,
    level_name TEXT NOT NULL,
    level_number INTEGER,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, job_id, level_code)
);

CREATE INDEX IF NOT EXISTS idx_job_levels_tenant_id ON core.job_levels(tenant_id);
CREATE INDEX IF NOT EXISTS idx_job_levels_job_id ON core.job_levels(job_id);

COMMENT ON TABLE core.job_levels IS 'Níveis/grades de jobs (grade simples)';

-- TODO: job_families é opcional, só se não aumentar complexidade
-- CREATE TABLE IF NOT EXISTS core.job_families (
--     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--     tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
--     code TEXT NOT NULL,
--     name TEXT NOT NULL,
--     description TEXT,
--     metadata JSONB DEFAULT '{}'::jsonb,
--     created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
--     updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
--     UNIQUE(tenant_id, code)
-- );
-- COMMENT: Job families - implementação futura se necessário

-- ============================================================================
-- C) PEOPLE
-- ============================================================================

-- People (pessoas; person_id)
CREATE TABLE IF NOT EXISTS core.people (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    person_id TEXT NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    display_name TEXT,
    date_of_birth DATE,
    gender TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    UNIQUE(tenant_id, person_id)
);

CREATE INDEX IF NOT EXISTS idx_people_tenant_id ON core.people(tenant_id);
CREATE INDEX IF NOT EXISTS idx_people_person_id ON core.people(person_id);

COMMENT ON TABLE core.people IS 'Pessoas (person_id único por tenant)';

-- Person Contacts (email obrigatório; phone opcional conforme decisão)
CREATE TABLE IF NOT EXISTS core.person_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    person_id UUID NOT NULL REFERENCES core.people(id) ON DELETE CASCADE,
    contact_type TEXT NOT NULL CHECK (contact_type IN ('email', 'phone', 'mobile', 'other')),
    contact_value TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, person_id, contact_type, contact_value)
);

CREATE INDEX IF NOT EXISTS idx_person_contacts_tenant_id ON core.person_contacts(tenant_id);
CREATE INDEX IF NOT EXISTS idx_person_contacts_person_id ON core.person_contacts(person_id);
CREATE INDEX IF NOT EXISTS idx_person_contacts_contact_type ON core.person_contacts(contact_type);

COMMENT ON TABLE core.person_contacts IS 'Contatos de pessoas (email obrigatório; phone opcional)';
COMMENT ON COLUMN core.person_contacts.contact_type IS 'email, phone, mobile, other';

-- Person Identities (identidades/identificadores)
CREATE TABLE IF NOT EXISTS core.person_identities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    person_id UUID NOT NULL REFERENCES core.people(id) ON DELETE CASCADE,
    identity_type TEXT NOT NULL CHECK (identity_type IN ('cpf', 'passport', 'rg', 'other')),
    identity_value TEXT NOT NULL,
    issuing_country TEXT,
    issued_at DATE,
    expires_at DATE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tenant_id, person_id, identity_type, identity_value)
);

CREATE INDEX IF NOT EXISTS idx_person_identities_tenant_id ON core.person_identities(tenant_id);
CREATE INDEX IF NOT EXISTS idx_person_identities_person_id ON core.person_identities(person_id);
CREATE INDEX IF NOT EXISTS idx_person_identities_identity_type ON core.person_identities(identity_type);

COMMENT ON TABLE core.person_identities IS 'Identidades/identificadores de pessoas (CPF, passport, RG, etc)';

-- Person Org Assignments (vínculo com effective dating)
CREATE TABLE IF NOT EXISTS core.person_org_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    person_id UUID NOT NULL REFERENCES core.people(id) ON DELETE CASCADE,
    org_unit_id UUID NOT NULL REFERENCES core.org_units(id) ON DELETE CASCADE,
    job_id UUID REFERENCES core.jobs(id) ON DELETE SET NULL,
    job_level_id UUID REFERENCES core.job_levels(id) ON DELETE SET NULL,
    cost_center_id UUID REFERENCES core.cost_centers(id) ON DELETE SET NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    assignment_type TEXT CHECK (assignment_type IN ('primary', 'secondary', 'temporary')),
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

CREATE INDEX IF NOT EXISTS idx_person_org_assignments_tenant_id ON core.person_org_assignments(tenant_id);
CREATE INDEX IF NOT EXISTS idx_person_org_assignments_person_id ON core.person_org_assignments(person_id);
CREATE INDEX IF NOT EXISTS idx_person_org_assignments_org_unit_id ON core.person_org_assignments(org_unit_id);
CREATE INDEX IF NOT EXISTS idx_person_org_assignments_effective ON core.person_org_assignments(effective_from, effective_to);

COMMENT ON TABLE core.person_org_assignments IS 'Vínculos pessoa ↔ organização (com effective dating)';

-- Person Status History (histórico de status)
CREATE TABLE IF NOT EXISTS core.person_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    person_id UUID NOT NULL REFERENCES core.people(id) ON DELETE CASCADE,
    old_status TEXT,
    new_status TEXT NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    reason TEXT,
    changed_by UUID,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_person_status_history_tenant_id ON core.person_status_history(tenant_id);
CREATE INDEX IF NOT EXISTS idx_person_status_history_person_id ON core.person_status_history(person_id);
CREATE INDEX IF NOT EXISTS idx_person_status_history_effective ON core.person_status_history(effective_from, effective_to);

COMMENT ON TABLE core.person_status_history IS 'Histórico de mudanças de status de pessoas';

-- ============================================================================
-- D) IMPORTS (infra)
-- ============================================================================

-- Import Jobs (trabalhos de importação)
CREATE TABLE IF NOT EXISTS core.import_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    job_name TEXT NOT NULL,
    import_type TEXT NOT NULL,
    source_type TEXT NOT NULL CHECK (source_type IN ('file', 'api', 'database', 'manual')),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'mapping', 'preview', 'running', 'completed', 'failed', 'cancelled')),
    total_rows INTEGER DEFAULT 0,
    processed_rows INTEGER DEFAULT 0,
    error_rows INTEGER DEFAULT 0,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    error_message TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID
);

CREATE INDEX IF NOT EXISTS idx_import_jobs_tenant_id ON core.import_jobs(tenant_id);
CREATE INDEX IF NOT EXISTS idx_import_jobs_status ON core.import_jobs(status);
CREATE INDEX IF NOT EXISTS idx_import_jobs_created_at ON core.import_jobs(created_at);

COMMENT ON TABLE core.import_jobs IS 'Trabalhos de importação';

-- Import Job Runs (execuções de import)
CREATE TABLE IF NOT EXISTS core.import_job_runs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    import_job_id UUID NOT NULL REFERENCES core.import_jobs(id) ON DELETE CASCADE,
    run_number INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'running' CHECK (status IN ('running', 'completed', 'failed', 'cancelled')),
    total_rows INTEGER DEFAULT 0,
    processed_rows INTEGER DEFAULT 0,
    error_rows INTEGER DEFAULT 0,
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    error_message TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(import_job_id, run_number)
);

CREATE INDEX IF NOT EXISTS idx_import_job_runs_tenant_id ON core.import_job_runs(tenant_id);
CREATE INDEX IF NOT EXISTS idx_import_job_runs_import_job_id ON core.import_job_runs(import_job_id);
CREATE INDEX IF NOT EXISTS idx_import_job_runs_status ON core.import_job_runs(status);

COMMENT ON TABLE core.import_job_runs IS 'Execuções de import (runs)';

-- Import Row Results (preview/erros)
CREATE TABLE IF NOT EXISTS core.import_row_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    import_job_id UUID NOT NULL REFERENCES core.import_jobs(id) ON DELETE CASCADE,
    import_job_run_id UUID REFERENCES core.import_job_runs(id) ON DELETE CASCADE,
    row_number INTEGER NOT NULL,
    row_data JSONB NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'preview', 'valid', 'error', 'processed', 'skipped')),
    error_message TEXT,
    error_details JSONB DEFAULT '{}'::jsonb,
    entity_type TEXT,
    entity_id UUID,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_import_row_results_tenant_id ON core.import_row_results(tenant_id);
CREATE INDEX IF NOT EXISTS idx_import_row_results_import_job_id ON core.import_row_results(import_job_id);
CREATE INDEX IF NOT EXISTS idx_import_row_results_import_job_run_id ON core.import_row_results(import_job_run_id);
CREATE INDEX IF NOT EXISTS idx_import_row_results_status ON core.import_row_results(status);
CREATE INDEX IF NOT EXISTS idx_import_row_results_row_number ON core.import_row_results(row_number);

COMMENT ON TABLE core.import_row_results IS 'Resultados de linhas de import (preview/erros)';

-- Import Mappings (mapeamentos de colunas)
CREATE TABLE IF NOT EXISTS core.import_mappings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    import_job_id UUID NOT NULL REFERENCES core.import_jobs(id) ON DELETE CASCADE,
    source_column TEXT NOT NULL,
    target_field TEXT NOT NULL,
    target_entity_type TEXT NOT NULL,
    transformation_rule JSONB DEFAULT '{}'::jsonb,
    is_required BOOLEAN DEFAULT FALSE,
    default_value TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(import_job_id, source_column)
);

CREATE INDEX IF NOT EXISTS idx_import_mappings_tenant_id ON core.import_mappings(tenant_id);
CREATE INDEX IF NOT EXISTS idx_import_mappings_import_job_id ON core.import_mappings(import_job_id);

COMMENT ON TABLE core.import_mappings IS 'Mapeamentos de colunas de import (source → target)';

-- ============================================================================
-- TRIGGERS: updated_at automático
-- ============================================================================

CREATE OR REPLACE FUNCTION core.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

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
        AND table_name NOT IN ('import_row_results') -- tabelas que não precisam de trigger automático
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS trigger_%s_updated_at ON core.%I', r.table_name, r.table_name);
        EXECUTE format('CREATE TRIGGER trigger_%s_updated_at BEFORE UPDATE ON core.%I FOR EACH ROW EXECUTE FUNCTION core.update_updated_at()', r.table_name, r.table_name);
    END LOOP;
END;
$$;
