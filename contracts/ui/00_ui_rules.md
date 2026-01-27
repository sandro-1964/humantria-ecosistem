# HUMANTRÍA — UI Rules (Canônico)

Status: OBRIGATÓRIO  
Escopo: qualquer código React/Lovable/UI

## Princípio Fundamental

A UI NUNCA renderiza dados crus. Toda renderização passa por normalização controlada. Frontend é camada de apresentação, não interpretador de JSON.

## Regras Absolutas

### 1. Proibido renderizar
- Objetos
- Arrays
- JSONB
- Funções
- Estruturas desconhecidas

### 2. JSX só recebe
- `string`
- `number`
- `boolean`
- `ReactNode` seguro

### 3. Adapter obrigatório
Toda tela usa `renderValue()` / `toText()` para normalizar dados antes de renderizar.

### 4. Nunca fazer
```tsx
{data}
{obj}
{json}
{metadata}
```

### 5. Providers
- Estáveis
- Determinísticos
- Sem efeitos colaterais na hidratação

## Adapter Layer (Obrigatório)

Fluxo: `Backend → DTO → Adapter → UI`

Nunca: `Backend → UI direto`

## DIAG (Permanente)

A rota `/__diag` é obrigatória para:
- Testar sem providers
- Isolar bugs de hidratação
- Validar se erro é dado ou infraestrutura

Nunca remover.

## Definição

Se um valor quebrar a UI, o erro é do CONTRATO, não do React.
