/**
 * Strategy Home — página real /strategy (Etapa 2).
 * Fallback canônico: layout mínimo sem puxar o kit Lovable (entrada controlada).
 * UI Contract: dados exibidos via toText/renderValue; sem objetos crus.
 */
import { Link } from 'react-router-dom'

export default function StrategyHomePage() {
  return (
    <div data-testid="strategy-home-page" style={{ padding: 24, fontFamily: 'Inter, system-ui', maxWidth: 640 }}>
      <h1>Strategy</h1>
      <p>Home — plataforma Humantría</p>
      <div style={{ marginTop: 16, padding: 16, border: '1px solid #e2e8f0', borderRadius: 8 }}>
        <p style={{ margin: 0 }}>Página Strategy real. Router ativo.</p>
        <Link to="/__diag" style={{ display: 'inline-block', marginTop: 12, color: '#2563eb' }}>
          Ir para /__diag
        </Link>
      </div>
    </div>
  )
}
