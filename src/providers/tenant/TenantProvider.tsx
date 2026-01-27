import type { ReactNode } from 'react'
import { createContext, useContext, useMemo } from 'react'

import { useAuth } from '../auth/AuthProvider'
import { decodeJwtClaims } from '../../services/supabase/jwt'
import { useTenantContextQuery } from '../../hooks/use-tenant-context'

export type TenantStatus = 'loading' | 'ready' | 'missing' | 'error'

export type TenantContextState = {
  status: TenantStatus
  tenantId: string | null
  role: string | null
  email: string | null
  tenantName: string | null
  errorMessage: string | null
}

const TenantContext = createContext<TenantContextState | null>(null)

export function TenantProvider({ children }: { children: ReactNode }) {
  const auth = useAuth()

  const claims = useMemo(() => decodeJwtClaims(auth.session?.access_token), [auth.session])

  const tenantId = (claims?.tenant_id as string | undefined) ?? null
  const role = (claims?.role as string | undefined) ?? null
  const email = (claims?.email as string | undefined) ?? auth.user?.email ?? null

  const q = useTenantContextQuery({ enabled: auth.status === 'authenticated' && !!tenantId, tenantId })

  const value = useMemo<TenantContextState>(() => {
    if (auth.status === 'loading') {
      return {
        status: 'loading',
        tenantId,
        role,
        email,
        tenantName: null,
        errorMessage: null,
      }
    }

    if (auth.status === 'error') {
      return {
        status: 'error',
        tenantId: null,
        role: null,
        email: null,
        tenantName: null,
        errorMessage: auth.errorMessage ?? 'auth_error',
      }
    }

    if (auth.status === 'anonymous') {
      return {
        status: 'missing',
        tenantId: null,
        role: null,
        email: null,
        tenantName: null,
        errorMessage: null,
      }
    }

    if (!tenantId) {
      // Platform Owner Console: sovereign mode may be cross-tenant; allow runtime boot even without tenant_id claim.
      if (role === 'platform_owner') {
        return {
          status: 'ready',
          tenantId: null,
          role,
          email,
          tenantName: null,
          errorMessage: null,
        }
      }
      return {
        status: 'missing',
        tenantId: null,
        role,
        email,
        tenantName: null,
        errorMessage: 'missing_tenant_id_claim',
      }
    }

    if (q.isLoading) {
      return {
        status: 'loading',
        tenantId,
        role,
        email,
        tenantName: null,
        errorMessage: null,
      }
    }

    if (q.isError) {
      return {
        status: 'error',
        tenantId,
        role,
        email,
        tenantName: null,
        errorMessage: q.error instanceof Error ? q.error.message : 'tenant_error',
      }
    }

    const tenantName = q.data?.tenant?.name ?? null
    return {
      status: q.data?.tenant ? 'ready' : 'missing',
      tenantId,
      role,
      email,
      tenantName,
      errorMessage: q.data?.tenant ? null : 'tenant_not_found',
    }
  }, [
    auth.errorMessage,
    auth.status,
    email,
    q.data,
    q.error,
    q.isError,
    q.isLoading,
    role,
    tenantId,
  ])

  return <TenantContext.Provider value={value}>{children}</TenantContext.Provider>
}

export function useTenant(): TenantContextState {
  const ctx = useContext(TenantContext)
  if (!ctx) throw new Error('useTenant must be used within TenantProvider')
  return ctx
}

