import type { ReactNode } from 'react'
import { createContext, useContext, useMemo } from 'react'

import { useTenant } from '../tenant/TenantProvider'
import { useRbacQuery } from '../../hooks/use-rbac'

export type RbacStatus = 'loading' | 'ready' | 'error'

export type RbacState = {
  status: RbacStatus
  role: string | null
  permissions: string[]
  errorMessage: string | null
}

const RbacContext = createContext<RbacState | null>(null)

export function RbacProvider({ children }: { children: ReactNode }) {
  const tenant = useTenant()
  const q = useRbacQuery({
    enabled: tenant.status === 'ready',
    tenantId: tenant.tenantId,
    roleFromJwt: tenant.role,
    userEmail: tenant.email,
  })

  const value = useMemo<RbacState>(() => {
    if (q.isLoading) {
      return { status: 'loading', role: tenant.role, permissions: [], errorMessage: null }
    }
    if (q.isError) {
      return {
        status: 'error',
        role: tenant.role,
        permissions: [],
        errorMessage: q.error instanceof Error ? q.error.message : 'rbac_error',
      }
    }
    return {
      status: 'ready',
      role: q.data?.role ?? tenant.role ?? null,
      permissions: q.data?.permissions ?? [],
      errorMessage: null,
    }
  }, [q.data?.permissions, q.data?.role, q.error, q.isError, q.isLoading, tenant.role])

  return <RbacContext.Provider value={value}>{children}</RbacContext.Provider>
}

export function useRbac(): RbacState {
  const ctx = useContext(RbacContext)
  if (!ctx) throw new Error('useRbac must be used within RbacProvider')
  return ctx
}

