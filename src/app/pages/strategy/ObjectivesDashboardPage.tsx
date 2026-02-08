/**
 * Strategy Dashboard — KPI + tabela de objectives (GS UI V2.2).
 * Usa tenant context canônico: set_current_tenant_id + objectives_list_for_tenant (RLS).
 */
import { useEffect, useState } from 'react'
import { TENANT_TARGET, setTenantContext, fetchObjectivesForTenant } from '../../../lib/auth'
import { toText } from '../../ui_contract/toText'

type ObjectiveRow = {
  id: string
  tenant_id: string
  code: string | null
  title: string | null
  description: string | null
  status: string | null
  methodology_type: string | null
  cycle_type: string | null
  cycle_start_date: string | null
  cycle_end_date: string | null
  created_at: string | null
  [key: string]: unknown
}

export default function ObjectivesDashboardPage() {
  const [tenantStatus, setTenantStatus] = useState<'idle' | 'ok' | 'error'>('idle')
  const [tenantError, setTenantError] = useState<string | null>(null)
  const [rows, setRows] = useState<ObjectiveRow[]>([])
  const [loading, setLoading] = useState(true)
  const [fetchError, setFetchError] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false
    setLoading(true)
    setTenantStatus('idle')
    setTenantError(null)
    setFetchError(null)

    ;(async () => {
      const r = await setTenantContext(TENANT_TARGET)
      if (cancelled) return
      if (r.ok) setTenantStatus('ok')
      else {
        setTenantStatus('error')
        setTenantError(r.error ?? 'unknown')
      }

      try {
        const data = await fetchObjectivesForTenant(TENANT_TARGET)
        if (cancelled) return
        setRows(Array.isArray(data) ? data : [])
      } catch (e) {
        if (!cancelled) setFetchError(e instanceof Error ? e.message : String(e))
      } finally {
        if (!cancelled) setLoading(false)
      }
    })()

    return () => { cancelled = true }
  }, [])

  return (
    <div data-testid="objectives-dashboard" style={{ padding: 24, fontFamily: 'Inter, system-ui' }}>
      <h1>Strategy — Objectives</h1>
      <p>Tenant context: {TENANT_TARGET}</p>
      <p>RPC set_current_tenant_id: {tenantStatus === 'ok' ? 'ok' : tenantStatus === 'error' ? `erro: ${tenantError}` : 'idle'}</p>
      {loading && <p>Carregando…</p>}
      {fetchError && <p style={{ color: 'red' }}>Erro ao carregar: {toText(fetchError)}</p>}
      {!loading && !fetchError && (
        <>
          <p><strong>Visíveis (RLS):</strong> {rows.length} linhas</p>
          <table border={1} cellPadding={8} style={{ borderCollapse: 'collapse', width: '100%' }}>
            <thead>
              <tr>
                <th>code</th>
                <th>title</th>
                <th>status</th>
                <th>methodology_type</th>
                <th>cycle_start_date</th>
                <th>cycle_end_date</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((row) => (
                <tr key={row.id}>
                  <td>{toText(row.code)}</td>
                  <td>{toText(row.title)}</td>
                  <td>{toText(row.status)}</td>
                  <td>{toText(row.methodology_type)}</td>
                  <td>{toText(row.cycle_start_date)}</td>
                  <td>{toText(row.cycle_end_date)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </>
      )}
    </div>
  )
}
