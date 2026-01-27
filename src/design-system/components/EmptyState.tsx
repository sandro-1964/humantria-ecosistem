/**
 * HUMANTRÍA — EmptyState Component
 */

import { ReactNode } from 'react'
import { Button } from './Button'
import './EmptyState.css'

interface EmptyStateProps {
  title: string
  description?: string
  action?: {
    label: string
    onClick: () => void
  }
  icon?: ReactNode
  className?: string
}

export function EmptyState({ title, description, action, icon, className = '' }: EmptyStateProps) {
  return (
    <div className={`ds-empty-state ${className}`}>
      {icon && <div className="ds-empty-state-icon">{icon}</div>}
      <h3 className="ds-empty-state-title">{title}</h3>
      {description && <p className="ds-empty-state-description">{description}</p>}
      {action && (
        <Button onClick={action.onClick} variant="primary">
          {action.label}
        </Button>
      )}
    </div>
  )
}
