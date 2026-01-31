import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'

import { LoadingState, EmptyState, ErrorState } from '../../../../components/states'
import { getSupabaseClient } from '../../../../services/supabase/client'
import { toText } from '../../../../lib/to-text'
import { useTenant } from '../../../../providers/tenant/TenantProvider'
import { PageLayout, Button, Table } from '../../../../design-system/components'

type ObjectiveRow = { id: string; code: string; title: string; status: string; cycle_id: string }

export function ObjectivesListPage() {
  const { tenantId } = useTenant()

  const q = useQuery<ObjectiveRow[]>({
    queryKey: ['strategy', 'objectives', tenantId ?? ''],
    queryFn: async () => {
      if (!tenantId) throw new Error('tenant_required')
      const supabase = getSupabaseClient()
      const { data, error } = await supabase.schema('strategy').rpc('list_objectives', { p_tenant_id: tenantId, p_limit: 50 })
      if (error) throw error
      return (data as ObjectiveRow[]) ?? []
    },
    enabled: !!tenantId,
  })

  if (q.isLoading) return <LoadingState testid="state-loading-objectives" />
  if (q.isError)
    return (
      <ErrorState
        testid="state-error-objectives"
        actions={<pre style={{ whiteSpace: 'pre-wrap', fontSize: 12, opacity: 0.85 }}>{toText(q.error instanceof Error ? q.error.message : 'objectives_error')}</pre>}
      />
    )

  const rows = q.data ?? []
  if (rows.length === 0) return <EmptyState testid="state-empty-objectives" />

  return (
    <PageLayout
      title="Objectives"
      actions={
        <Link to="/strategy/objectives/new">
          <Button>New objective</Button>
        </Link>
      }
    >
      <Table<ObjectiveRow>
        columns={[
          { key: 'title', header: 'Title', render: (o) => <Link to={`/strategy/objectives/${encodeURIComponent(o.id)}`}>{toText(o.title)}</Link> },
          { key: 'code', header: 'Code', render: (o) => toText(o.code) },
          { key: 'status', header: 'Status', render: (o) => toText(o.status) },
        ]}
        rows={rows}
        getRowKey={(o) => o.id}
      />
    </PageLayout>
  )
}
