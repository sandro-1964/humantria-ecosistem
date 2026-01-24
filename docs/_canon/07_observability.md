# HUMANTRÍA — OBSERVABILITY (CANÔNICO)

Status: OBRIGATÓRIO

━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRINCÍPIO
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Problema não observado é problema não resolvido.

━━━━━━━━━━━━━━━━━━━━━━━━━━━
CAMADAS
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Banco:
- audit_log
- events_outbox
- evidência versionada

Backend:
- logs estruturados
- erros rastreáveis

UI:
- incident log
- fingerprint
- /__diag

━━━━━━━━━━━━━━━━━━━━━━━━━━━
DIAG
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Toda app deve ter:

/__diag/*
/__diag/meta

Funções:
- testar sem providers
- comparar render mínimo
- diagnosticar hidratação

━━━━━━━━━━━━━━━━━━━━━━━━━━━
RELATÓRIOS
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Todo GS FULL deve gerar:

- validation_report.md
- final_audit_report.md

Sem relatório → GS não fecha
