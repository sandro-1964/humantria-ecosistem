import { useRbac } from '../providers/rbac/RbacProvider'
import { can } from '../lib/rbac-can'

export function useCan(permission: string): boolean {
  const rbac = useRbac()
  if (rbac.status !== 'ready') return false
  return can(rbac.permissions, permission)
}
