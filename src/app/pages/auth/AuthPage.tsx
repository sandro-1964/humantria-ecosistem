import { useState } from 'react'
import { useTranslation } from 'react-i18next'

import { ErrorState, LoadingState } from '../../../providers/app/states'
import { toText } from '../../../lib/to-text'
import { getSupabaseClient, hasSupabaseEnv } from '../../../services/supabase/client'
import { useAuth } from '../../../providers/auth/AuthProvider'
import { startDemoWithRole, type DemoRole } from '../../../services/demo/demo-session'

const DEMO_ROLES: { value: DemoRole; label: string }[] = [
  { value: 'admin', label: 'Admin' },
  { value: 'manager', label: 'Gestor' },
  { value: 'analyst', label: 'Analista' },
  { value: 'auditor', label: 'Auditor' },
]

export function AuthPage() {
  const { t } = useTranslation()
  const auth = useAuth()

  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [status, setStatus] = useState<'idle' | 'loading' | 'error'>('idle')
  const [error, setError] = useState<string | null>(null)

  async function signIn() {
    setStatus('loading')
    setError(null)
    if (!hasSupabaseEnv()) {
      setStatus('error')
      setError('Supabase não configurado')
      return
    }
    try {
      const supabase = getSupabaseClient()
      const res = await supabase.auth.signInWithPassword({ email, password })
      if (res.error) throw res.error
      setStatus('idle')
    } catch (e) {
      setStatus('error')
      setError(e instanceof Error ? e.message : 'auth_error')
    }
  }

  function enterDemo(role: DemoRole = 'admin') {
    startDemoWithRole(role)
  }

  if (status === 'loading') return <LoadingState title="Signing in" body="Authenticating with Supabase…" />

  return (
    <div style={{ padding: 24 }}>
      <h1>{toText(t('auth.title'))}</h1>

      {auth.supabaseNotConfigured ? (
        <div
          style={{
            marginBottom: 16,
            padding: 12,
            background: 'rgba(255, 193, 7, 0.15)',
            border: '1px solid rgba(255, 193, 7, 0.5)',
            borderRadius: 8,
            fontSize: 14,
          }}
        >
          Supabase não configurado. Use DEMO abaixo ou configure VITE_SUPABASE_URL e VITE_SUPABASE_ANON_KEY no .env.
        </div>
      ) : null}

      <div style={{ display: 'grid', gap: 8, maxWidth: 360 }}>
        <label>
          {toText(t('auth.email'))}
          <input
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            type="email"
            autoComplete="email"
            style={{ width: '100%', padding: 8, borderRadius: 8 }}
          />
        </label>

        <label>
          {toText(t('auth.password'))}
          <input
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            type="password"
            autoComplete="current-password"
            style={{ width: '100%', padding: 8, borderRadius: 8 }}
          />
        </label>

        <button onClick={() => void signIn()} disabled={!email || !password}>
          {toText(t('auth.signIn'))}
        </button>
      </div>

      {status === 'error' ? <ErrorState title="Sign-in failed" details={error ?? undefined} /> : null}

      <div style={{ marginTop: 24, paddingTop: 24, borderTop: '1px solid rgba(0,0,0,0.1)' }}>
        <div style={{ fontSize: 12, opacity: 0.8, marginBottom: 8 }}>DEMO MODE (sem Supabase)</div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, alignItems: 'center' }}>
          <button
            type="button"
            onClick={() => enterDemo('admin')}
            style={{ padding: '8px 12px', borderRadius: 8, fontWeight: 600 }}
          >
            Entrar em DEMO
          </button>
          <span style={{ fontSize: 12, opacity: 0.7 }}>ou</span>
          <label style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <span style={{ fontSize: 12 }}>Escolher perfil DEMO:</span>
            <select
              defaultValue=""
              onChange={(e) => {
                const v = e.target.value as DemoRole
                if (v) enterDemo(v)
              }}
              style={{ padding: 6, borderRadius: 6 }}
            >
              <option value="" disabled>
                —
              </option>
              {DEMO_ROLES.map((r) => (
                <option key={r.value} value={r.value}>
                  {r.label}
                </option>
              ))}
            </select>
          </label>
        </div>
      </div>
    </div>
  )
}

