import type { ReactNode } from 'react'
import { createContext, useContext, useMemo } from 'react'

import { useTenant } from '../tenant/TenantProvider'
import { useTenantContextQuery } from '../../hooks/use-tenant-context'
import { getDemoSession } from '../../services/demo/demo-session'

export type BrandStatus = 'loading' | 'ready' | 'error'

export type Brand = {
  status: BrandStatus
  tenantName: string | null
  logoUrl: string | null
  accentColor: string | null
}

const BrandContext = createContext<Brand | null>(null)

export function BrandProvider({ children }: { children: ReactNode }) {
  const tenant = useTenant()
  const demo = getDemoSession()
  const q = useTenantContextQuery({
    enabled: tenant.status === 'ready' && !!tenant.tenantId && !demo?.enabled,
    tenantId: tenant.tenantId,
  })

  const value = useMemo<Brand>(() => {
    const tenantName = tenant.tenantName
    const metadata = q.data?.settings?.metadata as any
    const brand = metadata?.brand ?? {}
    let status: BrandStatus = 'ready'
    if (tenant.status === 'ready' && !!tenant.tenantId && !demo?.enabled) {
      if (q.isLoading) status = 'loading'
      else if (q.isError) status = 'error'
    }
    return {
      status,
      tenantName,
      logoUrl: typeof brand.logoUrl === 'string' ? brand.logoUrl : null,
      accentColor: typeof brand.accentColor === 'string' ? brand.accentColor : null,
    }
  }, [demo?.enabled, q.data?.settings?.metadata, q.isError, q.isLoading, tenant.tenantId, tenant.tenantName, tenant.status])

  return <BrandContext.Provider value={value}>{children}</BrandContext.Provider>
}

export function useBrand(): Brand {
  const ctx = useContext(BrandContext)
  if (!ctx) throw new Error('useBrand must be used within BrandProvider')
  return ctx
}

