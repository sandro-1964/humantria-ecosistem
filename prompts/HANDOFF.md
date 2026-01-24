# PROMPT HANDOFF — HUMANTRÍA (CANÔNICO)

Você é o DEV/Capitão que está encerrando o chat/trabalho atual.
Objetivo: produzir uma PASSAGEM DE COMANDO que evite perda cognitiva.

## LEITURA OBRIGATÓRIA
Antes de escrever, leia:
- docs/_canon/* (todo)
- docs/decisions/* (se existir)
- docs/audits/* (se existir)
- contracts/* (se existir)
- ui/* (se existir)

## SAÍDA OBRIGATÓRIA (copiar exatamente esta estrutura)

1) RESUMO EXECUTIVO (5–10 linhas)
- O que foi feito
- O que está funcionando (evidência)
- O que quebrou / riscos

2) ESTADO DO REPO (factual)
- Branch atual:
- Último commit:
- Tags existentes relevantes:
- Migrations aplicadas (nomes/ids):
- Arquivos criados/alterados (lista curta por pasta):

3) SAÚDE DA PLATAFORMA (checklist)
- DB Contract: OK/NO + evidência
- RLS: OK/NO + evidência
- Seeds: OK/NO + evidência
- DIAG: OK/NO + evidência
- UI Runtime: OK/NO + evidência
- Observabilidade: OK/NO + evidência

4) DECISÕES TOMADAS / DECISÕES ABERTAS
- Tomadas (com link para docs/decisions ou referência objetiva)
- Abertas (o que falta decidir; impacto de adiar)

5) PENDÊNCIAS PRIORIZADAS (Top 10)
Para cada item:
- O que é
- Por que importa
- Onde mexer (arquivo/pasta)
- Critério de pronto (teste/DIAG/evidência)

6) LIÇÕES APRENDIDAS (curto e acionável)
- 5 bullets no máximo, focados em evitar repetição

7) PRÓXIMO PASSO “NON-STOP”
- Um único bloco com o próximo prompt recomendado:
  (ex.: “use prompts/prompt_dev_nonstop.md para implementar X”)

## REGRAS
- Não inventar fatos.
- Não sugerir ação manual fora do Cursor/MCP.
- Tudo deve ter referência em arquivo, commit, log ou evidência.
