import { useTenant } from '../../../providers/tenant/TenantProvider'
import { useRbac } from '../../../providers/rbac/RbacProvider'
import { toText } from '../../../lib/to-text'

export function FoundationHomePage() {
  const tenant = useTenant()
  const rbac = useRbac()

  return (
    <div>
      <h1>Foundation</h1>
      <p>Tenant: {toText(tenant.tenantName ?? tenant.tenantId ?? 'unknown')}</p>
      <p>Role: {toText(rbac.role ?? 'unknown')}</p>
    </div>
  )
}

