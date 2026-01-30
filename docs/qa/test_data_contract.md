# T9 — Test data contract

## Tenant temporário

- **Tabela:** `foundation.tenants`
- **Slug:** `int-t9-<timestamp>-<rand>` (ex.: `int-t9-1738234567890-abc12d`)
- **Name:** `T9 Integration <timestamp>`
- **Status:** `active`
- **Criação:** via cliente SERVICE_ROLE nos testes (beforeAll / factory).
- **Cleanup:** obrigatório em afterAll; deletar por `id` (cascata nas tabelas dependentes).

## Regras

- Dados isolados por tenant e por run; não compartilhar com produção.
- Nenhum dado persistido após o run; sempre remover o tenant criado.
- Não usar slugs/names fixos que colidam entre runs paralelos (sempre timestamp/rand).

## Evidência de fechamento T9 (2026-01-30)

- Contrato do tenant temporário `int-t9-*` e cleanup confirmados no código (`tests/integration/supabase/helpers/tenant.ts`, `foundation.spec.ts` afterAll).
- No run de fechamento, test:int falhou antes de criar tenant (erro "Invalid schema: foundation"), portanto nenhum tenant temporário foi criado nem removido neste run.
- **Nenhuma policy foi alterada; somente leitura + testes.**
