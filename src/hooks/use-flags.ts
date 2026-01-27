import { useQuery } from '@tanstack/react-query'

import { getSupabaseClient } from '../services/supabase/client'

export function useFlagsQuery({ enabled, tenantId }: { enabled: boolean; tenantId: string | null }) {
  return useQuery<Record<string, boolean>>({
    queryKey: ['foundation', 'flags', tenantId],
    enabled,
    queryFn: async () => {
      if (!tenantId) return {}
      const supabase = getSupabaseClient()

      const tffRes = await supabase
        .schema('foundation')
        .from('tenant_feature_flags')
        .select('feature_flag_id,value')
        .eq('tenant_id', tenantId)
      if (tffRes.error) throw tffRes.error

      const ids = (tffRes.data ?? []).map((r: any) => r.feature_flag_id).filter(Boolean)
      if (ids.length === 0) return {}

      const ffRes = await supabase.schema('foundation').from('feature_flags').select('id,code').in('id', ids)
      if (ffRes.error) throw ffRes.error

      const byId = new Map<string, string>()
      for (const row of ffRes.data ?? []) {
        if (row?.id && row?.code) byId.set(row.id, row.code)
      }

      const out: Record<string, boolean> = {}
      for (const row of tffRes.data ?? []) {
        const code = byId.get(row.feature_flag_id)
        if (code) out[code] = Boolean(row.value)
      }
      return out
    },
  })
}

