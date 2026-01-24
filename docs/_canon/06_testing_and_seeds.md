# HUMANTRÍA — TESTING & SEEDS (CANÔNICO)

Status: OBRIGATÓRIO
Escopo: todos os produtos

━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRINCÍPIO
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Sem dados realistas, não existe validação.

Seed é parte do produto, não acessório.

━━━━━━━━━━━━━━━━━━━━━━━━━━━
TIPOS DE BASE
━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. DEMO
- pequena
- didática
- venda/apresentação

2. REALISTA
- volumes médios
- cenários reais
- testes funcionais

3. STRESS
- alto volume
- performance
- concorrência

━━━━━━━━━━━━━━━━━━━━━━━━━━━
OBRIGAÇÕES DO DEV
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Cada GS FULL deve entregar:

- seed_demo.sql
- seed_realistic.sql
- queries de validação
- evidências no validation_report.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━
TESTES
━━━━━━━━━━━━━━━━━━━━━━━━━━━

DEV executa:
- integridade de contratos
- RLS
- funções governadas
- eventos
- consultas críticas

Humano:
- valida negócio
- aprova evidência

━━━━━━━━━━━━━━━━━━━━━━━━━━━
PROIBIDO
━━━━━━━━━━━━━━━━━━━━━━━━━━━

❌ testar com banco vazio
❌ testar manualmente sem seed
❌ criar seed depois do produto pronto
