# DECISÃO — Política Oficial de Branches

Data: 2026-01-24
Status: ATIVA (canônica)

## Objetivo
Eliminar risco de retrabalho, conflitos e perda de histórico.

## Regras

### dev
Fonte viva do desenvolvimento.
Todo trabalho ocorre aqui.
Canon, contracts, produtos e prompts nascem aqui.

### main
Somente release/deploy.
Proibido desenvolvimento direto.

## Publicação permitida
A) Pull Request dev → main (padrão)
B) Reset main = dev (exceção com decisão formal)

## Proibições
- Sem commits diretos em main
- Sem prompts DEV na main
- Sem MCP na main
- Sem SQL manual na main

## Justificativa
Separar:
desenvolvimento (risco controlado)
de
release (estável)

Evita conflitos, perda cognitiva e divergência histórica.
