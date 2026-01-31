import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'

import { LoadingState, EmptyState, ErrorState } from '../../../../components/states'
import { getSupabaseClient } from '../../../../services/supabase/client'
import { toText } from '../../../../lib/to-text'
import { useTenant } from '../../../../providers/tenant/TenantProvider'
import { PageLayout, Button, Table } from '../../../../design-system/components'

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
    <PageLayout
      title="Initiatives"
      actions={
        <Link to="/strategy/initiatives/new">
          <Button>New initiative</Button>
        </Link>
      }
    >
      <Table<InitiativeRow>
        columns={[
          { key: 'title', header: 'Title', render: (i) => <Link to={`/strategy/initiatives/${encodeURIComponent(i.id)}`}>{toText(i.title)}</Link> },
          { key: 'code', header: 'Code', render: (i) => toText(i.code) },
          { key: 'status', header: 'Status', render: (i) => toText(i.status) },
        ]}
        rows={rows}
        getRowKey={(i) => i.id}
      />
    </PageLayout>
  )
}
