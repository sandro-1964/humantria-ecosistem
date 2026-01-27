# HUMANTRÍA — Permission Guards and Density

## Permission Guards

### RBAC Integration
Toda rota e componente sensível deve verificar permissões antes de renderizar.

### Padrão
```tsx
const { hasPermission } = usePermissions()
if (!hasPermission('strategy:read')) {
  return <AccessDenied />
}
```

### Níveis
- Route-level: bloqueia acesso à rota
- Component-level: oculta/seleciona funcionalidades
- Action-level: desabilita botões/ações

## Density Control

### Atributo de Tema
Controlado via `data-density` no elemento raiz:
- `compact`: mais informações visíveis
- `comfortable`: padrão (default)
- `spacious`: mais espaço entre elementos

### Aplicação
- Espaçamentos (padding, margin)
- Altura de linhas (line-height)
- Tamanho de fontes (opcional, manter legibilidade)

### Regras
1. Density não altera tamanho de fonte abaixo do mínimo legível
2. Density é preferência do usuário, persistida
3. Aplicação é consistente em toda UI
