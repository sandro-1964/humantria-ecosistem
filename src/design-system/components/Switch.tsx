/**
 * HUMANTRÍA — Switch Component
 */

import { InputHTMLAttributes, ReactNode } from 'react'
import './Switch.css'

interface SwitchProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'type'> {
  label?: ReactNode
}

export function Switch({
  label,
  className = '',
  id,
  checked,
  ...props
}: SwitchProps) {
  const switchId = id || `switch-${Math.random().toString(36).substr(2, 9)}`

  return (
    <div className={`ds-switch-wrapper ${className}`}>
      <input
        type="checkbox"
        role="switch"
        id={switchId}
        className="ds-switch"
        checked={checked}
        {...props}
      />
      {label && (
        <label htmlFor={switchId} className="ds-switch-label">
          {label}
        </label>
      )}
    </div>
  )
}
