/**
 * RBAC: can(permissions, permission) — pure helper.
 * useCan() in hooks/use-can.ts uses this with useRbac().
 */

export function can(permissions: string[], permission: string): boolean {
  if (permissions.includes('*')) return true
  return permissions.includes(permission)
}
