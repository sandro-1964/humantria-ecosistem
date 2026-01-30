import { createClient, type SupabaseClient } from '@supabase/supabase-js'

export type HumantriaSupabaseClient = SupabaseClient

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string | undefined
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined

let _client: HumantriaSupabaseClient | null = null

/** True when env is set; app can run DEMO 100% when false. */
export function hasSupabaseEnv(): boolean {
  return !!(supabaseUrl && supabaseAnonKey)
}

export function getSupabaseClient(): HumantriaSupabaseClient {
  if (_client) return _client
  if (!hasSupabaseEnv()) {
    throw new Error(
      'Missing VITE_SUPABASE_URL or VITE_SUPABASE_ANON_KEY. Configure .env and restart dev server.',
    )
  }
  _client = createClient(supabaseUrl!, supabaseAnonKey!, {
    auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true },
  })
  return _client
}

