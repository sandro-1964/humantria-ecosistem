import type { ReactNode } from 'react'

import { useAuth } from '../auth/AuthProvider'
import { useTenant } from '../tenant/TenantProvider'
import { LoadingState, ErrorState } from './states'
import { AuthPage } from '../../app/pages/auth/AuthPage'
import { TenantMissingPage } from '../../app/pages/foundation/TenantMissingPage'

export function AppReadyGate({ children }: { children: ReactNode }) {
  const auth = useAuth()
  const tenant = useTenant()

  if (auth.status === 'loading') return <LoadingState />
  if (auth.status === 'error') return <ErrorState details={auth.errorMessage ?? undefined} />
  if (auth.status === 'anonymous') return <AuthPage />

  if (tenant.status === 'loading') return <LoadingState />
  if (tenant.status === 'error') return <ErrorState details={tenant.errorMessage ?? undefined} />
  if (tenant.status === 'missing') return <TenantMissingPage />

  return <>{children}</>
}

