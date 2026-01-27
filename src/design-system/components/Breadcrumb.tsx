/**
 * HUMANTRÍA — Breadcrumb Component
 */

import { ReactNode } from 'react'
import './Breadcrumb.css'

interface BreadcrumbItem {
  label: string
  href?: string
}

interface BreadcrumbProps {
  items: BreadcrumbItem[]
  className?: string
}

export function Breadcrumb({ items, className = '' }: BreadcrumbProps) {
  return (
    <nav className={`ds-breadcrumb ${className}`} aria-label="Breadcrumb">
      <ol className="ds-breadcrumb-list">
        {items.map((item, index) => (
          <li key={index} className="ds-breadcrumb-item">
            {index < items.length - 1 ? (
              item.href ? (
                <a href={item.href} className="ds-breadcrumb-link">
                  {item.label}
                </a>
              ) : (
                <span className="ds-breadcrumb-link">{item.label}</span>
              )
            ) : (
              <span className="ds-breadcrumb-current" aria-current="page">
                {item.label}
              </span>
            )}
            {index < items.length - 1 && (
              <span className="ds-breadcrumb-separator" aria-hidden="true">
                /
              </span>
            )}
          </li>
        ))}
      </ol>
    </nav>
  )
}
