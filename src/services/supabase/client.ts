import { createClient, type SupabaseClient } from '@supabase/supabase-js'

export type HumantriaSupabaseClient = SupabaseClient

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string | undefined
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined

let _client: HumantriaSupabaseClient | null = null

export function getSupabaseClient(): HumantriaSupabaseClient {
  if (_client) return _client
  if (!supabaseUrl || !supabaseAnonKey) {
    throw new Error(
      'Missing VITE_SUPABASE_URL or VITE_SUPABASE_ANON_KEY. Configure .env and restart dev server.',
    )
  }
  _client = createClient(supabaseUrl, supabaseAnonKey, {
    auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true },
  })
  return _client
}

