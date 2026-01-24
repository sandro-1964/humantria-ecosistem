HUMANTRÍA — Escopo & Princípios Canônicos (V1.0)
Status: IMUTÁVEL (só muda por decisão formal registrada)
Finalidade: impedir deriva de escopo, evitar reinterpretação, alinhar produto/engenharia/design

1. O que é a HUMANTRÍA

A HUMANTRÍA é uma Plataforma de Governança, Decisão e Inteligência para Capital Humano.
Ela existe para tornar decisões humanas (pessoas, estrutura, trabalho, risco, conformidade) mais seguras, explicáveis, auditáveis e consistentes, por meio de:

Decisão governada (aprovação, exceção, alçada, justificativa)

Evidência rastreável (cadeia de evidências e histórico)

Multi-tenancy enterprise (isolamento total por cliente)

Auditabilidade nativa (quem, quando, por quê, com qual evidência)

Observabilidade e diagnóstico (sistema observado = sistema controlado)

IA governada (conselheira — nunca fonte de verdade)

2. O que a HUMANTRÍA NÃO é (proibições)

A HUMANTRÍA não é, por padrão:

HRIS completo (cadastro operacional “de tudo”)

Folha de pagamento / motor de ponto / ERP

BI genérico sem cadeia de evidência

Ferramenta de execução automática (“IA decidiu e executou”)

Regra: a HUMANTRÍA pode se conectar a sistemas operacionais (ATS/HRIS/ERP/folha), mas nasce para governar decisões, não para substituir tudo.

3. Tese central: “Decisão, não execução”

A unidade de valor da plataforma é a decisão:

CRUD aqui é CRUD de decisão + evidência, não “cadastro pelo cadastro”.

Execuções operacionais podem ocorrer fora (ou por automação), desde que:

a decisão exista,

a evidência seja registrável,

haja rastreabilidade e auditoria.

4. Base e Teto

BASE (imutável e transversal)

FOUNDATION: tenancy, segurança, RBAC, auditoria, eventos, privacidade/LGPD estrutural, governança de IA, billing infra, flags/quotas, templates, POC (owner console).

CORE: semântica canônica do cliente: pessoas, estrutura, jobs/levels, cost centers, vínculos e importação inicial.

TETO (cresce por produto)
Produtos adicionam novos tipos de decisões (não “mais telas soltas”).
Quanto mais produtos, maior a capacidade de visão macro (Intelligence).

5. IA (papel e limites)

IA é conselheira. Pode:

sugerir, explicar, resumir, analisar, detectar inconsistências, simular cenários.

IA não pode:

criar fatos,

executar decisões críticas sem humano,

alterar dados sensíveis sem governança,

operar “fora” de auditoria.

Obrigatório em todo uso de IA: finalidade, modelo/provedor, custo/limites, evidência usada, aprovação humana, registro auditável.

6. Princípios inegociáveis (mandamentos)

Multi-tenant hard (isolamento é contrato)

RLS obrigatório (toda tabela sensível)

Sem FK cross-product

Bridge-first (event backbone/outbox como cidadão de 1ª classe)

Runtime governado (UI com contrato, DIAG, observabilidade)

Evidência > opinião

Contrato > interpretação

Um produto por vez (evita pulverização cognitiva)

7. Critério de “entrega real”

Uma entrega só é “real” se permite:
navegar → decidir → ver evidência → aprovar → auditar → explicar por quê → registrar evento.

d