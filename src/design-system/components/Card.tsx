import type { ReactNode } from 'react'

type Props = {
  title?: string
  children: ReactNode
  footer?: ReactNode
}

export function Card({ title, children, footer }: Props) {
  return (
    <div className="ds-card">
      {title && <div className="ds-card__header">{title}</div>}
      <div className="ds-card__content">{children}</div>
      {footer && <div className="ds-card__footer">{footer}</div>}
    </div>
  )
}
