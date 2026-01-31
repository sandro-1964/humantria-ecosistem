import { useMutation, useQueryClient } from '@tanstack/react-query'
import { Link, useParams, useNavigate } from 'react-router-dom'

import { LoadingState, ErrorState } from '../../../../components/states'
import { getSupabaseClient } from '../../../../services/supabase/client'
import { toText } from '../../../../lib/to-text'
import { useTenant } from '../../../../providers/tenant/TenantProvider'

export function ObjectiveApprovePage() {
  const { tenantId } = useTenant()
  const { id } = useParams<{ id: string }>()
  const queryClient = useQueryClient()
  const navigate = useNavigate()

  const approve = useMutation({
    mutationFn: async () => {
      if (!tenantId || !id) throw new Error('tenant_or_id_required')
      const supabase = getSupabaseClient()
      const { error } = await supabase.schema('strategy').rpc('approve_objective', { p_tenant_id: tenantId, p_objective_id: id, p_justification: 'Aprovado via UI' })
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['strategy'] })
      navigate(`/strategy/objectives/${id}`)
    },
  })

  if (approve.isPending) return <LoadingState testid="state-approving" />
  if (approve.isError)
    return (
      <ErrorState
        testid="state-error-approve"
        actions={<pre>{toText(approve.error instanceof Error ? approve.error.message : '')}</pre>}
      />
    )

  return (
    <div>
      <h1>Approve Objective</h1>
      <p>Objective ID: {toText(id)}</p>
      <button onClick={() => approve.mutate()} disabled={approve.isPending}>
        Confirm Approve
      </button>
      <p><Link to={`/strategy/objectives/${id}`}>Cancel</Link></p>
    </div>
  )
}
