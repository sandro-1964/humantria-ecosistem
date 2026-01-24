HUMANTRÍA — Princípios Arquiteturais (V1.0)
Status: IMUTÁVEL (mudança só por decisão formal)
Finalidade: evitar acoplamento, garantir escalabilidade e governança

1. Camadas

FOUNDATION: infraestrutura transversal (tenancy, security, audit, events, privacy, ia governance, billing infra, flags/quotas, templates).

CORE: semântica canônica do cliente (org, people, jobs/levels, cost centers, vínculos, import).

PRODUCTS: domínios independentes (Strategy, Talent, Ops, GRC, Intelligence, Experience, Evolution, Chronos, etc.).

BRIDGE: integrações e troca de sinais (import/export, APIs, webhooks, data bridge de DB do cliente).

2. Regras de acoplamento (absolutas)

❌ Proibido FK entre produtos.

✅ Produtos leem CORE (governado) e publicam eventos (outbox).

✅ Produto → Produto: somente eventos/evidências/métricas, nunca leitura/escrita direta.

✅ Toda mutação relevante gera:

audit_log (técnico) e/ou audit_log_functional (decisão/evidência)

events_outbox (bridge-first)

✅ Funções governadas, sem “mágica invisível” (triggers mínimos e auditáveis)

3. Multi-tenancy e segurança

tenant_id obrigatório (exceto catálogos globais explicitamente marcados)

RLS obrigatório em tabelas de domínio

políticas por perfil/RBAC

segregação demo/trial/prod por “tenant environment” governado

4. Modos de tenant (não misturar)

DEMO: narrativo, sintético, resetável, orientado a vendas.

TRIAL: sandbox real do cliente, escopo limitado, governado.

PROD: governança plena, métricas faturáveis e auditoria completa.

5. Operador da plataforma (soberania)

Existe camada de operação soberana (Platform Owner Console) para:
tenants, planos, flags, quotas, incidentes, auditoria cruzada, custos e ações governadas.