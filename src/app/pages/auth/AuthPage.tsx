import { useTranslation } from 'react-i18next'

import { ErrorState } from '../../../providers/app/states'
import { toText } from '../../../lib/to-text'

export function AuthPage() {
  const { t } = useTranslation()

  // V1: auth UI is intentionally minimal; relies on Supabase hosted auth or external flow.
  // If you need email/password later, implement it here with loading/empty/error.
  return (
    <div style={{ padding: 24 }}>
      <h1>{toText(t('auth.title'))}</h1>
      <p>Configure Supabase Auth e faça login. Depois retorne para o app.</p>
      <ErrorState
        title="Auth not configured"
        body="No fluxo V1, a UI de login é mínima. Se você esperava email/senha, habilite e implemente no AuthPage."
      />
    </div>
  )
}

