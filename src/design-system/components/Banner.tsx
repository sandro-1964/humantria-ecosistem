/**
 * HUMANTRÍA — Banner/Alert Component
 */

import { ReactNode } from 'react'
import './Banner.css'

interface BannerProps {
  children: ReactNode
  variant?: 'success' | 'warning' | 'error' | 'info'
  onClose?: () => void
  className?: string
}

export function Banner({ children, variant = 'info', onClose, className = '' }: BannerProps) {
  return (
    <div className={`ds-banner ds-banner--${variant} ${className}`} role="alert">
      <div className="ds-banner-content">{children}</div>
      {onClose && (
        <button
          type="button"
          className="ds-banner-close"
          onClick={onClose}
          aria-label="Fechar"
        >
          ×
        </button>
      )}
    </div>
  )
}
