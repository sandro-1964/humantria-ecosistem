import type { ReactNode } from 'react'
import { createContext, useContext, useMemo } from 'react'

import { useTenant } from '../tenant/TenantProvider'
import { useFlagsQuery } from '../../hooks/use-flags'

export type FlagsStatus = 'loading' | 'ready' | 'error'

export type FlagsState = {
  status: FlagsStatus
  flags: Record<string, boolean>
  errorMessage: string | null
  isEnabled: (flagCode: string) => boolean
}

const FlagsContext = createContext<FlagsState | null>(null)

export function FlagsProvider({ children }: { children: ReactNode }) {
  const tenant = useTenant()
  const q = useFlagsQuery({ enabled: tenant.status === 'ready', tenantId: tenant.tenantId })

  const value = useMemo<FlagsState>(() => {
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
  }, [q.data, q.error, q.isError, q.isLoading])

  return <FlagsContext.Provider value={value}>{children}</FlagsContext.Provider>
}

export function useFlags(): FlagsState {
  const ctx = useContext(FlagsContext)
  if (!ctx) throw new Error('useFlags must be used within FlagsProvider')
  return ctx
}

