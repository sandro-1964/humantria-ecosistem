# DECISÃO ARQUITETURAL — BASE V1 FROZEN

**Data:** 2026-01-24
**Decisores:** Sandro (Platform Owner) + Nelson (CEO Técnico)
**Status:** ✅ APROVADA · VINCULANTE
**Escopo:** Congelamento da Base V1 (Foundation + Core)

---

## 🎯 DECISÃO PRINCIPAL

**A BASE V1 (Foundation V1 + Core V1) está CONGELADA como referência arquitetural.**

### O que isso significa:
- ✅ **Não reabrir:** Foundation/Core não recebem novas features
- ✅ **Patch only:** Apenas correções críticas de segurança/bug
- ✅ **Read-only contracts:** Arquivos em `contracts/foundation/` e `contracts/core/` são referência
- ✅ **New products:** Todos os produtos vão para `contracts/<product>/`
- ✅ **Backward compatible:** Qualquer patch deve manter compatibilidade

---

## 📋 CONTEXTO DA DECISÃO

### O que foi entregue na Base V1:
- **Foundation V1:** 48 tabelas, 11 funções, 81 RLS policies (infra transversal)
- **Core V1:** 15 tabelas, 8 funções, 45 RLS policies (semântica canônica)
- **Total:** 63 tabelas, 19 funções, 126 RLS policies
- **Seeds:** Dados demo completos para desenvolvimento
- **Event backbone:** Sistema de eventos ativo
- **Audit logs:** Auditoria completa implementada

### Validações realizadas:
- ✅ RLS funcionando (Platform Owner vs Tenant Admin)
- ✅ Audit logs capturando mutations
- ✅ Events outbox recebendo eventos
- ✅ Seeds executados idempotentemente
- ✅ Hierarquia org_units funcionando
- ✅ Effective dating ativo onde necessário

---

## 🚫 O QUE MUDA DAQUI PRA FRENTE

### 1. **Estrutura de Contratos**
```
ANTES (Base V1):
contracts/foundation/     → Infra transversal
contracts/core/          → Semântica canônica

AGORA (Produtos):
contracts/<product>/     → Cada produto tem seu próprio schema
├── 001_schema.sql
├── 002_tables.sql
├── 003_functions.sql
├── 004_rls.sql
└── 005_seed_demo.sql
```

### 2. **Regras de Referência**
- ✅ **Foundation/Core são read-only:** Não alterar sem decisão explícita
- ✅ **Cross-schema FKs proibidos:** Produtos não fazem FK para outros produtos
- ✅ **Tenant isolation mantido:** Todo produto tem tenant_id
- ✅ **Event backbone compartilhado:** Todos os produtos publicam no `foundation.events_outbox`

### 3. **Evolução Controlada**
- 🔒 **Base frozen:** Não adicionar tabelas/funções novas na base
- 🩹 **Patch protocol:** Correções críticas seguem processo formal
- 📈 **New versions:** Base V2+ só se necessário arquiteturalmente
- 🔍 **Audit required:** Todo patch tem final_audit_report.md

---

## 🏗️ ARQUITETURA FIXADA

### Layers Definidos (imutável):
```
┌─────────────────────────────────────┐
│         PRODUCTS (contracts/)       │ ← Novos produtos aqui
│   - Product-specific schemas        │
│   - Domain logic isolada           │
├─────────────────────────────────────┤
│         CORE V1 (frozen)           │ ← Semântica canônica
│   - org_units, people, jobs        │
│   - Hierarchies, assignments       │
├─────────────────────────────────────┤
│     FOUNDATION V1 (frozen)         │ ← Infra transversal
│   - tenancy, iam, audit, events    │
│   - billing, ai governance         │
├─────────────────────────────────────┤
│         POSTGRESQL                 │ ← Managed by Supabase
│   - Extensions, security           │
└─────────────────────────────────────┘
```

### Cross-Layer Rules (vinculantes):
1. **Products → Foundation:** OK (referenciar tenants, usar events_outbox)
2. **Products → Core:** OK (referenciar org_units, people, jobs)
3. **Core → Foundation:** OK (já implementado)
4. **Products → Products:** ❌ PROIBIDO (no FK cross-product)

---

## ⚠️ EXCEÇÕES AUTORIZADAS

### Cenários de Patch (raros):
1. **Critical Security Bug:** Vulnerabilidade que compromete dados
2. **Data Corruption:** Bug que corrompe dados existentes
3. **Compliance Issue:** Violação de lei/regulamentação
4. **Performance Critical:** Bottleneck que quebra SLA

### Processo de Exceção:
```
1. Identificação do problema (com evidências)
2. Aprovação conjunta (Platform Owner + CEO Técnico)
3. Implementação do patch (contracts/patch_v1.x/)
4. Validação completa
5. Final audit report
6. Documentação da decisão
7. Deploy controlado
```

---

## 📝 REGISTRO DE PENDÊNCIAS

### TODOs Deferidos (registrados):
- **org_unit_edges v1.5:** Dual-reporting/matrix organization
  - Status: Deferido para quando houver demanda real
  - Justificativa: Complexidade adicional desnecessária para V1

- **job_families:** Agrupamento hierárquico de jobs
  - Status: Deferido para quando necessário
  - Justificativa: Modelo simples suficiente para V1

- **Advanced audit compression:** Compressão automática de logs antigos
  - Status: Deferido para V2.0
  - Justificativa: Volume atual não justifica complexidade

### Próximas Releases:
- **Product 1:** A definir (contracts/product1/)
- **Product 2:** A definir (contracts/product2/)
- **Base V2:** Só se arquiteturalmente necessário

---

## 🎯 CRITÉRIOS DE SUCESSO

### Para a Base V1:
- [x] **63 tabelas** criadas e funcionais
- [x] **19 funções** governadas (SECURITY INVOKER)
- [x] **126 políticas RLS** aplicadas
- [x] **Seeds demo** completos e idempotentes
- [x] **Event backbone** ativo
- [x] **Audit logs** funcionando
- [x] **Hierarquia** org_units OK
- [x] **Multi-tenancy** hard implementado

### Para futuras evoluções:
- [ ] Todo produto tem seu validation_report.md
- [ ] Todo produto segue estrutura contracts/<product>/
- [ ] Todo produto respeita boundaries (no cross-product FKs)
- [ ] Todo patch tem decisão registrada
- [ ] Base permanece frozen até decisão explícita

---

## 📋 DECISÃO FORMAL

**Decidimos por unanimidade:**

1. **Congelar Base V1** como referência arquitetural estável
2. **Proibir alterações** na Base sem processo formal de decisão
3. **Permitir patches críticos** apenas via protocolo aprovado
4. **Direcionar novos desenvolvimentos** para contracts/<product>/
5. **Manter boundaries** entre layers (Foundation → Core → Products)

**Esta decisão é vinculante e será revisada apenas se mudanças arquiteturais fundamentais forem necessárias.**

---

**Assinaturas:**
- **Sandro (Platform Owner):** ✅ Aprovado
- **Nelson (CEO Técnico):** ✅ Aprovado
- **Data da decisão:** 2026-01-24

---

**Referências:**
- `docs/releases/base_v1.md` - Documentação completa da release
- `docs/releases/base_v1_validation_queries.sql` - Queries de validação
- `docs/_canon/` - Regras canônicas aplicáveis
- `contracts/foundation/` e `contracts/core/` - Contratos de referência