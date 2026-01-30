import { useQuery } from '@tanstack/react-query'

import { LoadingState, EmptyState, ErrorState } from '../../../../components/states'
import { useTenant } from '../../../../providers/tenant/TenantProvider'
import { getSupabaseClient } from '../../../../services/supabase/client'
import { toText } from '../../../../lib/to-text'
import { useStubSafe } from '../../../../hooks/use-stub-safe'
import { StubPageLayout } from '../../../../components/stubs/StubPageLayout'

type AuditFunctionalRow = {
  id: string
  decision_type: string
  entity_type: string
  entity_id: string | null
  user_email: string | null
  justification: string | null
  created_at: string
}

const STUB_AUDIT: AuditFunctionalRow[] = [
  { id: 'audit-1', decision_type: 'ui.action', entity_type: 'tenant_settings', entity_id: null, user_email: 'demo+admin@humantria.local', justification: 'Stub entry', created_at: '2026-01-29T12:00:00Z' },
  { id: 'audit-2', decision_type: 'audit.read', entity_type: 'audit_log', entity_id: 'audit-1', user_email: 'demo+auditor@humantria.local', justification: 'Compliance view', created_at: '2026-01-29T11:00:00Z' },
  { id: 'audit-3', decision_type: 'ui.action', entity_type: 'user_role_assignments', entity_id: 'user_1', user_email: 'demo+admin@humantria.local', justification: 'Role assigned', created_at: '2026-01-28T10:00:00Z' },
]

export function AuditTimelinePage() {
  const tenant = useTenant()
  const stubSafe = useStubSafe()

  const q = useQuery<AuditFunctionalRow[]>({
    queryKey: ['foundation', 'audit_log_functional', tenant.tenantId],
    enabled: Boolean(tenant.tenantId) && !stubSafe,
    queryFn: async () => {
      const supabase = getSupabaseClient()
      const res = await supabase
        .schema('foundation')
        .from('audit_log_functional')
        .select('id,decision_type,entity_type,entity_id,user_email,justification,created_at')
        .eq('tenant_id', tenant.tenantId as string)
        .order('created_at', { ascending: false })
        .limit(50)
      if (res.error) throw res.error
      return (res.data as AuditFunctionalRow[]) ?? []
    },
  })

  if (stubSafe) {
    return (
      <StubPageLayout
        title="Audit Timeline"
        expectedItems={['id', 'decision_type', 'entity_type', 'entity_id', 'user_email', 'justification', 'created_at', 'Somente leitura (compliance)']}
        fakeList={
          <ul>
            {STUB_AUDIT.map((r) => (
              <li key={r.id} style={{ marginBottom: 8 }}>
                <div>
                  <strong>{toText(r.decision_type)}</strong> — {toText(r.entity_type)}{' '}
                  <span style={{ opacity: 0.7 }}>{toText(r.entity_id ?? '')}</span>
                </div>
                <div style={{ fontSize: 12, opacity: 0.8 }}>
                  {toText(r.user_email ?? '')} · {toText(r.created_at)}
                </div>
                {r.justification ? <div>{toText(r.justification)}</div> : null}
              </li>
            ))}
          </ul>
        }
        readOnly={true}
      />
    )
  }

  if (q.isLoading) return <LoadingState testid="state-loading-audit" />
  if (q.isError)
    return (
      <ErrorState
        testid="state-error-audit"
        actions={
          <pre style={{ whiteSpace: 'pre-wrap', fontSize: 12, opacity: 0.85 }}>
            {toText(q.error instanceof Error ? q.error.message : 'audit_error')}
          </pre>
        }
      />
    )

  const rows = q.data ?? []
  if (rows.length === 0)
    return (
      <EmptyState
        testid="state-empty-audit"
        title="No audit entries"
        message="Nenhuma entrada encontrada para este tenant."
      />
    )

  return (
    <div>
      <h1>Audit Timeline</h1>
      <ul>
        {rows.map((r) => (
          <li key={r.id} style={{ marginBottom: 8 }}>
            <div>
              <strong>{toText(r.decision_type)}</strong> — {toText(r.entity_type)}{' '}
              <span style={{ opacity: 0.7 }}>{toText(r.entity_id ?? '')}</span>
            </div>
            <div style={{ fontSize: 12, opacity: 0.8 }}>
              {toText(r.user_email ?? '')} · {toText(r.created_at)}
            </div>
            {r.justification ? <div>{toText(r.justification)}</div> : null}
          </li>
        ))}
      </ul>
    </div>
  )
}

