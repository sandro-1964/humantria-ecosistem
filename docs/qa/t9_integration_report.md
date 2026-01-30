# T9 — Integration report (evidências)

## Comando

```bash
npm run test:int
```

## Output esperado

- Vitest executa `tests/integration/supabase/**/*.spec.ts`.
- Foundation: criar tenant temporário, listar via service client (tenant presente), anon client retorna 0 rows.
- Strategy: se RPC `strategy.list_cycles` existir, retorna array; senão teste passa sem falha.
- Cleanup: tenant criado é deletado em `afterAll`.

## Tenants criados / limpos

- Slug pattern: `int-t9-<timestamp>-<rand>`.
- Sempre removidos no `afterAll` do mesmo run (obrigatório).

## DIAG

- `/__diag/meta` expõe `supabaseConfigured: true` quando `VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY` estão definidos (evidência manual no frontend).

## T9 iniciado (integration)

Suite T9 de integração Supabase iniciada nesta branch; evidências de execução local/CI devem ser anotadas aqui após cada run relevante.
