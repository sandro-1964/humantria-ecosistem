import { useQuery } from '@tanstack/react-query'

import { LoadingState, EmptyState, ErrorState } from '../../../../providers/app/states'
import { useTenant } from '../../../../providers/tenant/TenantProvider'
import { getSupabaseClient } from '../../../../services/supabase/client'
import { toText } from '../../../../lib/to-text'

type AssignmentRow = {
  user_id: string
  role_id: string
  assigned_at: string
}

export function UsersAndRolesPage() {
  const tenant = useTenant()

  const q = useQuery<AssignmentRow[]>({
    queryKey: ['foundation', 'user_role_assignments', tenant.tenantId],
    enabled: Boolean(tenant.tenantId),
    queryFn: async () => {
      const supabase = getSupabaseClient()
      const res = await supabase
        .schema('foundation')
        .from('user_role_assignments')
        .select('user_id,role_id,assigned_at')
        .eq('tenant_id', tenant.tenantId as string)
        .order('assigned_at', { ascending: false })
      if (res.error) throw res.error
      return (res.data as AssignmentRow[]) ?? []
    },
  })

  if (q.isLoading) return <LoadingState />
  if (q.isError) return <ErrorState details={q.error instanceof Error ? q.error.message : 'roles_error'} />

  const rows = q.data ?? []
  if (rows.length === 0) return <EmptyState />

  return (
    <div>
      <h1>Users & Roles</h1>
      <p style={{ opacity: 0.8 }}>
        V1: esta tela lista atribuições. A UI de atribuição/revogação entra como patch futuro (mantendo RLS).
      </p>
      <ul>
        {rows.map((r) => (
          <li key={`${r.user_id}-${r.role_id}-${r.assigned_at}`}>
            user_id={toText(r.user_id)} role_id={toText(r.role_id)} assigned_at={toText(r.assigned_at)}
          </li>
        ))}
      </ul>
    </div>
  )
}

