import type { ReactNode } from 'react'

type Props = {
  label?: string
  children: ReactNode
}

export function SidebarNav({ label, children }: Props) {
  return (
    <nav className="ds-sidebar-nav">
      {label && <div className="ds-sidebar-nav__label">{label}</div>}
      <div className="ds-sidebar-nav__items">{children}</div>
    </nav>
  )
}
