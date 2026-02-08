import { supabase } from './supabase'

/** Tenant_id real dos strategy.objectives (descoberto via MCP; usado para contexto RLS). */
export const TENANT_TARGET = '00000000-0000-0000-0000-000000000001' as const

export async function getSession() {
  const { data: { session }, error } = await supabase.auth.getSession()
  return { session, error }
}

/**
 * Seta o tenant da sessão (fallback quando JWT não traz tenant_id).
 * Deve ser chamado após login ou ao carregar /strategy.
 */
export async function setTenantContext(tenantId: string): Promise<{ ok: boolean; error?: string }> {
  const { error } = await supabase.schema('foundation').rpc('set_current_tenant_id', {
    p_tenant_id: tenantId,
  })
  if (error) return { ok: false, error: error.message }
  return { ok: true }
}

/**
 * Retorna os objectives com tenant context setado na mesma request (respeita RLS).
 */
export async function fetchObjectivesForTenant(tenantId: string) {
  const { data, error } = await supabase.schema('strategy').rpc('objectives_list_for_tenant', {
    p_tenant_id: tenantId,
  })
  if (error) throw error
  return data ?? []
}
