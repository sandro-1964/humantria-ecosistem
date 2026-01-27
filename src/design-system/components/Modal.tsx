/**
 * HUMANTRÍA — Modal Component
 */

import { ReactNode, useEffect } from 'react'
import './Modal.css'

interface ModalProps {
  isOpen: boolean
  onClose: () => void
  title?: string
  children: ReactNode
  size?: 'sm' | 'md' | 'lg' | 'xl'
  className?: string
}

export function Modal({ isOpen, onClose, title, children, size = 'md', className = '' }: ModalProps) {
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden'
    } else {
      document.body.style.overflow = ''
    }
    return () => {
      document.body.style.overflow = ''
    }
  }, [isOpen])

  if (!isOpen) return null

  return (
    <>
      <div className="ds-modal-backdrop" onClick={onClose} />
      <div className={`ds-modal ds-modal--${size} ${className}`} role="dialog" aria-modal="true">
        {title && (
          <div className="ds-modal-header">
            <h2 className="ds-modal-title">{title}</h2>
            <button
              type="button"
              className="ds-modal-close"
              onClick={onClose}
              aria-label="Fechar"
            >
              ×
            </button>
          </div>
        )}
        <div className="ds-modal-content">{children}</div>
      </div>
    </>
  )
}
