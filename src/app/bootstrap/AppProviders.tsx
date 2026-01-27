import type { ReactNode } from 'react'

import { AuthProvider } from '../../providers/auth/AuthProvider'
import { TenantProvider } from '../../providers/tenant/TenantProvider'
import { FlagsProvider } from '../../providers/flags/FlagsProvider'
import { RbacProvider } from '../../providers/rbac/RbacProvider'
import { BrandProvider } from '../../providers/brand/BrandProvider'

export function AppProviders({ children }: { children: ReactNode }) {
  return (
    <AuthProvider>
      <TenantProvider>
        <BrandProvider>
          <FlagsProvider>
            <RbacProvider>{children}</RbacProvider>
          </FlagsProvider>
        </BrandProvider>
      </TenantProvider>
    </AuthProvider>
  )
}

