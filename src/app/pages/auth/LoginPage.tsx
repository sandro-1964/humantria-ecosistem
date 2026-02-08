/**
 * Login — redireciona para /strategy após sucesso.
 * Usa Supabase Auth (anon key); não usa service_role.
 */
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../../../lib/supabase'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const navigate = useNavigate()

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError(null)
    const { error: err } = await supabase.auth.signInWithPassword({ email, password })
    setLoading(false)
    if (err) {
      setError(err.message)
      return
    }
    navigate('/strategy', { replace: true })
  }

  return (
    <div style={{ padding: 24, maxWidth: 400, margin: '0 auto', fontFamily: 'Inter, system-ui' }}>
      <h1>Login</h1>
      <form onSubmit={handleSubmit}>
        <div style={{ marginBottom: 12 }}>
          <label htmlFor="email">Email</label>
          <input
            id="email"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            style={{ display: 'block', width: '100%', padding: 8 }}
          />
        </div>
        <div style={{ marginBottom: 12 }}>
          <label htmlFor="password">Senha</label>
          <input
            id="password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            style={{ display: 'block', width: '100%', padding: 8 }}
          />
        </div>
        {error != null && <p style={{ color: 'red', marginBottom: 12 }}>{error}</p>}
        <button type="submit" disabled={loading} style={{ padding: '8px 16px' }}>
          {loading ? 'Entrando…' : 'Entrar'}
        </button>
      </form>
    </div>
  )
}
