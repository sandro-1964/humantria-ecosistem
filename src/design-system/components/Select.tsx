/**
 * HUMANTRÍA — Select Component
 */

import { SelectHTMLAttributes, ReactNode } from 'react'
import './Select.css'

interface SelectOption {
  value: string
  label: string
  disabled?: boolean
}

interface SelectProps extends Omit<SelectHTMLAttributes<HTMLSelectElement>, 'children'> {
  label?: string
  error?: string
  helperText?: string
  options: SelectOption[]
  placeholder?: string
}

export function Select({
  label,
  error,
  helperText,
  options,
  placeholder,
  className = '',
  id,
  ...props
}: SelectProps) {
  const selectId = id || `select-${Math.random().toString(36).substr(2, 9)}`
  const hasError = !!error

  return (
    <div className={`ds-select-wrapper ${className}`}>
      {label && (
        <label htmlFor={selectId} className="ds-select-label">
          {label}
        </label>
      )}
      <div className={`ds-select-container ${hasError ? 'ds-select-container--error' : ''}`}>
        <select
          id={selectId}
          className="ds-select"
          {...props}
        >
          {placeholder && <option value="">{placeholder}</option>}
          {options.map((option) => (
            <option key={option.value} value={option.value} disabled={option.disabled}>
              {option.label}
            </option>
          ))}
        </select>
      </div>
      {error && <span className="ds-select-error">{error}</span>}
      {helperText && !error && <span className="ds-select-helper">{helperText}</span>}
    </div>
  )
}
