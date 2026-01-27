# 2026-01-27 — core_patch_v1_ui_apis_scope

## Contexto

O Core V1 está congelado. A UI Runtime e produtos precisam de um conjunto mínimo de APIs/RPCs para consumir dados canônicos (org/jobs/levels) e funções de economics já aprovadas.

Este documento define o **escopo fechado** do GS-PATCH V1 “UI/APIs mínimas” no Core.

## Decisão (escopo fechado)

- **Criar** um GS-PATCH dedicado em `contracts/core/gs_patch_v1_ui_apis/` com funções **SECURITY INVOKER**, **multi-tenant** e compatíveis com RLS existente.
- **Adicionar** apenas RPCs de leitura mínimas para:
  - `core.list_jobs(p_tenant_id uuid)`
  - `core.list_job_levels(p_tenant_id uuid, p_job_id uuid default null)`
  - `core.get_job_matrix(p_tenant_id uuid)`
  - `core.get_org_tree(p_tenant_id uuid)`
- **Não** alterar tabelas/estrutura econômica fora do Core nem criar qualquer feature nova.
- **Não** relaxar RLS; apenas reutilizar policies existentes.

## Economics — contrato canônico confirmado

- Já existem e são canônicas (patch anterior):
  - `core.convert_currency(...)`
  - `core.get_cost_parameter_for_context(...)`
- Para salary structure “por contexto”, o contrato canônico existente é:
  - `core.get_salary_structure_for_job_level(...)`
- **Não será criada** uma função nova `core.get_salary_structure_for_context(...)` neste patch, para evitar “inventar engine”/duplicar contrato. Se algum consumidor exigir o nome alternativo, isso deve virar **nova decisão** e evidência.

## Observações de segurança/tenancy

- As novas RPCs validam `tenant_id` e:
  - exigem contexto de tenant para perfis não-owner
  - permitem Platform Owner consultar tenant arbitrário (sempre filtrando por `p_tenant_id`)
- Erros retornam mensagem curta e incluem `correlation_id` quando disponível (best-effort via headers).

## Impacto

- **DB**: novas funções de leitura no schema `core` (sem schema changes; sem seed).
- **Compatibilidade DB**: o DB alvo usa `core.job_levels.seniority_level`; o contrato das RPCs expõe `level_number` mapeando `seniority_level → level_number` (sem alterar tabela).
- **Risco**: baixo, pois as funções são read-only e respeitam RLS/policies existentes.

## Rollback

- `DROP FUNCTION` das funções adicionadas no patch (listar no audit report).

