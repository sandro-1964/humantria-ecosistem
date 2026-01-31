/**
 * T9 Integration tests: validate required env vars.
 * Env is loaded by vitest.integration.config.ts (priority: .env.test > .env.local > .env).
 */
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
