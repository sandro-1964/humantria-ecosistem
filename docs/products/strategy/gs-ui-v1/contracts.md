GS-UI-V1 — Contracts (UI Integration)
Escopo

IN: Integração visual do kit Lovable (componentes/layout/estilos) nas páginas do produto Strategy já existentes + AppShell.
OUT: DB, SQL contracts, RPCs, testes de integração, regras de negócio, seeds, RLS.

Caminhos canônicos (fonte de verdade)

Kit Lovable importado: src/ui/lovable/**

Export standalone arquivado (não usar em runtime): ui/lovable/_archived_root/**

Páginas Strategy atuais (fonte funcional): src/app/pages/strategy/**

Shell atual: src/shell/AppShell.tsx

Router atual: src/app/router/** (ou equivalente existente no repo)

CSS Lovable carregado em: src/main.tsx

Contratos obrigatórios

UI Contract

Toda renderização de dados deve passar por toText() / renderValue() (conforme docs/_canon/05_ui_contract.md).

Proibido renderizar objetos/arrays/JSON crus em JSX.

Não alterar rotas

Paths de Strategy permanecem exatamente como estão.

Não renomear rotas, não mover “a lógica” de roteamento.

Não alterar chamadas de dados

Não mudar hooks, queries, mutations, clients ou assinaturas de RPCs.

Apenas trocar JSX/layout e componentes visuais.

Lovable como “skin”, não como app

Não ativar o app standalone do Lovable.

Reutilizar somente: src/ui/lovable/components/**, src/ui/lovable/styles/**, e utilitários necessários.

Regras de integração

Preferir imports via adapters (um ponto único), para reduzir acoplamento:

src/app/strategy/components/lovable.ts reexporta componentes Lovable usados pelo Strategy.

Se existir alias @/ no kit Lovable, resolver via config do repo (tsconfig/vite) ou usar adapters com imports relativos, sem espalhar correções por dezenas de arquivos.

Critérios de aceite (PASS/FAIL)

PASS

npm run build passa.

Páginas Strategy continuam funcionando com os mesmos dados/fluxos (sem regressões de lógica).

Nenhum JSON cru aparece na tela (UI Contract OK).

Sidebar/AppShell mantém regras de visibilidade por role (não abrir acesso).

FAIL

Qualquer alteração em DB/RPC/contratos.

Mudança de rotas/paths.

Build quebrado ou imports Lovable espalhados sem padrão.

Evidências mínimas

git diff --stat

Log do npm run build (pass)

Lista de arquivos tocados (Strategy pages + Shell + adapters + config/estilos, no máximo)