# HUMANTRÍA — Design System

## Uso

### Tokens (TypeScript)

```tsx
import { tokens } from '@/design-system'

const primaryColor = tokens.colors.brand.primary
const spacing = tokens.spacing.md
```

### CSS Variables

Importe `theme.css` no root da aplicação:

```tsx
import '@/design-system/theme.css'
```

Use variáveis CSS nos componentes:

```css
.my-component {
  background: var(--bg-primary);
  color: var(--text-primary);
  padding: var(--spacing-md);
  border-radius: var(--radius-md);
}
```

### Tema Dark

Aplique `data-theme="dark"` no elemento raiz:

```tsx
<html data-theme="dark">
```

### Densidade

Aplique `data-density` no elemento raiz:

```tsx
<html data-density="compact">  // ou "comfortable" ou "spacious"
```

## Estrutura

- `tokens.ts` → tokens TypeScript (fonte de verdade)
- `theme.css` → CSS variables (derivado de tokens)
- `index.ts` → exports públicos
