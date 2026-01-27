import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'

import { LoadingState, EmptyState, ErrorState } from '../../../../providers/app/states'
import { getSupabaseClient } from '../../../../services/supabase/client'
import { toText } from '../../../../lib/to-text'

type TenantRow = { id: string; name: string; slug: string; status: string }

export function TenantsListPage() {
  const q = useQuery<TenantRow[]>({
    queryKey: ['foundation', 'tenants', 'list'],
    queryFn: async () => {
      const supabase = getSupabaseClient()
      const res = await supabase.schema('foundation').from('tenants').select('id,name,slug,status').order('created_at', { ascending: false })
      if (res.error) throw res.error
      return (res.data as TenantRow[]) ?? []
    },
  })

  if (q.isLoading) return <LoadingState />
  if (q.isError) return <ErrorState details={q.error instanceof Error ? q.error.message : 'tenants_error'} />

  const rows = q.data ?? []
  if (rows.length === 0) return <EmptyState />

  return (
    <div>
      <h1>Tenants</h1>
      <ul>
        {rows.map((t) => (
          <li key={t.id}>
            <Link to={`/foundation/tenants/${encodeURIComponent(t.id)}`}>{toText(t.name)}</Link>{' '}
            <span style={{ opacity: 0.7 }}>({toText(t.slug)} / {toText(t.status)})</span>
          </li>
        ))}
      </ul>
    </div>
  )
}

