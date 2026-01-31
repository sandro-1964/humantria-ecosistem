import type { ReactNode } from 'react'

type Props = {
  title: string
  actions?: ReactNode
  children: ReactNode
}

export function PageLayout({ title, actions, children }: Props) {
  return (
    <div className="ds-page">
      <header className="ds-page__header">
        <h1 className="ds-page__title">{title}</h1>
        {actions && <div className="ds-page__actions">{actions}</div>}
      </header>
      <div className="ds-page__body">{children}</div>
    </div>
  )
}
