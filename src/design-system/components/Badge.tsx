/**
 * HUMANTRÍA — Badge Component
 */

import { ReactNode } from 'react'
import './Badge.css'

interface BadgeProps {
  children: ReactNode
  variant?: 'neutral' | 'success' | 'warning' | 'error' | 'info'
  size?: 'sm' | 'md'
  className?: string
}

export function Badge({
  children,
  variant = 'neutral',
  size = 'md',
  className = ''
}: BadgeProps) {
  return (
    <span className={`ds-badge ds-badge--${variant} ds-badge--${size} ${className}`}>
      {children}
    </span>
  )
}
