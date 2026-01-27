import type { ReactNode } from 'react'

import { useAuth } from '../../providers/auth/AuthProvider'
import { useTenant } from '../../providers/tenant/TenantProvider'
import { useRbac } from '../../providers/rbac/RbacProvider'
import { AccessDeniedState, LoadingState, ErrorState } from '../../providers/app/states'

export function RequireAuth({ children }: { children: ReactNode }) {
  const auth = useAuth()
  if (auth.status === 'loading') return <LoadingState />
  if (auth.status === 'error') return <ErrorState details={auth.errorMessage ?? undefined} />
  if (auth.status !== 'authenticated') return <AccessDeniedState reason="Authentication required." />
  return <>{children}</>
}

export function RequireTenant({ children }: { children: ReactNode }) {
  const tenant = useTenant()
  if (tenant.status === 'loading') return <LoadingState />
  if (tenant.status === 'error') return <ErrorState details={tenant.errorMessage ?? undefined} />
  if (tenant.status !== 'ready') return <AccessDeniedState reason="Tenant context required." />
  return <>{children}</>
}

export function RequireRole({
  roles,
  children,
}: {
  roles: string[]
  children: ReactNode
}) {
  const rbac = useRbac()
  if (rbac.status === 'loading') return <LoadingState />
  if (rbac.status === 'error') return <ErrorState details={rbac.errorMessage ?? undefined} />
  if (!rbac.role || !roles.includes(rbac.role)) {
    return <AccessDeniedState reason="Role not allowed." />
  }
  return <>{children}</>
}

export function RequirePermission({
  permissions,
  children,
}: {
  permissions: string[]
  children: ReactNode
}) {
  const rbac = useRbac()
  if (rbac.status === 'loading') return <LoadingState />
  if (rbac.status === 'error') return <ErrorState details={rbac.errorMessage ?? undefined} />
  const ok = permissions.every((p) => rbac.permissions.includes(p))
  if (!ok) return <AccessDeniedState reason="Permission not allowed." />
  return <>{children}</>
}

