# HUMANTRÍA — States: Loading, Empty, Error, Success

## Estados Obrigatórios

Toda tela que consome dados assíncronos deve tratar explicitamente:

### 1. Loading
- Estado inicial durante fetch
- Feedback visual claro (spinner, skeleton, progress)
- Não renderizar conteúdo parcial durante loading

### 2. Empty
- Quando não há dados para exibir
- Mensagem contextual e ação sugerida
- Nunca mostrar "undefined" ou "null"

### 3. Error
- Erros de rede, validação, permissão
- Mensagem clara e ação de recuperação
- Logging para diagnóstico

### 4. Success
- Conteúdo renderizado apenas quando dados válidos
- Feedback de ações bem-sucedidas (toast, banner)

## Padrão de Implementação

```tsx
if (loading) return <LoadingState />
if (error) return <ErrorState error={error} />
if (empty) return <EmptyState />
return <Content data={normalizedData} />
```

## Regras

1. Nunca renderizar durante loading
2. Sempre normalizar dados antes de renderizar
3. Estados são explícitos, não implícitos
4. Mensagens de erro são acionáveis
