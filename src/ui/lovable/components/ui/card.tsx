import type { ReactNode } from 'react'

export interface CardProps {
  children?: ReactNode
  className?: string
  title?: string
}

export function Card({ children, className = '', title }: CardProps) {
  return (
    <div className={`lovable-card ${className}`.trim()} data-testid="lovable-card">
      {title != null && <div className="lovable-card-title">{title}</div>}
      {children}
    </div>
  )
}
