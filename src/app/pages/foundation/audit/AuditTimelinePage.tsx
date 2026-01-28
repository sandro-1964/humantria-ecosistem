import { useQuery } from '@tanstack/react-query'

import { LoadingState, EmptyState, ErrorState } from '../../../../components/states'
import { useTenant } from '../../../../providers/tenant/TenantProvider'
import { getSupabaseClient } from '../../../../services/supabase/client'
import { toText } from '../../../../lib/to-text'

type AuditFunctionalRow = {
  id: string
  decision_type: string
  entity_type: string
  entity_id: string | null
  user_email: string | null
  justification: string | null
  created_at: string
}

export function AuditTimelinePage() {
  const tenant = useTenant()

  const q = useQuery<AuditFunctionalRow[]>({
    queryKey: ['foundation', 'audit_log_functional', tenant.tenantId],
    enabled: Boolean(tenant.tenantId),
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

