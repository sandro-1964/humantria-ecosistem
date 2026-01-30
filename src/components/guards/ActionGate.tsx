import type { ReactNode } from 'react'

import { MenuGate } from './MenuGate'

type Props = {
  permission: string
  children: ReactNode
}

/** Renders children only when the user has the given permission (role-agnostic). */
export function ActionGate({ permission, children }: Props) {
  return <MenuGate allowPermissions={[permission]}>{children}</MenuGate>
}
