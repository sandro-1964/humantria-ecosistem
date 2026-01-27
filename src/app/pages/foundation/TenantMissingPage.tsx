import { useTenant } from '../../../providers/tenant/TenantProvider'
import { ErrorState } from '../../../providers/app/states'

export function TenantMissingPage() {
  const tenant = useTenant()
  return (
    <ErrorState
      title="Tenant missing"
      body="Não foi possível resolver o tenant. Verifique JWT claims (tenant_id) e/ou seed."
      details={tenant.errorMessage ?? undefined}
    />
  )
}

