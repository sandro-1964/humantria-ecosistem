-- HUMANTRÍA — GS-PATCH AUTHZ: membership canônico para RLS (V1)
-- Superfície user_id ↔ tenant_id ↔ role para políticas RLS sem depender de JWT custom claims.
-- Idempotente.

-- Schema (criar antes de usar no search_path)
CREATE SCHEMA IF NOT EXISTS foundation_authz;
COMMENT ON SCHEMA foundation_authz IS 'Superfície canônica de autorização para RLS (membership por user/tenant/role).';

SET search_path TO foundation_authz, foundation, public;

-- Tabela user_memberships (canônica para RLS)
CREATE TABLE IF NOT EXISTS foundation_authz.user_memberships (
    user_id UUID NOT NULL,
    tenant_id UUID NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('gestor', 'tenant_admin', 'especialista', 'auditor', 'platform_owner', 'colaborador')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, tenant_id)
);

COMMENT ON TABLE foundation_authz.user_memberships IS 'Membership canônico para RLS: user_id ↔ tenant_id ↔ role (não depende de JWT).';

-- RLS
ALTER TABLE foundation_authz.user_memberships ENABLE ROW LEVEL SECURITY;

-- SELECT: usuário vê apenas as próprias memberships
CREATE POLICY policy_user_memberships_select_own
    ON foundation_authz.user_memberships
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

-- INSERT/UPDATE/DELETE: apenas platform_owner (por enquanto; tenant_admin pode ser adicionado depois)
CREATE POLICY policy_user_memberships_platform_owner_all
    ON foundation_authz.user_memberships
    FOR ALL
    TO authenticated
    USING (foundation.is_platform_owner())
    WITH CHECK (foundation.is_platform_owner());

-- Grants
GRANT USAGE ON SCHEMA foundation_authz TO authenticated;
GRANT SELECT ON foundation_authz.user_memberships TO authenticated;
