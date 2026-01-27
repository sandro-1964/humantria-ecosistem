/**
 * HUMANTRÍA — Toast Component
 */

import { ReactNode, useEffect } from 'react'
import './Toast.css'

interface ToastProps {
  message: string
  variant?: 'success' | 'error' | 'warning' | 'info'
  onClose?: () => void
  duration?: number
}

export function Toast({ message, variant = 'info', onClose, duration = 5000 }: ToastProps) {
  useEffect(() => {
    if (duration > 0 && onClose) {
      const timer = setTimeout(onClose, duration)
      return () => clearTimeout(timer)
    }
  }, [duration, onClose])

  return (
    <div className={`ds-toast ds-toast--${variant}`} role="alert">
      <span className="ds-toast-message">{message}</span>
      {onClose && (
        <button
          type="button"
          className="ds-toast-close"
          onClick={onClose}
          aria-label="Fechar"
        >
          ×
        </button>
      )}
    </div>
  )
}
