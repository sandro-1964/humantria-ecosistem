import { useQuery } from '@tanstack/react-query'
import { Link, useParams } from 'react-router-dom'

import { LoadingState, ErrorState } from '../../../../components/states'
import { getSupabaseClient } from '../../../../services/supabase/client'
import { toText } from '../../../../lib/to-text'
import { useTenant } from '../../../../providers/tenant/TenantProvider'
import { PageLayout, Card, Badge, Button } from '../../../../design-system/components'

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
    <PageLayout
      title={toText(obj.title)}
      actions={
        <>
          {canApprove && (
            <Link to={`/strategy/objectives/${id}/approve`}>
              <Button>Approve</Button>
            </Link>
          )}
          <Link to="/strategy/objectives">
            <Button variant="secondary">Back to objectives</Button>
          </Link>
        </>
      }
    >
      <Card title="Details">
        <p style={{ margin: '0 0 0.5rem 0' }}>
          Code: {toText(obj.code)} | Status: <Badge variant={obj.status === 'active' ? 'success' : obj.status === 'completed' ? 'info' : 'default'}>{toText(obj.status)}</Badge>
        </p>
        {obj.description && <p style={{ margin: 0 }}>{toText(obj.description)}</p>}
      </Card>
      <div style={{ marginTop: '1rem' }}>
      <Card title="Initiatives">
        {initQ.isLoading ? (
          <LoadingState testid="state-loading-initiatives" />
        ) : initiatives.length === 0 ? (
          <p style={{ margin: 0 }}>No initiatives.</p>
        ) : (
          <ul style={{ margin: 0, paddingLeft: '1.25rem' }}>
            {initiatives.map((i) => (
              <li key={i.id} style={{ marginBottom: '0.25rem' }}>
                <Link to={`/strategy/initiatives/${encodeURIComponent(i.id)}`}>{toText(i.title)}</Link> (<Badge variant="default">{toText(i.status)}</Badge>)
              </li>
            ))}
          </ul>
        )}
      </Card>
      </div>
    </PageLayout>
  )
}
