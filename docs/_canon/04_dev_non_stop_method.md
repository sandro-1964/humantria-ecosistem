HUMANTRÍA — Método DEV NON-STOP (V1.0)
Status: BLOQUEANTE
Objetivo: eliminar ciclos longos, perda cognitiva e “quase pronto”

1. Fluxo NON-STOP (único)

Implementar → Validar com evidência → Preencher validation_report.md → Auditoria final → Tag (com aprovação humana) → Fechar

2. Papéis (responsabilidade)

DEV (Cursor/MCP): executa tudo técnico (DB, contracts, seeds, testes, DIAG, relatórios).

Humano: revisa evidências + autoriza explicitamente a tag.

3. Proibições

❌ alternar de branch no meio do ciclo sem necessidade canônica

❌ rodar SQL manual fora do contrato

❌ fechar sem evidência

❌ “testar no olho” como substituto de teste/seed/diag

4. Artefatos obrigatórios por ciclo

contracts/... atualizados

seeds executados e registrados

validation_report.md (evidência objetiva)

final_audit_report.md (aprovado/bloqueado)

DIAG PASS/FAIL documentado

decisão de tag registrada

5. Gate final (antes da TAG)

O DEV para antes da tag e apresenta:

resumo do escopo entregue

evidências

riscos/dívida técnica

recomendação “tag / não tag”
A tag só ocorre após aprovação humana.