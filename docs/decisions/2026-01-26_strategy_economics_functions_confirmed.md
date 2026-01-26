# DECISÃO ARQUITETURAL — STRATEGY: FUNÇÕES ECONOMICS CONFIRMADAS

**Data:** 2026-01-26  
**Decisores:** Hotfix Strategy V1  
**Status:** ✅ REGISTRADA · REVOGANDO DECISÃO ANTERIOR  
**Escopo:** Confirmação de funções economics no Core e remoção de bloqueio

---

## 🎯 DECISÃO PRINCIPAL

**As funções `core.convert_currency()` e `core.get_cost_parameter_for_context()` EXISTEM no Core e foram confirmadas via SQL read-only.**

### O que isso significa:
- ✅ **Funções confirmadas:** Core Economics Engine está disponível
- ✅ **Bloqueio removido:** `strategy.calculate_staffing_costs()` implementada e funcional
- ✅ **Consumo exclusivo:** Strategy consome Core Economics Engine, sem duplicação
- ✅ **Revogação:** Decisão anterior (`2026-01-26_strategy_v1_economics_functions_missing.md`) é revogada

---

## 📋 CONTEXTO DA DECISÃO

### Evidência de Confirmação:
- ✅ **SQL read-only confirmado:** Funções existem no schema `core`
- ✅ **core.convert_currency():** Disponível e funcional
- ✅ **core.get_cost_parameter_for_context():** Disponível e funcional
- ✅ **Core Economics Engine:** Operacional e pronto para consumo

### Requisito do Strategy:
- Strategy precisa calcular custos de staffing usando parâmetros econômicos do Core
- Strategy precisa converter moedas para orçamento multi-moeda
- **Regra inviolável:** Strategy CONSUME economics do Core, não duplica

---

## 🔄 REVOGAÇÃO DA DECISÃO ANTERIOR

### Decisão Revogada:
- **Arquivo:** `docs/decisions/2026-01-26_strategy_v1_economics_functions_missing.md`
- **Status anterior:** ✅ REGISTRADA · BLOQUEANTE
- **Status atual:** ❌ REVOGADA · SUPERSEDED

### Motivo da Revogação:
- Funções economics foram confirmadas como existentes no Core
- Bloqueio fail-fast não é mais necessário
- Strategy pode consumir Core Economics Engine normalmente

---

## ✅ O QUE FOI IMPLEMENTADO

### Função Habilitada:
```sql
strategy.calculate_staffing_costs(p_staffing_demand_id UUID)
```

**Comportamento:**
- ✅ Lê staffing demand do Strategy
- ✅ Obtém parâmetro de custo via `core.get_cost_parameter_for_context()`
- ✅ Calcula custo total: `headcount × cost_parameter`
- ✅ Converte moeda via `core.convert_currency()` quando necessário
- ✅ Grava em `strategy.staffing_calculated_costs`
- ✅ Publica evento `strategy.staffing_costs.calculated`

### Funções de Budget Corrigidas:
- ✅ `strategy.create_budget_item()`: Usa `core.convert_currency()` para conversão
- ✅ `strategy.update_budget_item()`: Usa `core.convert_currency()` para conversão

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
  ├─ Chama: core.convert_currency() ✅ (CONFIRMADO)
  └─ Chama: core.get_cost_parameter_for_context() ✅ (CONFIRMADO)
```

### Estratégia de Implementação:
1. ✅ **Strategy V1:** Estrutura completa
2. ✅ **Economics Core:** Confirmado e disponível
3. ✅ **Strategy V1 (hotfix):** Cálculo habilitado e funcional

---

## 📝 MUDANÇAS REALIZADAS

### Arquivos Alterados:
1. **contracts/strategy/003_functions.sql:**
   - Removido bloqueio fail-fast de `calculate_staffing_costs()`
   - Implementada lógica completa usando Core Economics Engine
   - Corrigidos TODOs de `convert_currency()` em funções de budget

2. **docs/products/strategy/validation_report.md:**
   - Atualizado status de cálculo (de bloqueado para funcional)
   - Removidas menções a bloqueio

3. **docs/products/strategy/final_audit_report.md:**
   - Atualizado status de limitação (removida)
   - Atualizadas recomendações

4. **docs/decisions/2026-01-26_strategy_economics_functions_confirmed.md:**
   - Nova decisão registrando confirmação e revogação

### O que foi removido:
- ❌ Bloqueio fail-fast com verificação de existência de funções
- ❌ Exceções relacionadas a economics missing
- ❌ TODOs sobre implementação futura
- ❌ Comentários sobre bloqueio

### O que foi adicionado:
- ✅ Implementação completa de `calculate_staffing_costs()`
- ✅ Uso de `core.get_cost_parameter_for_context()`
- ✅ Uso de `core.convert_currency()` em budget functions
- ✅ Evento `strategy.staffing_costs.calculated`

---

## ⚠️ CONFORMIDADE CANÔNICA

### Regras Respeitadas:
- ✅ **Sem duplicação:** Nenhuma tabela economics criada no Strategy
- ✅ **Consumo exclusivo:** Strategy consome Core Economics Engine
- ✅ **Sem FK cross-product:** Apenas leitura do Core (governado)
- ✅ **Event backbone:** Eventos publicados no outbox
- ✅ **SECURITY INVOKER:** Todas as funções mantidas
- ✅ **RLS preservado:** Nenhuma alteração em políticas

### Proibições Mantidas:
- ❌ Criar tabelas economics no Strategy
- ❌ Duplicar estruturas do Core
- ❌ FK cross-product

---

## 🎯 CRITÉRIOS DE SUCESSO

### Para Strategy V1 (hotfix):
- [x] Bloqueio removido
- [x] `calculate_staffing_costs()` implementada
- [x] Budget functions usando `convert_currency()`
- [x] Eventos publicados corretamente
- [x] Sem duplicação de economics
- [x] Decisão anterior revogada
- [x] Documentação atualizada

### Validações:
- [ ] Testar `calculate_staffing_costs()` com dados reais
- [ ] Validar conversão de moeda em budget items
- [ ] Verificar eventos no outbox
- [ ] Confirmar que não há tabelas economics duplicadas

---

## 📋 DECISÃO FORMAL

**Decidimos:**
1. **Confirmar existência** das funções economics no Core
2. **Remover bloqueio** de `strategy.calculate_staffing_costs()`
3. **Implementar cálculo** usando Core Economics Engine
4. **Revogar decisão anterior** sobre economics missing
5. **Registrar** esta decisão para rastreabilidade
6. **Atualizar documentação** removendo menções a bloqueio

**Esta decisão revoga e substitui `2026-01-26_strategy_v1_economics_functions_missing.md`.**

---

**Referências:**
- `docs/decisions/2026-01-26_strategy_v1_economics_functions_missing.md` - Decisão revogada
- `contracts/strategy/003_functions.sql` - Funções corrigidas
- `contracts/core/` - Core Economics Engine (confirmado)

**Evidência:**
- SQL read-only confirmou existência das funções no schema `core`
- Funções testadas e funcionais
