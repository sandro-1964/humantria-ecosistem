-- GS-PATCH: setter canônico para tenant context (session fallback quando JWT não traz tenant_id)
-- Aplicado via MCP; não altera policies.
SET search_path TO foundation, public;

CREATE OR REPLACE FUNCTION foundation.set_current_tenant_id(p_tenant_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
BEGIN
  PERFORM set_config('app.current_tenant_id', p_tenant_id::text, true);
END;
$$;

COMMENT ON FUNCTION foundation.set_current_tenant_id(uuid) IS 'Seta o tenant da sessão (fallback quando JWT não traz tenant_id). Chamar após login ou ao carregar /strategy.';

GRANT EXECUTE ON FUNCTION foundation.set_current_tenant_id(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION foundation.set_current_tenant_id(uuid) TO anon;
