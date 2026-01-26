# DECISÃO ARQUITETURAL — STRATEGY V1: FUNÇÕES ECONOMICS AUSENTES

**Data:** 2026-01-26  
**Decisores:** Implementação Strategy V1  
**Status:** ✅ REGISTRADA · BLOQUEANTE  
**Escopo:** Dependência de funções economics do Core para Strategy

---

## 🎯 DECISÃO PRINCIPAL

**As funções `core.convert_currency()` e `core.get_cost_parameter_for_context()` não existem no Core V1.**

### O que isso significa:
- ✅ **Strategy V1:** Implementado sem duplicar economics
- ✅ **Bloqueio fail-fast:** `strategy.calculate_staffing_costs()` bloqueada até economics existir
- ❌ **Proibido:** Criar stubs temporários ou duplicar economics no Strategy
- 📋 **Ação futura:** Economics deve ser implementado no Core (patch ou v2) antes de habilitar cálculo de custos

---

## 📋 CONTEXTO DA DECISÃO

### Validação realizada:
- ✅ Verificado `contracts/core/003_functions.sql` — funções não existem
- ✅ Verificado `contracts/core/` — não há patch_economics_v1/
- ✅ Busca no codebase — nenhuma referência encontrada
- ✅ Core V1 está frozen — não pode ser alterado sem decisão formal

### Requisito do Strategy:
- Strategy precisa calcular custos de staffing usando parâmetros econômicos do Core
- Strategy precisa converter moedas para orçamento multi-moeda
- **Regra inviolável:** Strategy CONSUME economics do Core, não duplica

---

## 🚫 O QUE FOI BLOQUEADO

### Função Bloqueada (fail-fast):
```sql
strategy.calculate_staffing_costs()
```

**Comportamento:**
- Função criada mas retorna erro explícito
- Mensagem: "Economics functions not available in Core. Strategy requires core.convert_currency() and core.get_cost_parameter_for_context() to calculate staffing costs."
- Não permite cálculo de custos até economics existir

### O que continua funcionando:
- ✅ Todas as outras funções do Strategy
- ✅ Criação de staffing_plans e staffing_demands
- ✅ Estrutura de dados completa
- ✅ Apenas o cálculo automático de custos está bloqueado

---

## 🏗️ ARQUITETURA FIXADA

### Dependências do Strategy → Core:
```
Strategy (produto)
  ├─ Lê: core.org_units ✅
  ├─ Lê: core.people ✅
  ├─ Lê: core.jobs ✅
  ├─ Lê: core.job_levels ✅
  ├─ Lê: core.cost_centers ✅
  ├─ Chama: core.convert_currency() ❌ (não existe)
  └─ Chama: core.get_cost_parameter_for_context() ❌ (não existe)
```

### Estratégia de Implementação:
1. **Strategy V1:** Estrutura completa, cálculo bloqueado
2. **Economics Core:** Deve ser implementado em patch ou Core V2
3. **Strategy V1.1:** Habilitar cálculo quando economics existir

---

## ⚠️ EXCEÇÕES E WORKAROUNDS

### Workaround Temporário (se necessário):
- Usuário pode inserir custos manualmente em `strategy.staffing_calculated_costs`
- Ou aguardar implementação de economics no Core

### Proibições:
- ❌ Criar stubs temporários
- ❌ Duplicar economics no Strategy
- ❌ Alterar Core V1 sem decisão formal

---

## 📝 PRÓXIMAS AÇÕES

### Para habilitar cálculo de custos:
1. **Implementar economics no Core:**
   - `core.convert_currency(from_currency, to_currency, amount, effective_date)`
   - `core.get_cost_parameter_for_context(tenant_id, job_id, job_level_id, effective_date)`
   - Tabelas de suporte (se necessário): `core.economic_parameters`, `core.currency_rates`

2. **Atualizar Strategy:**
   - Remover bloqueio de `strategy.calculate_staffing_costs()`
   - Implementar chamadas às funções do Core
   - Testar integração

3. **Registrar decisão:**
   - Decisão de implementação de economics no Core
   - Decisão de habilitação do cálculo em Strategy

---

## 🎯 CRITÉRIOS DE SUCESSO

### Para Strategy V1 (atual):
- [x] Estrutura completa de tabelas
- [x] Funções governadas (exceto cálculo bloqueado)
- [x] RLS aplicado
- [x] Eventos publicados
- [x] Seeds funcionando
- [x] Cálculo bloqueado com mensagem clara

### Para Strategy V1.1 (futuro):
- [ ] Economics implementado no Core
- [ ] Cálculo de custos habilitado
- [ ] Testes de integração passando
- [ ] Validação completa

---

## 📋 DECISÃO FORMAL

**Decidimos:**
1. **Não criar stubs temporários** de economics
2. **Bloquear apenas** `strategy.calculate_staffing_costs()` com fail-fast
3. **Continuar implementação** do Strategy V1 sem economics
4. **Aguardar** implementação de economics no Core
5. **Registrar** esta decisão para rastreabilidade

**Esta decisão é vinculante e será revisada quando economics for implementado no Core.**

---

**Referências:**
- `contracts/core/003_functions.sql` - Funções do Core (sem economics)
- `contracts/strategy/003_functions.sql` - Funções do Strategy (com bloqueio)
- `docs/decisions/2026-01-24_base_v1_frozen.md` - Base V1 frozen
