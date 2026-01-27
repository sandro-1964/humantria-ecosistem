/**
 * HUMANTRÍA — KPIBlock Component
 */

import { ReactNode } from 'react'
import './KPIBlock.css'

interface KPIBlockProps {
  title: string
  value: string | number
  subtitle?: string
  icon?: ReactNode
  variant?: 'neutral' | 'success' | 'warning' | 'error' | 'info'
  className?: string
}

export function KPIBlock({
  title,
  value,
  subtitle,
  icon,
  variant = 'neutral',
  className = ''
}: KPIBlockProps) {
  return (
    <div className={`ds-kpi-block ds-kpi-block--${variant} ${className}`}>
      {icon && <div className="ds-kpi-block-icon">{icon}</div>}
      <div className="ds-kpi-block-content">
        <div className="ds-kpi-block-title">{title}</div>
        <div className="ds-kpi-block-value">{value}</div>
        {subtitle && <div className="ds-kpi-block-subtitle">{subtitle}</div>}
      </div>
    </div>
  )
}
