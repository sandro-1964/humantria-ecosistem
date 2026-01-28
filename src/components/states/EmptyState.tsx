import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'

import { toText } from '../../lib/to-text'

type Props = {
  title?: string
  message?: string
  actions?: ReactNode
  icon?: ReactNode
  testid?: string
}

export function EmptyState({ title, message, actions, icon, testid }: Props) {
  const { t } = useTranslation()

  return (
    <div data-testid={testid} style={{ padding: 24 }}>
      {icon ? <div style={{ marginBottom: 8 }}>{icon}</div> : null}
      <h2 style={{ margin: '0 0 8px 0' }}>{toText(title ?? t('states.emptyTitle'))}</h2>
      <p style={{ margin: '0 0 12px 0' }}>{toText(message ?? t('states.emptyBody'))}</p>
      {actions}
    </div>
  )
}

