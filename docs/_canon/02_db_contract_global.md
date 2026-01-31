HUMANTRÍA — DB Contract Global (V1.0)
Status: BLOQUEANTE (sem isso não existe build)
Escopo: FOUNDATION + CORE + BRIDGE (e regras comuns a produtos)

1. Convenções obrigatórias

PK padrão: UUID (ou equivalente canônico).

Campos mínimos (quando aplicável): tenant_id, created_at, updated_at.

tenant_id é obrigatório em dados de domínio (exceto catálogos globais explicitamente “global_catalog”).

2. Segurança e RLS

RLS obrigatório em tabelas de domínio.

Policies devem suportar:

Platform Owner (visão soberana, governada)

Tenant Admin

Perfis de negócio (gestor/colaborador/especialista/auditor)

Funções devem ser preferencialmente SECURITY INVOKER e governadas (sem bypass invisível).

3. Auditoria e evidência

Toda mutação relevante deve registrar:

audit_log (técnico: operação, tabela, registro, user, timestamp)

audit_log_functional quando houver decisão/evidência (contexto, justificativa, anexos/ligações)

Evidência deve ser imutável (ou versionada).

4. Event backbone (Bridge-first)

events_outbox é obrigatório para eventos de domínio.

Eventos devem carregar:

correlation_id e causation_id

event_type, entity_type, entity_id, tenant_id

payload versionado

Replay controlado (consumers e checkpoints governados).

5. Proibições

❌ FK cross-product (Produto↔Produto). FK Produto→Core/Foundation é permitida (Decisão 2026-01-31).

❌ “tabela no public porque é mais rápido”.

❌ lógica de negócio escondida em triggers sem contrato.

❌ seed improvisado como dependência implícita de execução.

6. Seeds e dados

Seeds são idempotentes e explícitos.

Mínimo de 4 camadas: technical / functional / demo / edge.

GS/entrega não fecha sem seed + evidência.

7. Fundação de catálogos (catálogo vs extensão do tenant)

Catálogos globais: tabelas “global_catalog” (sem tenant_id) — somente para listas universais (ex.: lista de países).

Extensões do tenant: sempre com tenant_id e RLS.

Campos customizáveis do cliente (se adotado):

devem ser governados, com limite, tipo restrito (ex.: texto curto), auditáveis e com RBAC.