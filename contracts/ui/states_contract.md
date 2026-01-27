# HUMANTRÍA — UI STATES CONTRACT (LOCAL) — V1

Status: BLOQUEANTE  
Escopo: estados assíncronos e mensagens do runtime

━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRINCÍPIO
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Proibido tela em branco.

Todo async tem estados explícitos e visíveis:
- loading: “o que está acontecendo agora”
- empty: “o que existe / o que fazer agora”
- error: “[o que aconteceu] + [por quê] + [o que fazer agora]”
- success: conteúdo normal

━━━━━━━━━━━━━━━━━━━━━━━━━━━
ESTADOS PADRÃO (TIPOS)
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Cada operação assíncrona deve expor no mínimo:
- `status`: `idle | loading | success | empty | error`
- `error`: `{ code?, message, detail?, correlationId? } | null`
- `retry()` quando aplicável

━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMPONENTES BASE (CONTRATO)
━━━━━━━━━━━━━━━━━━━━━━━━━━━

O runtime deve ter componentes reutilizáveis:
- `LoadingState`
- `EmptyState`
- `ErrorState`
- `AccessDeniedState`

Regras:
- devem aceitar strings/valores primitivos (já normalizados)
- devem suportar “saiba mais” apontando para `/__diag`

━━━━━━━━━━━━━━━━━━━━━━━━━━━
INCIDENT LOG (UI)
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Quando `error` ocorrer em operação relevante:
- registrar incidente (best-effort) em `foundation.audit_log_functional_insert`
- incluir fingerprint, rota, user/tenant (se disponível), e mensagem normalizada

Falha no registro **não pode** causar crash nem bloquear UI.

