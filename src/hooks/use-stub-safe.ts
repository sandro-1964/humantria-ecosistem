import { useAuth } from '../providers/auth/AuthProvider'
import { getDemoSession } from '../services/demo/demo-session'

/**
 * Regra de ouro: quando true, páginas admin devem ser "stub safe" e NÃO chamar Supabase.
 */
export function useStubSafe(): boolean {
  const auth = useAuth()
  const demo = getDemoSession()
  return !!(demo?.enabled || auth.supabaseNotConfigured)
}
