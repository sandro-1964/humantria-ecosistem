import { useQuery } from '@tanstack/react-query'

import { getSupabaseClient } from '../services/supabase/client'

export type RbacData = {
  role: string | null
  permissions: string[]
}

export function useRbacQuery({
  enabled,
  tenantId,
  roleFromJwt,
  userEmail,
}: {
  enabled: boolean
  tenantId: string | null
  roleFromJwt: string | null
  userEmail: string | null
}) {
  return useQuery<RbacData>({
    queryKey: ['foundation', 'rbac', tenantId, roleFromJwt, userEmail],
    enabled,
    queryFn: async () => {
      // Fast path: platform_owner is sovereign; we still return empty permissions list (treat as allow-all via role checks).
      if (roleFromJwt === 'platform_owner') return { role: roleFromJwt, permissions: ['*'] }

      const supabase = getSupabaseClient()

      // If roleFromJwt exists, still try to resolve permissions from catalogs.
      if (roleFromJwt) {
        const roleRes = await supabase
          .schema('foundation')
          .from('roles')
          .select('id, code')
          .eq('code', roleFromJwt)
          .maybeSingle()
        if (roleRes.error) throw roleRes.error
        const roleId = (roleRes.data as any)?.id as string | undefined
        if (!roleId) return { role: roleFromJwt, permissions: [] }

        const rpRes = await supabase
          .schema('foundation')
          .from('role_permissions')
          .select('permission_id')
          .eq('role_id', roleId)
        if (rpRes.error) throw rpRes.error

        const permIds = (rpRes.data ?? []).map((r: any) => r.permission_id).filter(Boolean)
        if (permIds.length === 0) return { role: roleFromJwt, permissions: [] }

        const permsRes = await supabase
          .schema('foundation')
          .from('permissions')
          .select('code')
          .in('id', permIds)
        if (permsRes.error) throw permsRes.error
        const permissions = (permsRes.data ?? []).map((p: any) => p.code).filter(Boolean)
        return { role: roleFromJwt, permissions }
      }

      // If there is no role in JWT yet, return safe default.
      return { role: null, permissions: [] }
    },
  })
}

