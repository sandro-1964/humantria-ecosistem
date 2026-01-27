/**
 * HUMANTRÍA — Drawer Component
 */

import { ReactNode, useEffect } from 'react'
import './Drawer.css'

interface DrawerProps {
  isOpen: boolean
  onClose: () => void
  title?: string
  children: ReactNode
  placement?: 'left' | 'right'
  className?: string
}

export function Drawer({
  isOpen,
  onClose,
  title,
  children,
  placement = 'right',
  className = ''
}: DrawerProps) {
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
      <div className="ds-drawer-backdrop" onClick={onClose} />
      <div className={`ds-drawer ds-drawer--${placement} ${className}`} role="dialog" aria-modal="true">
        {title && (
          <div className="ds-drawer-header">
            <h2 className="ds-drawer-title">{title}</h2>
            <button
              type="button"
              className="ds-drawer-close"
              onClick={onClose}
              aria-label="Fechar"
            >
              ×
            </button>
          </div>
        )}
        <div className="ds-drawer-content">{children}</div>
      </div>
    </>
  )
}
