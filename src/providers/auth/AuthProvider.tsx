import type { Session, User } from '@supabase/supabase-js'
import type { ReactNode } from 'react'
import { createContext, useContext, useEffect, useMemo, useState } from 'react'

import { getSupabaseClient } from '../../services/supabase/client'
import {
  getDemoSession,
  DEMO_SESSION_CHANGE_EVENT,
  clearDemoSession,
} from '../../services/demo/demo-session'

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

function syntheticUserFromDemo(demo: { userId: string; userEmail: string; userName: string }): User {
  return {
    id: demo.userId,
    email: demo.userEmail ?? undefined,
    app_metadata: {},
    user_metadata: { full_name: demo.userName },
    aud: 'authenticated',
    created_at: '',
    updated_at: '',
  } as User
}

function applyDemoOrSupabase(
  setState: (s: AuthState) => void,
  demo: ReturnType<typeof getDemoSession>,
  supabaseSession: Session | null,
  supabaseUser: User | null,
  error: string | null,
) {
  if (demo?.enabled) {
    setState({
      status: 'authenticated',
      session: { access_token: 'demo', refresh_token: '', expires_in: 0, token_type: 'bearer', user: syntheticUserFromDemo(demo) } as Session,
      user: syntheticUserFromDemo(demo),
      errorMessage: null,
    })
    return
  }
  setState({
    status: supabaseSession ? 'authenticated' : 'anonymous',
    session: supabaseSession ?? null,
    user: supabaseUser ?? null,
    errorMessage: error,
  })
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AuthState>({
    status: 'loading',
    session: null,
    user: null,
    errorMessage: null,
  })

  useEffect(() => {
    let unsub: (() => void) | null = null

    function initSupabase() {
      ;(async () => {
        try {
          const supabase = getSupabaseClient()
          const { data, error } = await supabase.auth.getSession()
          if (error) throw error
          applyDemoOrSupabase(setState, getDemoSession(), data.session ?? null, data.session?.user ?? null, null)
          const { data: sub } = supabase.auth.onAuthStateChange((_event, session) => {
            if (getDemoSession()?.enabled) return
            applyDemoOrSupabase(setState, null, session ?? null, session?.user ?? null, null)
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
    }

    const demo = getDemoSession()
    if (demo?.enabled) {
      applyDemoOrSupabase(setState, demo, null, null, null)
    } else {
      initSupabase()
    }

    const onDemoChange = () => {
      const d = getDemoSession()
      if (d?.enabled) {
        applyDemoOrSupabase(setState, d, null, null, null)
      } else {
        setState({ status: 'loading', session: null, user: null, errorMessage: null })
        unsub?.()
        unsub = null
        setTimeout(() => initSupabase(), 0)
      }
    }
    window.addEventListener(DEMO_SESSION_CHANGE_EVENT, onDemoChange)
    return () => {
      window.removeEventListener(DEMO_SESSION_CHANGE_EVENT, onDemoChange)
      unsub?.()
    }
  }, [])

  const value = useMemo<AuthContextValue>(() => {
    return {
      ...state,
      signOut: async () => {
        const demo = getDemoSession()
        if (demo?.enabled) {
          clearDemoSession()
          return
        }
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

