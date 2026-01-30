import type { ReactNode } from 'react'
import { createContext, useContext, useMemo } from 'react'

import { useTenant } from '../tenant/TenantProvider'
import { useFlagsQuery } from '../../hooks/use-flags'
import { getDemoSession } from '../../services/demo/demo-session'
import { hasSupabaseEnv } from '../../services/supabase/client'

export type FlagsStatus = 'loading' | 'ready' | 'error'

export type FlagsState = {
  status: FlagsStatus
  flags: Record<string, boolean>
  errorMessage: string | null
  isEnabled: (flagCode: string) => boolean
}

const FlagsContext = createContext<FlagsState | null>(null)

const EMPTY_FLAGS_STATE: FlagsState = {
  status: 'ready',
  flags: {},
  errorMessage: null,
  isEnabled: () => false,
}

export function FlagsProvider({ children }: { children: ReactNode }) {
  const tenant = useTenant()
  const demo = getDemoSession()
  const useRealFlags = tenant.status === 'ready' && !demo?.enabled && hasSupabaseEnv()
  const q = useFlagsQuery({ enabled: useRealFlags, tenantId: tenant.tenantId })

  const value = useMemo<FlagsState>(() => {
    if (demo?.enabled || !hasSupabaseEnv()) {
      return EMPTY_FLAGS_STATE
    }
    if (q.isLoading) {
      return {
        status: 'loading',
        flags: {},
        errorMessage: null,
        isEnabled: () => false,
      }
    }
    if (q.isError) {
      return {
        status: 'error',
        flags: {},
        errorMessage: q.error instanceof Error ? q.error.message : 'flags_error',
        isEnabled: () => false,
      }
    }
    const flags = q.data ?? {}
    return {
      status: 'ready',
      flags,
      errorMessage: null,
      isEnabled: (flagCode: string) => Boolean(flags[flagCode]),
    }
  }, [demo?.enabled, q.data, q.error, q.isError, q.isLoading])

  return <FlagsContext.Provider value={value}>{children}</FlagsContext.Provider>
}

export function useFlags(): FlagsState {
  const ctx = useContext(FlagsContext)
  if (!ctx) throw new Error('useFlags must be used within FlagsProvider')
  return ctx
}

