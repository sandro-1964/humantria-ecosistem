import { useQuery } from '@tanstack/react-query'

import { LoadingState, EmptyState, ErrorState } from '../../../../providers/app/states'
import { useTenant } from '../../../../providers/tenant/TenantProvider'
import { getSupabaseClient } from '../../../../services/supabase/client'
import { toText } from '../../../../lib/to-text'
import { useStubSafe } from '../../../../hooks/use-stub-safe'
import { StubPageLayout } from '../../../../components/stubs/StubPageLayout'

type AssignmentRow = {
  user_id: string
  role_id: string
  assigned_at: string
}

const STUB_ASSIGNMENTS: AssignmentRow[] = [
  { user_id: 'user_demo_admin', role_id: 'role_tenant_admin', assigned_at: '2026-01-01T00:00:00Z' },
  { user_id: 'user_analyst_1', role_id: 'role_analyst', assigned_at: '2026-01-15T00:00:00Z' },
  { user_id: 'user_auditor_1', role_id: 'role_auditor', assigned_at: '2026-01-20T00:00:00Z' },
]

export function UsersAndRolesPage() {
  const tenant = useTenant()
  const stubSafe = useStubSafe()

  const q = useQuery<AssignmentRow[]>({
    queryKey: ['foundation', 'user_role_assignments', tenant.tenantId],
    enabled: Boolean(tenant.tenantId) && !stubSafe,
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

  if (stubSafe) {
    return (
      <StubPageLayout
        title="Users & Roles"
        expectedItems={['user_id', 'role_id', 'tenant_id', 'assigned_at', 'CRUD: listar, atribuir, revogar (tenant_admin)']}
        fakeList={
          <ul>
            {STUB_ASSIGNMENTS.map((r) => (
              <li key={`${r.user_id}-${r.role_id}-${r.assigned_at}`}>
                user_id={toText(r.user_id)} role_id={toText(r.role_id)} assigned_at={toText(r.assigned_at)}
              </li>
            ))}
          </ul>
        }
      />
    )
  }

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

