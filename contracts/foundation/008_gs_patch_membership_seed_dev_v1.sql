-- HUMANTRÍA — GS-PATCH AUTHZ: seed DEV membership (V1)
-- Uma linha para user_id/tenant_id com role tenant_admin. Idempotente (upsert).
-- Apenas para ambientes DEV onde o usuário existe.

SET search_path TO foundation_authz, public;

INSERT INTO foundation_authz.user_memberships (user_id, tenant_id, role)
VALUES (
    'efe5f770-ac33-4d69-88f8-17a000de8ebd'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    'tenant_admin'
)
ON CONFLICT (user_id, tenant_id) DO UPDATE SET role = EXCLUDED.role;
