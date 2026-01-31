import type { ReactNode } from 'react'

type Props = {
  children: ReactNode
}

export function Sidebar({ children }: Props) {
  return <aside className="ds-sidebar">{children}</aside>
}
