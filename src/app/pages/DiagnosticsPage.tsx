/**
 * Diagnostics page (05_ui_contract: /__diag obrigatória).
 * Exibe sessão (present/absent), user id, TENANT_TARGET e resultado do RPC set_current_tenant_id.
 */
import { useEffect, useState } from 'react'
import { getSession, TENANT_TARGET, setTenantContext } from '../../lib/auth'

export default function DiagnosticsPage() {
  const [sessionInfo, setSessionInfo] = useState<{ present: boolean; userId?: string } | null>(null)
  const [tenantRpc, setTenantRpc] = useState<{ status: 'idle' | 'ok' | 'error'; error?: string }>({ status: 'idle' })
  const fingerprint = typeof import.meta.env?.VITE_APP_FINGERPRINT === 'string'
    ? import.meta.env.VITE_APP_FINGERPRINT
    : undefined

  useEffect(() => {
    getSession().then(({ session }) => {
      setSessionInfo({
        present: !!session,
        userId: session?.user?.id,
      })
    })
  }, [])

  useEffect(() => {
    setTenantContext(TENANT_TARGET).then((r) => {
      setTenantRpc(r.ok ? { status: 'ok' } : { status: 'error', error: r.error })
    })
  }, [])

  return (
    <div data-testid="diagnostics-page" style={{ padding: 24, fontFamily: 'Inter, system-ui' }}>
      <h1>Diagnostics OK</h1>
      <p>Route: /__diag</p>
      <p>Timestamp: {new Date().toISOString()}</p>
      <p>
        Sessão: {sessionInfo == null ? '...' : sessionInfo.present ? 'present' : 'absent'}
        {sessionInfo?.userId != null && ` — User ID: ${sessionInfo.userId}`}
      </p>
      <p>TENANT_TARGET: {TENANT_TARGET}</p>
      <p>RPC set_current_tenant_id: {tenantRpc.status === 'ok' ? 'ok' : tenantRpc.status === 'error' ? `erro: ${tenantRpc.error ?? 'unknown'}` : 'idle'}</p>
      {fingerprint != null && <p>Build fingerprint: {fingerprint}</p>}
    </div>
  )
}
