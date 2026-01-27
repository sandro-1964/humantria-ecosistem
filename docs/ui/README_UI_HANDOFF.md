# HUMANTRÍA — UI Handoff para Lovable

## Contexto

Este repositório segue arquitetura incremental. Lovable edita **somente**:
- `src/design-system/` (tokens, tema, componentes base)
- `src/shell/` (layout, header, sidebar, footer)
- `src/app/` (páginas e containers)
- `src/assets/` (brand, product-icons)

**Runtime, backend, e lógica de negócio são Cursor-only.**

## Estrutura Criada

### Design System
- `src/design-system/tokens.ts` → tokens de design (cores, espaçamentos, tipografia)
- `src/design-system/theme.css` → CSS variables para temas dark/light
- `src/design-system/index.ts` → exports públicos

### Shell
- `src/shell/AppLayout.tsx` → container principal
- `src/shell/Header.tsx` → cabeçalho com branding
- `src/shell/Sidebar.tsx` → menu lateral de produtos
- `src/shell/FooterTech.tsx` → rodapé técnico

### App (Páginas)
- `src/app/home/HomePage.tsx` → home macro
- `src/app/strategy/StrategyHome.tsx` → container do produto Strategy

### Assets
- `src/assets/brand/` → logos (dark/light, completo/compacto)
- `src/assets/product-icons/` → ícones de produtos

## Contratos UI

Todos os contratos estão em `contracts/ui/`:
- `00_ui_rules.md` → regras fundamentais (nunca renderizar objetos/arrays)
- `01_routing_and_layout.md` → estrutura de rotas e layout
- `02_states_loading_empty_error_success.md` → tratamento de estados
- `03_a11y_and_responsive.md` → acessibilidade e responsividade
- `04_icons_and_brand_usage.md` → uso de logos e ícones
- `05_permission_guards_and_density.md` → guards de permissão e densidade

## Regras Absolutas

1. **Nunca renderizar dados crus** (objetos, arrays, JSONB)
2. **Sempre normalizar** antes de renderizar (adapter layer)
3. **DIAG route** (`/__diag`) é permanente, nunca remover
4. **Multi-tenant** em toda lógica de dados
5. **RLS** em todas as queries

## Próximos Passos (Lovable)

1. Implementar componentes do design system baseado em tokens
2. Finalizar layout do shell (Header, Sidebar, FooterTech)
3. Criar páginas de produto (começar com Strategy)
4. Integrar rotas (React Router ou similar)
5. Implementar estados (loading, empty, error, success)
6. Adicionar guards de permissão
7. Testar responsividade e a11y

## Não Fazer

- ❌ Modificar `src/App.tsx` ou `src/main.tsx` (Cursor-only)
- ❌ Criar lógica de backend ou runtime
- ❌ Criar novo repo dentro de `/ui`
- ❌ Apagar arquivos existentes
- ❌ Criar FK cross-product
