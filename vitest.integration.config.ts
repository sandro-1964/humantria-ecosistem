import { existsSync } from 'node:fs'
import { resolve } from 'node:path'
import * as dotenv from 'dotenv'

// Priority: .env.test > .env.local > .env
const envTestPath = resolve(process.cwd(), '.env.test')
const envLocalPath = resolve(process.cwd(), '.env.local')
const envPath = resolve(process.cwd(), '.env')

const envFile = existsSync(envTestPath)
  ? envTestPath
  : existsSync(envLocalPath)
    ? envLocalPath
    : envPath

dotenv.config({ path: envFile })

import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    include: ['tests/integration/supabase/**/*.spec.ts'],
    environment: 'node',
    testTimeout: 60_000,
    hookTimeout: 60_000,
    reporters: ['default'],
    setupFiles: ['tests/setup/env.ts'],
  },
})
