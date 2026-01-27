import type { Session, User } from '@supabase/supabase-js'
import type { ReactNode } from 'react'
import { createContext, useContext, useEffect, useMemo, useState } from 'react'

import { getSupabaseClient } from '../../services/supabase/client'

export type AuthStatus = 'loading' | 'anonymous' | 'authenticated' | 'error'

export type AuthState = {
  status: AuthStatus
  session: Session | null
  user: User | null
  errorMessage: string | null
}

type AuthContextValue = AuthState & {
  signOut: () => Promise<void>
}

const AuthContext = createContext<AuthContextValue | null>(null)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AuthState>({
    status: 'loading',
    session: null,
    user: null,
    errorMessage: null,
  })

  useEffect(() => {
    let unsub: (() => void) | null = null
    ;(async () => {
      try {
        const supabase = getSupabaseClient()
        const { data, error } = await supabase.auth.getSession()
        if (error) throw error
        setState({
          status: data.session ? 'authenticated' : 'anonymous',
          session: data.session ?? null,
          user: data.session?.user ?? null,
          errorMessage: null,
        })
        const { data: sub } = supabase.auth.onAuthStateChange((_event, session) => {
          setState({
            status: session ? 'authenticated' : 'anonymous',
            session: session ?? null,
            user: session?.user ?? null,
            errorMessage: null,
          })
        })
        unsub = () => sub.subscription.unsubscribe()
      } catch (e) {
        setState({
          status: 'error',
          session: null,
          user: null,
          errorMessage: e instanceof Error ? e.message : 'auth_error',
        })
      }
    })()

    return () => {
      unsub?.()
    }
  }, [])

  const value = useMemo<AuthContextValue>(() => {
    return {
      ...state,
      signOut: async () => {
        const supabase = getSupabaseClient()
        await supabase.auth.signOut()
      },
    }
  }, [state])

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used within AuthProvider')
  return ctx
}

