import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.SUPABASE_URL!
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY!

export function getServiceClient() {
  return createClient(supabaseUrl, supabaseServiceRoleKey, { auth: { persistSession: false } })
}
