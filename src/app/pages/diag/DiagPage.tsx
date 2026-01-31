/**
 * Página de diagnóstico (05_ui_contract: rota /__diag obrigatória).
 * Build info mínimo: skeleton OK, route, timestamp.
 */
import { useLocation } from 'react-router-dom'

export default function DiagPage() {
  const location = useLocation()
  const timestamp = new Date().toISOString()

  return (
    <div data-testid="diag-page" style={{ padding: '1.5rem', fontFamily: 'system-ui' }}>
      <h1>Humantría UI skeleton OK</h1>
      <p><strong>Route:</strong> {location.pathname}</p>
      <p><strong>Timestamp:</strong> {timestamp}</p>
    </div>
  )
}
