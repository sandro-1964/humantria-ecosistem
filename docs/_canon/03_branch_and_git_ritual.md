HUMANTRÍA — Branch & Git Ritual (V1.0)
Status: IMUTÁVEL (evita caos de versões)

1. Branches permitidas (mínimo absoluto)

main — referência soberana e estável.

dev — integração contínua (quando adotado).

gs-<nn>-<slug> — somente quando existir GS real com risco/escopo fechado.

branches temporárias só se houver motivo auditável (ex.: hotfix crítico).

2. Regra de ouro

Branch existe para controlar decisão e rastreabilidade, não para playground.

3. Tags e releases

Toda entrega fechada gera TAG imutável.

Nunca sobrescrever tag.

Se colidir: criar sufixo -fixed ou -patch-N e registrar em auditoria.

4. Rito mínimo de commit

Todo commit relevante deve indicar:

o que mudou

por que mudou

impacto (DB/UI/Contracts/Seeds)

evidência (quando aplicável)

5. Rito de abertura e fechamento (resumo)

Abertura: escopo fechado + leitura do canon + plano + branch (se aplicável)

Fechamento: validação + evidência + auditoria + tag + registro final