import type { ReactNode } from 'react'

import { useRbac } from '../../providers/rbac/RbacProvider'

type Props = {
  allowRoles?: string[]
  allowPermissions?: string[]
  children: ReactNode
}

function hasAnyRole(role: string | null, allowRoles: string[] | undefined): boolean {
  if (!allowRoles || allowRoles.length === 0) return true
  if (!role) return false
  return allowRoles.includes(role)
}

function hasAllPermissions(userPerms: string[], allowPermissions: string[] | undefined): boolean {
  if (!allowPermissions || allowPermissions.length === 0) return true
  if (userPerms.includes('*')) return true
  return allowPermissions.every((p) => userPerms.includes(p))
}

export function MenuGate({ allowRoles, allowPermissions, children }: Props) {
  const rbac = useRbac()
  if (rbac.status !== 'ready') return null

  const ok = hasAnyRole(rbac.role, allowRoles) && hasAllPermissions(rbac.permissions, allowPermissions)
  if (!ok) return null

  return <>{children}</>
}

