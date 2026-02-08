-- HUMANTRÍA — GS-PATCH FK Cleanup V1 — Drop FKs strategy → core
-- Remove acoplamento físico; colunas UUID mantidas como referência lógica.
-- Triggers (futuro): se necessário validação em write, usar core_assert.assert_* em BEFORE INSERT/UPDATE (comentado abaixo).

SET search_path TO strategy, core, foundation, public;

-- 1. approval_history.approver_person_id → core.people
ALTER TABLE strategy.approval_history DROP CONSTRAINT IF EXISTS approval_history_approver_person_id_fkey;

-- 2. budget_approvals.approver_person_id → core.people
ALTER TABLE strategy.budget_approvals DROP CONSTRAINT IF EXISTS budget_approvals_approver_person_id_fkey;

-- 3. budget_items.cost_center_id → core.cost_centers
ALTER TABLE strategy.budget_items DROP CONSTRAINT IF EXISTS budget_items_cost_center_id_fkey;

-- 4. budget_items.org_unit_id → core.org_units
ALTER TABLE strategy.budget_items DROP CONSTRAINT IF EXISTS budget_items_org_unit_id_fkey;

-- 5. initiatives.owner_person_id → core.people
ALTER TABLE strategy.initiatives DROP CONSTRAINT IF EXISTS initiatives_owner_person_id_fkey;

-- 6. key_results.owner_person_id → core.people
ALTER TABLE strategy.key_results DROP CONSTRAINT IF EXISTS key_results_owner_person_id_fkey;

-- 7. objectives.owner_person_id → core.people
ALTER TABLE strategy.objectives DROP CONSTRAINT IF EXISTS objectives_owner_person_id_fkey;

-- 8. staffing_demands.cost_center_id → core.cost_centers
ALTER TABLE strategy.staffing_demands DROP CONSTRAINT IF EXISTS staffing_demands_cost_center_id_fkey;

-- 9. staffing_demands.job_id → core.jobs
ALTER TABLE strategy.staffing_demands DROP CONSTRAINT IF EXISTS staffing_demands_job_id_fkey;

-- 10. staffing_demands.job_level_id → core.job_levels
ALTER TABLE strategy.staffing_demands DROP CONSTRAINT IF EXISTS staffing_demands_job_level_id_fkey;

-- 11. staffing_demands.org_unit_id → core.org_units
ALTER TABLE strategy.staffing_demands DROP CONSTRAINT IF EXISTS staffing_demands_org_unit_id_fkey;

-- =============================================================================
-- Triggers (futuro) — descomentar e ajustar se validação em write for exigida
-- =============================================================================
-- Exemplo para strategy.objectives (owner_person_id):
-- CREATE OR REPLACE FUNCTION strategy.validate_owner_person_id()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     IF NEW.owner_person_id IS NOT NULL THEN
--         PERFORM core_assert.assert_person_exists(NEW.tenant_id, NEW.owner_person_id);
--     END IF;
--     RETURN NEW;
-- END; $$ LANGUAGE plpgsql;
-- CREATE TRIGGER objectives_validate_owner_person
--     BEFORE INSERT OR UPDATE OF owner_person_id ON strategy.objectives
--     FOR EACH ROW EXECUTE FUNCTION strategy.validate_owner_person_id();
