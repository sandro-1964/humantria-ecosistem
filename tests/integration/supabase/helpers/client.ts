import { createClient, type SupabaseClient } from '@supabase/supabase-js'

/**
 * Supabase clients for integration tests.
 * Uses .schema('foundation'|'strategy') which maps to PostgREST headers:
 * Accept-Profile (GET/HEAD) and Content-Profile (POST/PATCH/DELETE).
 * Requires schemas exposed in pgrst.db_schemas and USAGE+table grants for anon/authenticated/service_role.
 */
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
