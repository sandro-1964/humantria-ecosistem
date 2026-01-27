/**
 * HUMANTRÍA — Input Component
 */

import { InputHTMLAttributes, ReactNode } from 'react'
import './Input.css'

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string
  error?: string
  helperText?: string
  leftIcon?: ReactNode
  rightIcon?: ReactNode
}

export function Input({
  label,
  error,
  helperText,
  leftIcon,
  rightIcon,
  className = '',
  id,
  ...props
}: InputProps) {
  const inputId = id || `input-${Math.random().toString(36).substr(2, 9)}`
  const hasError = !!error

  return (
    <div className={`ds-input-wrapper ${className}`}>
      {label && (
        <label htmlFor={inputId} className="ds-input-label">
          {label}
        </label>
      )}
      <div className={`ds-input-container ${hasError ? 'ds-input-container--error' : ''}`}>
        {leftIcon && <span className="ds-input-icon-left">{leftIcon}</span>}
        <input
          id={inputId}
          className="ds-input"
          {...props}
        />
        {rightIcon && <span className="ds-input-icon-right">{rightIcon}</span>}
      </div>
      {error && <span className="ds-input-error">{error}</span>}
      {helperText && !error && <span className="ds-input-helper">{helperText}</span>}
    </div>
  )
}
