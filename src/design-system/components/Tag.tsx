/**
 * HUMANTRÍA — Tag Component
 */

import { ReactNode } from 'react'
import './Tag.css'

interface TagProps {
  children: ReactNode
  onRemove?: () => void
  className?: string
}

export function Tag({ children, onRemove, className = '' }: TagProps) {
  return (
    <span className={`ds-tag ${className}`}>
      {children}
      {onRemove && (
        <button
          type="button"
          className="ds-tag-remove"
          onClick={onRemove}
          aria-label="Remover tag"
        >
          ×
        </button>
      )}
    </span>
  )
}
