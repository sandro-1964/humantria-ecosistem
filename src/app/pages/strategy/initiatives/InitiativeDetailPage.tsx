import { useQuery } from '@tanstack/react-query'
import { Link, useParams } from 'react-router-dom'

import { LoadingState, ErrorState } from '../../../../components/states'
import { getSupabaseClient } from '../../../../services/supabase/client'
import { toText } from '../../../../lib/to-text'
import { useTenant } from '../../../../providers/tenant/TenantProvider'
import { PageLayout, Card, Badge, Button } from '../../../../design-system/components'

type InitiativeRow = { id: string; code: string; title: string; description: string | null; status: string; objective_id: string }

export function InitiativeDetailPage() {
  const { tenantId } = useTenant()
  const { id } = useParams<{ id: string }>()

  const q = useQuery<InitiativeRow[]>({
    queryKey: ['strategy', 'initiative', id, tenantId],
    queryFn: async () => {
      if (!tenantId || !id) throw new Error('tenant_or_id_required')
      const supabase = getSupabaseClient()
      const { data, error } = await supabase.schema('strategy').rpc('list_initiatives_full', { p_tenant_id: tenantId, p_limit: 200 })
      if (error) throw error
      const rows = (data as (InitiativeRow & { id: string })[]) ?? []
      return rows.filter((r) => r.id === id)
    },
    enabled: !!tenantId && !!id,
  })

  if (q.isLoading) return <LoadingState testid="state-loading-initiative" />
  if (q.isError)
    return <ErrorState testid="state-error-initiative" actions={<pre>{toText(q.error instanceof Error ? q.error.message : '')}</pre>} />

  const i = q.data?.[0]
  if (!i) return <ErrorState testid="state-not-found-initiative" />

  return (
    <PageLayout
      title={toText(i.title)}
      actions={
        <Link to="/strategy/initiatives">
          <Button variant="secondary">Back to initiatives</Button>
        </Link>
      }
    >
      <Card title="Details">
        <p style={{ margin: '0 0 0.5rem 0' }}>
          Code: {toText(i.code)} | Status: <Badge variant={i.status === 'active' ? 'success' : i.status === 'completed' ? 'info' : 'default'}>{toText(i.status)}</Badge>
        </p>
        {i.description && <p style={{ margin: 0 }}>{toText(i.description)}</p>}
      </Card>
    </PageLayout>
  )
}
