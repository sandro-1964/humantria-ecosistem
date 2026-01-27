/**
 * HUMANTRÍA — Section Component
 */

import { ReactNode } from 'react'
import './Section.css'

interface SectionProps {
  title?: string
  description?: string
  children: ReactNode
  className?: string
}

export function Section({ title, description, children, className = '' }: SectionProps) {
  return (
    <section className={`ds-section ${className}`}>
      {(title || description) && (
        <div className="ds-section-header">
          {title && <h2 className="ds-section-title">{title}</h2>}
          {description && <p className="ds-section-description">{description}</p>}
        </div>
      )}
      <div className="ds-section-content">{children}</div>
    </section>
  )
}
