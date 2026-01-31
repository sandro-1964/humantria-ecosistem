import type { ReactNode } from 'react'

export interface SidebarProps {
  children?: ReactNode
  className?: string
}

export function Sidebar({ children, className = '' }: SidebarProps) {
  return (
    <aside className={`lovable-sidebar ${className}`.trim()} data-testid="lovable-sidebar">
      {children}
    </aside>
  )
}
