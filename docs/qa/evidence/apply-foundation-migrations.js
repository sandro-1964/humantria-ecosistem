/**
 * HUMANTRÍA T9 — Apply foundation migrations via Supabase Management API.
 * HISTÓRICO: copiado de scripts/ para docs/qa/evidence/ (não executar migrations no fechamento).
 * Uses SUPABASE_ACCESS_TOKEN (env or .cursor/mcp.json) and project ref from .env.local.
 * No secrets printed to stdout.
 */
import { readFileSync, existsSync } from 'node:fs'
import { resolve, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'
import { config } from 'dotenv'

const __dirname = dirname(fileURLToPath(import.meta.url))
const root = resolve(__dirname, '..', '..', '..')

config({ path: resolve(root, '.env.local') })

const SUPABASE_URL = process.env.SUPABASE_URL
const ref = SUPABASE_URL ? new URL(SUPABASE_URL).hostname.replace('.supabase.co', '') : null
let token = process.env.SUPABASE_ACCESS_TOKEN
if (!token && existsSync(resolve(root, '.cursor', 'mcp.json'))) {
  try {
    const mcp = JSON.parse(readFileSync(resolve(root, '.cursor', 'mcp.json'), 'utf8'))
    token = mcp?.mcpServers?.supabase?.env?.SUPABASE_ACCESS_TOKEN || null
  } catch (_) {}
}

if (!ref || !token) {
  console.error('Missing: SUPABASE_URL (in .env.local) and SUPABASE_ACCESS_TOKEN (env or .cursor/mcp.json)')
  process.exit(1)
}

const files = [
  'contracts/foundation/001_schema.sql',
  'contracts/foundation/002_tables.sql',
  'contracts/foundation/003_functions.sql',
  'contracts/foundation/004_rls.sql',
  'contracts/foundation/005_seed_demo.sql',
]

const api = `https://api.supabase.com/v1/projects/${ref}/database/query`

async function runQuery(sql) {
  const res = await fetch(api, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({ query: sql }),
  })
  const text = await res.text()
  if (!res.ok) {
    throw new Error(`API ${res.status}: ${text.slice(0, 500)}`)
  }
  try {
    return JSON.parse(text)
  } catch {
    return {}
  }
}

async function main() {
  for (const rel of files) {
    const path = resolve(root, rel)
    const sql = readFileSync(path, 'utf8')
    process.stdout.write(`Applying ${rel}... `)
    try {
      await runQuery(sql)
      console.log('OK')
    } catch (err) {
      console.error('FAIL')
      console.error(err.message)
      process.exit(1)
    }
  }
  console.log('All foundation migrations applied.')
}

main()
