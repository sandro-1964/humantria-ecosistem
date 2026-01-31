import type { ReactNode } from 'react'
import { Link } from 'react-router-dom'

type Props = {
  to: string
  title: string
  description?: string
  icon?: ReactNode
}

export function NavCard({ to, title, description, icon }: Props) {
  return (
    <Link to={to} className="ds-nav-card">
      {icon && <div className="ds-nav-card__icon">{icon}</div>}
      <div className="ds-nav-card__body">
        <h3 className="ds-nav-card__title">{title}</h3>
        {description && <p className="ds-nav-card__desc">{description}</p>}
      </div>
    </Link>
  )
}
