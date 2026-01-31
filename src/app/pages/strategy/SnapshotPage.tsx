import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'

import { LoadingState, ErrorState } from '../../../components/states'
import { getSupabaseClient } from '../../../services/supabase/client'
import { toText } from '../../../lib/to-text'
import { useTenant } from '../../../providers/tenant/TenantProvider'

type SnapshotRow = {
  tenant_id: string
  cycle_id: string
  objectives_total: number
  objectives_active: number
  objectives_completed: number
  initiatives_total: number
  initiatives_active: number
  updated_at_max: string | null
}

export function SnapshotPage() {
  const { tenantId } = useTenant()

  const cycleQ = useQuery({
    queryKey: ['strategy', 'cycles', tenantId],
    queryFn: async () => {
      if (!tenantId) throw new Error('tenant_required')
      const supabase = getSupabaseClient()
      const { data, error } = await supabase.schema('strategy').rpc('list_cycles', { p_tenant_id: tenantId, p_limit: 1 })
      if (error) throw error
      const rows = (data as { cycle_id: string }[]) ?? []
      return rows[0]?.cycle_id ?? null
    },
    enabled: !!tenantId,
  })

  const snapshotQ = useQuery<SnapshotRow[]>({
    queryKey: ['strategy', 'snapshot', tenantId, cycleQ.data],
    queryFn: async () => {
      if (!tenantId || !cycleQ.data) throw new Error('tenant_or_cycle_required')
      const supabase = getSupabaseClient()
      const { data, error } = await supabase.schema('strategy').rpc('get_portfolio_snapshot_full', { p_tenant_id: tenantId, p_cycle_id: cycleQ.data })
      if (error) throw error
      return (data as SnapshotRow[]) ?? []
    },
    enabled: !!tenantId && !!cycleQ.data,
  })

  if (cycleQ.isLoading || snapshotQ.isLoading) return <LoadingState testid="state-loading-snapshot" />
  if (cycleQ.isError)
    return <ErrorState testid="state-error-cycles" actions={<pre>{toText(cycleQ.error instanceof Error ? cycleQ.error.message : '')}</pre>} />
  if (snapshotQ.isError)
    return <ErrorState testid="state-error-snapshot" actions={<pre>{toText(snapshotQ.error instanceof Error ? snapshotQ.error.message : '')}</pre>} />

  const s = snapshotQ.data?.[0]
  if (!s) return <p>No snapshot for this cycle.</p>

  return (
    <div>
      <h1>Portfolio Snapshot</h1>
      <table>
        <tbody>
          <tr><td>Objectives total</td><td>{toText(s.objectives_total)}</td></tr>
          <tr><td>Objectives active</td><td>{toText(s.objectives_active)}</td></tr>
          <tr><td>Objectives completed</td><td>{toText(s.objectives_completed)}</td></tr>
          <tr><td>Initiatives total</td><td>{toText(s.initiatives_total)}</td></tr>
          <tr><td>Initiatives active</td><td>{toText(s.initiatives_active)}</td></tr>
          <tr><td>Updated at</td><td>{toText(s.updated_at_max)}</td></tr>
        </tbody>
      </table>
      <p><Link to="/strategy">Back to Strategy</Link></p>
    </div>
  )
}
