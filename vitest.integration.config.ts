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
