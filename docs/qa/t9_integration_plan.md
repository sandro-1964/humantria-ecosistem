# T9 — Integration tests (Supabase)

## Resumo

Suite de testes de integração (Node + Vitest) contra Supabase real. Cobre Foundation (tenants, RLS), Strategy (condicional) e evidência DIAG (`supabaseConfigured` em `/__diag/meta`). Integration tests **não** rodam por padrão; só via `npm run test:int`.

## Envs exigidas

- `SUPABASE_URL` — URL do projeto Supabase
- `SUPABASE_ANON_KEY` — chave anônima
- `SUPABASE_SERVICE_ROLE_KEY` — chave service role (bypass RLS para seed/cleanup)

Nenhuma chave no código; testes usam `process.env.*`.

## Rodar local

1. Criar `.env.local` na raiz (ou exportar as variáveis no shell):

   ```
   SUPABASE_URL=https://xxx.supabase.co
   SUPABASE_ANON_KEY=eyJ...
   SUPABASE_SERVICE_ROLE_KEY=eyJ...
   ```

2. Executar:

   ```bash
   npm run test:int
   ```

   Watch (re-run on change):

   ```bash
   npm run test:int:watch
   ```

## Rodar no GitHub

- **Manual:** Actions → "Integration (Supabase T9)" → "Run workflow".
- **Nightly:** Workflow agendado 00:00 UTC (se habilitado).
- Configurar secrets no repositório: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`.

Não roda em todo push; separado do smoke.
