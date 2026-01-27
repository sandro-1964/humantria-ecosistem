/**
 * HUMANTRÍA — Textarea Component
 */

import { TextareaHTMLAttributes, ReactNode } from 'react'
import './Textarea.css'

interface TextareaProps extends TextareaHTMLAttributes<HTMLTextAreaElement> {
  label?: string
  error?: string
  helperText?: string
}

export function Textarea({
  label,
  error,
  helperText,
  className = '',
  id,
  ...props
}: TextareaProps) {
  const textareaId = id || `textarea-${Math.random().toString(36).substr(2, 9)}`
  const hasError = !!error

  return (
    <div className={`ds-textarea-wrapper ${className}`}>
      {label && (
        <label htmlFor={textareaId} className="ds-textarea-label">
          {label}
        </label>
      )}
      <div className={`ds-textarea-container ${hasError ? 'ds-textarea-container--error' : ''}`}>
        <textarea
          id={textareaId}
          className="ds-textarea"
          {...props}
        />
      </div>
      {error && <span className="ds-textarea-error">{error}</span>}
      {helperText && !error && <span className="ds-textarea-helper">{helperText}</span>}
    </div>
  )
}
