-- HUMANTRÍA — GS-PATCH AUTHZ: policies Strategy por membership (V1)
-- strategy.objectives (e opcionalmente key_results/initiatives) usam foundation_authz.user_memberships + auth.uid().
-- Idempotente; não usa JWT role/tenant_id para acesso.

SET search_path TO strategy, foundation_authz, foundation, public;

-- =============================================================================
-- strategy.objectives — remover policies antigas (JWT) e criar por membership
-- =============================================================================

DROP POLICY IF EXISTS policy_strategy_objectives_analyst_select ON strategy.objectives;
DROP POLICY IF EXISTS policy_strategy_objectives_gestor_all ON strategy.objectives;
DROP POLICY IF EXISTS policy_strategy_objectives_tenant_admin_all ON strategy.objectives;
-- Manter platform_owner; não remover policy_strategy_objectives_platform_owner_all

-- SELECT: platform_owner OU usuário com membership no tenant e role que pode ver
CREATE POLICY policy_strategy_objectives_membership_select
    ON strategy.objectives
    FOR SELECT
    TO authenticated
    USING (
        foundation.is_platform_owner()
        OR EXISTS (
            SELECT 1 FROM foundation_authz.user_memberships m
            WHERE m.user_id = auth.uid()
              AND m.tenant_id = strategy.objectives.tenant_id
              AND m.role IN ('gestor', 'tenant_admin', 'especialista', 'auditor', 'platform_owner', 'colaborador')
        )
    );

-- ALL (INSERT/UPDATE/DELETE): platform_owner OU membership com role tenant_admin ou gestor
CREATE POLICY policy_strategy_objectives_membership_all
    ON strategy.objectives
    FOR ALL
    TO authenticated
    USING (
        foundation.is_platform_owner()
        OR EXISTS (
            SELECT 1 FROM foundation_authz.user_memberships m
            WHERE m.user_id = auth.uid()
              AND m.tenant_id = strategy.objectives.tenant_id
              AND m.role IN ('tenant_admin', 'gestor')
        )
    )
    WITH CHECK (
        foundation.is_platform_owner()
        OR EXISTS (
            SELECT 1 FROM foundation_authz.user_memberships m
            WHERE m.user_id = auth.uid()
              AND m.tenant_id = strategy.objectives.tenant_id
              AND m.role IN ('tenant_admin', 'gestor')
        )
    );
