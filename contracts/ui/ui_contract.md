# HUMANTRÍA — UI CONTRACT (LOCAL) — V1

Status: BLOQUEANTE  
Escopo: qualquer código React/UI deste repositório

> Este contrato é a **fonte canônica local** para UI Runtime do Foundation.  
> Ele deve ser compatível com `docs/_canon/05_ui_contract.md` (que continua soberano).

━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRINCÍPIO FUNDAMENTAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━

A UI NUNCA renderiza dados crus.

Toda renderização passa por normalização controlada:

Backend → DTO → Adapter/Normalizer → UI

━━━━━━━━━━━━━━━━━━━━━━━━━━━
REGRAS ABSOLUTAS (BLOQUEANTES)
━━━━━━━━━━━━━━━━━━━━━━━━━━━

1) É PROIBIDO renderizar:
- objetos
- arrays
- jsonb
- funções
- estruturas desconhecidas

2) JSX só recebe:
- string
- number
- boolean
- ReactNode seguro (derivado de valores primitivos)

3) Toda tela deve usar uma camada de adapter:
- `toText(value)` / `renderValue(value)` (ou equivalente) antes de renderizar

4) Providers devem ser:
- estáveis
- determinísticos
- sem efeitos colaterais na hidratação

5) Proibido “tela em branco”:
- toda rota/página tem `loading`, `empty`, `error`, `success`

━━━━━━━━━━━━━━━━━━━━━━━━━━━
DOMÍNIOS (VISUAL vs RUNTIME)
━━━━━━━━━━━━━━━━━━━━━━━━━━━

1) Lovable domina (VISUAL):
- `src/design-system/*`
- `src/shell/*`

Regra: estes caminhos são “propriedade visual”. O runtime **não deve** reescrever design system/shell; apenas integrar (props/hooks).

2) Cursor domina (RUNTIME):
- `src/providers/*`
- `src/hooks/*`
- `src/services/*`
- `src/lib/*`
- `src/app/*`

Regra: estes caminhos são “propriedade runtime”. O Lovable **não pode sobrescrever**.

━━━━━━━━━━━━━━━━━━━━━━━━━━━
EVIDÊNCIA, AUDITORIA E INCIDENTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Toda ação relevante deve gerar evidência/auditoria, usando:
- Incident Log (UI) com fingerprint + contexto
- Audit trail (DB): `foundation.audit_log_functional` via RPC

Quando ocorrer erro:
- mostrar `error state` com instruções
- expor link para `/__diag`
- registrar incidente (best-effort; falha de log não pode causar crash)

━━━━━━━━━━━━━━━━━━━━━━━━━━━
DIAG (PERMANENTE)
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Rotas obrigatórias:
- `/__diag`
- `/__diag/meta`

Funções:
- testar render mínimo
- inspecionar providers (auth/tenant/rbac/flags)
- diagnosticar falhas de dados vs infraestrutura

Nunca remover.

