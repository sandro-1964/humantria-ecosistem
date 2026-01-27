# HUMANTRÍA — Routing and Layout

## Estrutura de Rotas

### Rotas Principais
- `/` → HomePage (macro)
- `/strategy` → StrategyHome (container do 1º produto)
- `/__diag` → Diagnóstico (obrigatório, permanente)

### Layout Shell
Todas as páginas (exceto `/__diag`) usam `AppLayout`:
- Header (branding, navegação, perfil)
- Sidebar (menu de produtos)
- Conteúdo principal (páginas)
- FooterTech (versão, ambiente, links técnicos)

## Componentes de Layout

### AppLayout
Container principal que envolve todas as páginas autenticadas.

### Header
- Logo (dark/light conforme tema)
- Navegação principal
- Perfil do usuário
- Notificações (se aplicável)

### Sidebar
- Menu de produtos (Strategy, Talent, Ops, etc.)
- Estado colapsado/expandido
- Indicadores de acesso por permissão

### FooterTech
- Versão da aplicação
- Ambiente (demo/trial/prod)
- Links técnicos (docs, suporte)

## Regras

1. Layout é responsável apenas por estrutura, não por lógica de negócio
2. Páginas são containers de conteúdo, não componentes de layout
3. Rotas devem ser declarativas e centralizadas
4. Navegação respeita permissões RBAC
