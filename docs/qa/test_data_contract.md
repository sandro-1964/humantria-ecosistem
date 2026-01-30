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
