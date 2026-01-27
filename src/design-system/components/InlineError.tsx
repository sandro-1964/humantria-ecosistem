/**
 * HUMANTRÍA — InlineError Component
 */

import { ReactNode } from 'react'
import './InlineError.css'

interface InlineErrorProps {
  message: string
  className?: string
}

export function InlineError({ message, className = '' }: InlineErrorProps) {
  return (
    <div className={`ds-inline-error ${className}`} role="alert">
      {message}
    </div>
  )
}
