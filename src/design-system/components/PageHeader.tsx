/**
 * HUMANTRÍA — PageHeader Component
 */

import { ReactNode } from 'react'
import './PageHeader.css'

interface PageHeaderProps {
  title: string
  description?: string
  actions?: ReactNode
  breadcrumb?: ReactNode
  className?: string
}

export function PageHeader({ title, description, actions, breadcrumb, className = '' }: PageHeaderProps) {
  return (
    <div className={`ds-page-header ${className}`}>
      {breadcrumb && <div className="ds-page-header-breadcrumb">{breadcrumb}</div>}
      <div className="ds-page-header-content">
        <div>
          <h1 className="ds-page-header-title">{title}</h1>
          {description && <p className="ds-page-header-description">{description}</p>}
        </div>
        {actions && <div className="ds-page-header-actions">{actions}</div>}
      </div>
    </div>
  )
}
