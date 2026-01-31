# DECISÃO CANÔNICA — Regras de Dependência entre Camadas (FK e Policy)

**Data:** 2026-01-31  
**Status:** ATIVA  
**Escopo:** Dependências entre Foundation, Core e Produtos  

---

## Contexto

- **Core** é SSOT (Single Source of Truth) e camada base para semântica canônica do cliente (org, people, jobs, cost centers, etc.).
- **Foundation** é infraestrutura transversal (tenancy, security, audit, events).
- **Produtos** (Strategy, Talent, Ops, etc.) implementam domínios de decisão sobre a base.
- Produtos precisam referenciar entidades do Core para manter integridade referencial e consistência.

---

## Decisão

### Permitido

- **FK Produto → Core:** Produtos podem ter foreign keys referenciando tabelas do Core (ex.: strategy.staffing_demands → core.org_units, core.jobs).
- **FK Produto → Foundation:** Produtos podem ter foreign keys referenciando Foundation (ex.: tenant_id → foundation.tenants).

### Proibido

- **FK Core/Foundation → Produto:** Camadas base não podem depender de produtos.
- **FK Produto ↔ Produto:** Produtos não podem ter FKs entre si (comunicação via eventos/evidências).

---

## Impactos

- A validação estrutural (Q9) deve tratar **Strategy→Core** e **Produto→Foundation** como **OK**.
- A regra "FK cross-product" no canon refere-se a **Produto↔Produto**, não Produto→Base.
- Políticas RLS e validações devem continuar exigindo tenant-safe em todas as camadas.

---

## Referência

- docs/_canon/01_architecture_principles.md — Regras de Dependência entre Camadas
- docs/_canon/02_db_contract_global.md — Proibições (atualizado)
