import { useQuery } from '@tanstack/react-query'
import { Link, useParams } from 'react-router-dom'

import { LoadingState, ErrorState } from '../../../../components/states'
import { getSupabaseClient } from '../../../../services/supabase/client'
import { toText } from '../../../../lib/to-text'
import { useTenant } from '../../../../providers/tenant/TenantProvider'

type ObjectiveRow = { id: string; code: string; title: string; description: string | null; status: string }
type InitiativeRow = { id: string; code: string; title: string; status: string }

export function ObjectiveDetailPage() {
  const { tenantId } = useTenant()
  const { id } = useParams<{ id: string }>()

  const objQ = useQuery<ObjectiveRow[]>({
    queryKey: ['strategy', 'objective', id, tenantId],
    queryFn: async () => {
      if (!tenantId || !id) throw new Error('tenant_or_id_required')
      const supabase = getSupabaseClient()
      const { data, error } = await supabase.schema('strategy').rpc('list_objectives', { p_tenant_id: tenantId, p_limit: 200 })
      if (error) throw error
      const rows = (data as (ObjectiveRow & { id: string })[]) ?? []
      return rows.filter((r) => r.id === id)
    },
    enabled: !!tenantId && !!id,
  })

  const initQ = useQuery<InitiativeRow[]>({
    queryKey: ['strategy', 'initiatives', id, tenantId],
    queryFn: async () => {
      if (!tenantId || !id) throw new Error('tenant_or_id_required')
      const supabase = getSupabaseClient()
      const { data, error } = await supabase.schema('strategy').rpc('list_initiatives_full', { p_tenant_id: tenantId, p_objective_id: id, p_limit: 50 })
      if (error) throw error
      return (data as InitiativeRow[]) ?? []
    },
    enabled: !!tenantId && !!id,
  })

  if (objQ.isLoading) return <LoadingState testid="state-loading-objective" />
  if (objQ.isError)
    return <ErrorState testid="state-error-objective" actions={<pre>{toText(objQ.error instanceof Error ? objQ.error.message : '')}</pre>} />

  const obj = objQ.data?.[0]
  if (!obj) return <ErrorState testid="state-not-found-objective" />

  const initiatives = initQ.data ?? []
  const canApprove = obj.status === 'draft'

  return (
    <div>
      <h1>{toText(obj.title)}</h1>
      <p>Code: {toText(obj.code)} | Status: {toText(obj.status)}</p>
      {obj.description && <p>{toText(obj.description)}</p>}
      {canApprove && (
        <p>
          <Link to={`/strategy/objectives/${id}/approve`}>Approve</Link>
        </p>
      )}
      <h2>Initiatives</h2>
      {initQ.isLoading ? (
        <LoadingState testid="state-loading-initiatives" />
      ) : (
        <ul>
          {initiatives.map((i) => (
            <li key={i.id}>
              <Link to={`/strategy/initiatives/${encodeURIComponent(i.id)}`}>{toText(i.title)}</Link> ({toText(i.status)})
            </li>
          ))}
        </ul>
      )}
      <p>
        <Link to="/strategy/objectives">Back to objectives</Link>
      </p>
    </div>
  )
}
