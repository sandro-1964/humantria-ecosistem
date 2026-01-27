import { useQuery } from '@tanstack/react-query'
import { useParams } from 'react-router-dom'

import { LoadingState, ErrorState } from '../../../../providers/app/states'
import { getSupabaseClient } from '../../../../services/supabase/client'
import { toText } from '../../../../lib/to-text'

type TenantRow = { id: string; name: string; slug: string; status: string; metadata: unknown }

export function TenantDetailPage() {
  const { tenantId } = useParams()

  const q = useQuery<TenantRow | null>({
    queryKey: ['foundation', 'tenants', 'detail', tenantId],
    enabled: Boolean(tenantId),
    queryFn: async () => {
      const supabase = getSupabaseClient()
      const res = await supabase
        .schema('foundation')
        .from('tenants')
        .select('id,name,slug,status,metadata')
        .eq('id', tenantId as string)
        .maybeSingle()
      if (res.error) throw res.error
      return (res.data as TenantRow | null) ?? null
    },
  })

  if (q.isLoading) return <LoadingState />
  if (q.isError) return <ErrorState details={q.error instanceof Error ? q.error.message : 'tenant_error'} />
  if (!q.data) return <ErrorState title="Tenant not found" body="No tenant matched this id." />

  return (
    <div>
      <h1>{toText(q.data.name)}</h1>
      <p>Slug: {toText(q.data.slug)}</p>
      <p>Status: {toText(q.data.status)}</p>
      <h3>Metadata</h3>
      <pre style={{ whiteSpace: 'pre-wrap', fontSize: 12 }}>
        {toText(JSON.stringify(q.data.metadata, null, 2))}
      </pre>
    </div>
  )
}

