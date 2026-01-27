# HUMANTRÍA — A11y and Responsive

## Acessibilidade (A11y)

### Obrigatório
- Semântica HTML correta (`<nav>`, `<main>`, `<header>`, `<footer>`)
- ARIA labels quando necessário
- Navegação por teclado funcional
- Contraste de cores (WCAG AA mínimo)
- Foco visível em elementos interativos

### Regras
1. Imagens têm `alt` descritivo
2. Formulários têm labels associados
3. Botões têm texto ou aria-label
4. Modais são focáveis e escapáveis

## Responsive

### Breakpoints (CSS Variables)
- Mobile: < 768px
- Tablet: 768px - 1024px
- Desktop: > 1024px

### Regras
1. Layout adapta-se a viewport
2. Sidebar colapsa em mobile
3. Tabelas são scrolláveis horizontalmente em mobile
4. Touch targets mínimos: 44x44px

## Densidade

Suporta três níveis:
- Compact: mais informações visíveis
- Comfortable: padrão
- Spacious: mais espaço entre elementos

Controlado via `data-density` no tema.
