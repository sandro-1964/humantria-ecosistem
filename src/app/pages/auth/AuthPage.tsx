import { useState } from 'react'
import { useTranslation } from 'react-i18next'

import { ErrorState, LoadingState } from '../../../providers/app/states'
import { toText } from '../../../lib/to-text'
import { getSupabaseClient } from '../../../services/supabase/client'

export function AuthPage() {
  const { t } = useTranslation()

  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [status, setStatus] = useState<'idle' | 'loading' | 'error'>('idle')
  const [error, setError] = useState<string | null>(null)

  async function signIn() {
    setStatus('loading')
    setError(null)
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

  if (status === 'loading') return <LoadingState title="Signing in" body="Authenticating with Supabase…" />

  return (
    <div style={{ padding: 24 }}>
      <h1>{toText(t('auth.title'))}</h1>

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
    </div>
  )
}

