/**
 * HUMANTRÍA — ErrorState Component
 */

import { ReactNode } from 'react'
import { Button } from './Button'
import './ErrorState.css'

interface ErrorStateProps {
  title?: string
  message: string
  onRetry?: () => void
  className?: string
}

export function ErrorState({ title = 'Erro', message, onRetry, className = '' }: ErrorStateProps) {
  return (
    <div className={`ds-error-state ${className}`}>
      <div className="ds-error-state-icon">⚠</div>
      <h3 className="ds-error-state-title">{title}</h3>
      <p className="ds-error-state-message">{message}</p>
      {onRetry && (
        <Button onClick={onRetry} variant="primary">
          Tentar novamente
        </Button>
      )}
    </div>
  )
}
