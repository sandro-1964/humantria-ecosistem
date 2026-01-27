/**
 * HUMANTRÍA — Card Component
 */

import { ReactNode } from 'react'
import './Card.css'

interface CardProps {
  title?: string
  children: ReactNode
  actions?: ReactNode
  className?: string
}

export function Card({ title, children, actions, className = '' }: CardProps) {
  return (
    <div className={`ds-card ${className}`}>
      {(title || actions) && (
        <div className="ds-card-header">
          {title && <h3 className="ds-card-title">{title}</h3>}
          {actions && <div className="ds-card-actions">{actions}</div>}
        </div>
      )}
      <div className="ds-card-content">{children}</div>
    </div>
  )
}
