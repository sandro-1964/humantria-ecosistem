import type { ReactNode } from 'react'
import { Link } from 'react-router-dom'
import { useTranslation } from 'react-i18next'

import { toText } from '../../lib/to-text'

export function LoadingState({ title, body }: { title?: string; body?: string }) {
  const { t } = useTranslation()
  return (
    <div style={{ padding: 24 }}>
      <h2>{toText(title ?? t('states.loadingTitle'))}</h2>
      <p>{toText(body ?? t('states.loadingBody'))}</p>
    </div>
  )
}

export function EmptyState({
  title,
  body,
  actions,
}: {
  title?: string
  body?: string
  actions?: ReactNode
}) {
  const { t } = useTranslation()
  return (
    <div style={{ padding: 24 }}>
      <h2>{toText(title ?? t('states.emptyTitle'))}</h2>
      <p>{toText(body ?? t('states.emptyBody'))}</p>
      {actions}
    </div>
  )
}

export function ErrorState({
  title,
  body,
  details,
}: {
  title?: string
  body?: string
  details?: string
}) {
  const { t } = useTranslation()
  return (
    <div style={{ padding: 24 }}>
      <h2>{toText(title ?? t('states.errorTitle'))}</h2>
      <p>{toText(body ?? t('states.errorBody'))}</p>
      <p>
        <Link to="/__diag">{toText(t('nav.diag'))}</Link>
      </p>
      {details ? (
        <pre style={{ whiteSpace: 'pre-wrap', fontSize: 12, opacity: 0.85 }}>
          {toText(details)}
        </pre>
      ) : null}
    </div>
  )
}

export function AccessDeniedState({ reason }: { reason?: string }) {
  return (
    <ErrorState
      title="Access denied"
      body={reason ?? 'You do not have access to this area.'}
    />
  )
}

