import type { ReactNode } from 'react'

import { toText } from '../../lib/to-text'
import { LoadingState as V1LoadingState } from '../../components/states/LoadingState'
import { EmptyState as V1EmptyState } from '../../components/states/EmptyState'
import { ErrorState as V1ErrorState } from '../../components/states/ErrorState'
import { AccessDeniedState as V1AccessDeniedState } from '../../components/states/AccessDeniedState'

export function LoadingState({ title, body }: { title?: string; body?: string }) {
  return <V1LoadingState title={toText(title)} message={toText(body)} />
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
  return <V1EmptyState title={toText(title)} message={toText(body)} actions={actions} />
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
  return (
    <V1ErrorState
      title={toText(title)}
      message={toText(body)}
      actions={
        details ? (
          <pre style={{ whiteSpace: 'pre-wrap', fontSize: 12, opacity: 0.85 }}>
            {toText(details)}
          </pre>
        ) : null
      }
    />
  )
}

export function AccessDeniedState({ reason }: { reason?: string }) {
  return <V1AccessDeniedState message={toText(reason)} />
}

