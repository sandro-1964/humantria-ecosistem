import { useQuery } from '@tanstack/react-query'

import { getSupabaseClient } from '../services/supabase/client'

export type TenantRow = {
  id: string
  name: string
  slug: string
  status: string
  created_at: string
}

export type TenantProfileRow = {
  tenant_id: string
  primary_locale: string | null
  base_currency: string | null
  country: string | null
}

export type TenantSettingsRow = {
  tenant_id: string
  locale: string | null
  timezone: string | null
  base_currency: string | null
  metadata: unknown
}

export type TenantContextData = {
  tenant: TenantRow | null
  profile: TenantProfileRow | null
  settings: TenantSettingsRow | null
}

export function useTenantContextQuery({
  enabled,
  tenantId,
}: {
  enabled: boolean
  tenantId: string | null
}) {
  return useQuery<TenantContextData>({
    queryKey: ['foundation', 'tenantContext', tenantId],
    enabled,
    queryFn: async () => {
      if (!tenantId) return { tenant: null, profile: null, settings: null }
      const supabase = getSupabaseClient()

      const tenantRes = await supabase.schema('foundation').from('tenants').select('*').eq('id', tenantId).maybeSingle()
      if (tenantRes.error) throw tenantRes.error

      const profileRes = await supabase
        .schema('foundation')
        .from('tenant_profiles')
        .select('*')
        .eq('tenant_id', tenantId)
        .maybeSingle()
      if (profileRes.error) throw profileRes.error

      const settingsRes = await supabase
        .schema('foundation')
        .from('tenant_settings')
        .select('*')
        .eq('tenant_id', tenantId)
        .maybeSingle()
      if (settingsRes.error) throw settingsRes.error

      return {
        tenant: (tenantRes.data as TenantRow | null) ?? null,
        profile: (profileRes.data as TenantProfileRow | null) ?? null,
        settings: (settingsRes.data as TenantSettingsRow | null) ?? null,
      }
    },
  })
}

