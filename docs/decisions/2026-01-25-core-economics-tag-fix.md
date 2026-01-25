# Decision — Core Economics tag fix (no overwrite)

## Contexto
Foi criada a tag `core-economics-v1.0.0`. Identificamos que ela contém artefatos temporários (`temp_*`) gerados durante a montagem/execução (não canônicos).

## Decisão
- **Nenhuma TAG existente será sobrescrita.**
- A tag `core-economics-v1.0.0` permanece como **histórico**.
- A referência **ativa/canônica** será marcada por uma nova tag: `core-economics-v1.0.0-fixed`, contendo apenas artefatos canônicos (contracts + docs).

## Ação obrigatória
1) Remover `temp_*` do repositório (git rm)  
2) Bloquear `temp_*` no `.gitignore`  
3) Criar e publicar a tag `core-economics-v1.0.0-fixed`  
4) Abrir PR `core-patch-economics-v1 → dev`

## Resultado esperado
- Patch Core Economics fica **limpo, reprodutível e auditável**
- Sem risco de colisão de tags históricas
