/**
 * Diagnostics page (05_ui_contract: /__diag obrigatória).
 * Conteúdo simples: "Diagnostics OK" + fingerprint se existir.
 */
export default function DiagnosticsPage() {
  const fingerprint = typeof import.meta.env?.VITE_APP_FINGERPRINT === 'string'
    ? import.meta.env.VITE_APP_FINGERPRINT
    : undefined

  return (
    <div data-testid="diagnostics-page" style={{ padding: 24, fontFamily: 'Inter, system-ui' }}>
      <h1>Diagnostics OK</h1>
      <p>Route: /__diag</p>
      <p>Timestamp: {new Date().toISOString()}</p>
      {fingerprint != null && <p>Build fingerprint: {fingerprint}</p>}
    </div>
  )
}
