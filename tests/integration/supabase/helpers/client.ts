import { createClient, type SupabaseClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.SUPABASE_URL!
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY!
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY!

const sharedOptions = {
  auth: { persistSession: false },
}

export function getServiceClient(): SupabaseClient {
  return createClient(supabaseUrl, supabaseServiceRoleKey, sharedOptions)
}

export function getAnonClient(): SupabaseClient {
  return createClient(supabaseUrl, supabaseAnonKey, sharedOptions)
}
