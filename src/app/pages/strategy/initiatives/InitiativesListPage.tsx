import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'

import { LoadingState, EmptyState, ErrorState } from '../../../../components/states'
import { getSupabaseClient } from '../../../../services/supabase/client'
import { toText } from '../../../../lib/to-text'
import { useTenant } from '../../../../providers/tenant/TenantProvider'

type InitiativeRow = { id: string; code: string; title: string; status: string; objective_id: string }

export function InitiativesListPage() {
  const { tenantId } = useTenant()

  const q = useQuery<InitiativeRow[]>({
    queryKey: ['strategy', 'initiatives', tenantId ?? ''],
    queryFn: async () => {
      if (!tenantId) throw new Error('tenant_required')
      const supabase = getSupabaseClient()
      const { data, error } = await supabase.schema('strategy').rpc('list_initiatives_full', { p_tenant_id: tenantId, p_limit: 50 })
      if (error) throw error
      return (data as InitiativeRow[]) ?? []
    },
    enabled: !!tenantId,
  })

  if (q.isLoading) return <LoadingState testid="state-loading-initiatives" />
  if (q.isError)
    return (
      <ErrorState
        testid="state-error-initiatives"
        actions={<pre style={{ whiteSpace: 'pre-wrap', fontSize: 12, opacity: 0.85 }}>{toText(q.error instanceof Error ? q.error.message : 'initiatives_error')}</pre>}
      />
    )

  const rows = q.data ?? []
  if (rows.length === 0) return <EmptyState testid="state-empty-initiatives" />

  return (
    <div>
      <h1>Initiatives</h1>
      <p>
        <Link to="/strategy/initiatives/new">New initiative</Link>
      </p>
      <ul>
        {rows.map((i) => (
          <li key={i.id}>
            <Link to={`/strategy/initiatives/${encodeURIComponent(i.id)}`}>{toText(i.title)}</Link>{' '}
            <span style={{ opacity: 0.7 }}>({toText(i.code)} / {toText(i.status)})</span>
          </li>
        ))}
      </ul>
    </div>
  )
}
