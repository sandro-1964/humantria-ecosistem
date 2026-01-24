# HUMANTRÍA — CHAT ZERO GUARDIAN (PROMPT + REGRAS BLOQUEANTES)

Status: CANÔNICO · BLOQUEANTE  
Aplicação: todo novo Chat, todo novo DEV, todo novo “capitão”, todo novo ciclo.  
Objetivo: impedir reinterpretação, impedir arquitetura esquizofrênica, impedir “Cursor projetando”.

---

## 1) POR QUE ESTE DOCUMENTO EXISTE (CONTEXTO)
A HUMANTRÍA já sofreu falhas por **pulverização cognitiva**:
- múltiplos chats reinterpretando decisões
- versões “novas” substituindo regras antigas sem registro
- execução técnica sem guard-rails

Este documento é o **airbag de governança**:
ele existe para garantir que **ninguém recrie arquitetura** sob pressão.

---

## 2) REGRA DE SOBERANIA (NÃO NEGOCIÁVEL)
A partir deste ponto:

### ✅ Sandro (Platform Owner) decide:
- escopo, prioridades, ordem de entrega
- o que é Foundation / Core / Produto
- o que entra / não entra (negócio)

### ✅ “Nelson/CEO Técnico” decide:
- arquitetura, contratos, boundaries, modelagem, padrões
- como implementar com segurança e rastreabilidade

### ❌ Cursor (DEV) NÃO decide:
- arquitetura
- contratos de dados por conta própria
- modelo de RLS
- estrutura de schemas
- padrões
Cursor **apenas executa** o que já está decidido.

---

## 3) PROIBIÇÕES BLOQUEANTES
É TERMINANTEMENTE PROIBIDO (bloqueia execução):

1. **Gerar contratos SQL (Foundation/Core/Produtos) sem aprovação explícita do CEO Técnico.**
2. **Pedir “faça o foundation/core” ao Cursor** como se fosse projetista.
3. **Alterar banco manualmente** (console/SQL solto) fora do MCP + contracts/.
4. **Criar tabelas “ad-hoc”** no meio do caminho.
5. **Fechar GS/versão** sem validation_report.md + final_audit_report.md.
6. **Reescrever decisão antiga** sem registrar substituição em decisions.md.

---

## 4) REGRA OPERACIONAL (SEMPRE)
Todo novo chat começa assim:

### 4.1 Leitura obrigatória
Antes de qualquer ação, o executor deve ler integralmente:
- `docs/_canon/*`

Se não leu → execução inválida.

### 4.2 Ordem fixa do trabalho (sem improviso)
A ordem canônica é:

1) Estrutura de pastas + branches (se ainda não existir)  
2) Canon (docs/_canon/) consolidado e lido  
3) Contratos (contracts/) definidos e aprovados  
4) Execução via MCP (migrations/seeds)  
5) Validação (validation_report.md)  
6) Auditoria (final_audit_report.md)  
7) Tag (somente após aprovação humana)  
8) Registro de decisão e pendências

---

## 5) COMANDO DE ABERTURA (PROMPT PADRÃO DO CHAT ZERO)
Copie e cole SEM ALTERAR quando abrir novo chat:

> Você está entrando no projeto HUMANTRÍA.  
> Antes de qualquer ação, leia integralmente `docs/_canon/*`.  
> Você NÃO está autorizado a projetar arquitetura, banco, contratos ou padrões.  
> Você só pode executar o que for explicitamente definido pelo Platform Owner e pelo CEO Técnico.  
> Se surgir ambiguidade, você deve parar e solicitar decisão — não improvisar.

---

## 6) “CHECKPOINT” DE SEGURANÇA (ANTI-RETRABALHO)
Antes de qualquer execução técnica, confirme em texto:

- [ ] Li integralmente `docs/_canon/*`
- [ ] Não vou criar contratos SQL por iniciativa própria
- [ ] Vou executar somente o que foi aprovado
- [ ] Toda mudança terá evidência (reports)
- [ ] Não haverá SQL manual fora do MCP

---

## 7) REGRA FINAL (SENTENÇA CANÔNICA)
**Arquitetura não é conversa. Arquitetura é contrato.**  
Se não está no Canon e não está em contracts/, **não existe**.

— FIM —
