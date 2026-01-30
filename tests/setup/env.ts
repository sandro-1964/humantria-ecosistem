/**
 * T9 Integration tests: load .env.local if present and validate required env vars.
 * Does not fail if .env.local is missing.
 */
import { existsSync } from 'node:fs'
import { resolve } from 'node:path'
import { config } from 'dotenv'

const envLocalPath = resolve(process.cwd(), '.env.local')
if (existsSync(envLocalPath)) {
  config({ path: envLocalPath })
}

const required = [
  'SUPABASE_URL',
  'SUPABASE_ANON_KEY',
  'SUPABASE_SERVICE_ROLE_KEY',
] as const

export function requireEnv(name: (typeof required)[number]): string {
  const value = process.env[name]
  if (!value || value.trim() === '') {
    throw new Error(
      `T9 integration: missing or empty env ${name}. Set it in .env.local or environment.`,
    )
  }
  return value
}

for (const key of required) {
  requireEnv(key)
}
