-- HUMANTRÍA — STRATEGY GS FULL V1 — Tables
-- Status: BLOQUEANTE
-- Escopo: initiatives (objectives já existe); view portfolio_snapshot
-- objectives: pré-existente (tenant_id, cycle_*, code, title, status, owner_person_id)

SET search_path TO strategy, foundation, core, public;

-- ============================================================================
-- INITIATIVES (ligadas a objectives)
-- ============================================================================

CREATE TABLE IF NOT EXISTS strategy.initiatives (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES foundation.tenants(id) ON DELETE CASCADE,
    objective_id UUID NOT NULL REFERENCES strategy.objectives(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'completed', 'blocked', 'archived')),
    owner_person_id UUID REFERENCES core.people(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

CREATE INDEX IF NOT EXISTS idx_initiatives_tenant_id ON strategy.initiatives(tenant_id);
CREATE INDEX IF NOT EXISTS idx_initiatives_objective_id ON strategy.initiatives(objective_id);
CREATE INDEX IF NOT EXISTS idx_initiatives_status ON strategy.initiatives(status);

COMMENT ON TABLE strategy.initiatives IS 'Iniciativas ligadas a objectives (GS Strategy Full V1)';

-- Trigger updated_at
CREATE OR REPLACE FUNCTION strategy._initiatives_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_initiatives_updated_at ON strategy.initiatives;
CREATE TRIGGER trigger_initiatives_updated_at
    BEFORE UPDATE ON strategy.initiatives
    FOR EACH ROW EXECUTE FUNCTION strategy._initiatives_updated_at();
