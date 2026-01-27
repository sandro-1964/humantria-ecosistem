/**
 * HUMANTRÍA — Checkbox Component
 */

import { InputHTMLAttributes, ReactNode } from 'react'
import './Checkbox.css'

interface CheckboxProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'type'> {
  label?: ReactNode
}

export function Checkbox({
  label,
  className = '',
  id,
  ...props
}: CheckboxProps) {
  const checkboxId = id || `checkbox-${Math.random().toString(36).substr(2, 9)}`

  return (
    <div className={`ds-checkbox-wrapper ${className}`}>
      <input
        type="checkbox"
        id={checkboxId}
        className="ds-checkbox"
        {...props}
      />
      {label && (
        <label htmlFor={checkboxId} className="ds-checkbox-label">
          {label}
        </label>
      )}
    </div>
  )
}
