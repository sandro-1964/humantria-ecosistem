# HUMANTRÍA — UI CONTRACT (CANÔNICO)

Status: OBRIGATÓRIO
Escopo: qualquer código React/Lovable/UI

━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRINCÍPIO FUNDAMENTAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━

A UI NUNCA renderiza dados crus.

Toda renderização passa por normalização controlada.

Frontend é camada de apresentação, não interpretador de JSON.

━━━━━━━━━━━━━━━━━━━━━━━━━━━
REGRAS ABSOLUTAS
━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. É PROIBIDO renderizar:
   - objetos
   - arrays
   - jsonb
   - funções
   - estruturas desconhecidas

2. JSX só recebe:
   - string
   - number
   - boolean
   - ReactNode seguro

3. Toda tela usa:
   renderValue() / toText() (adapter obrigatório)

4. Nunca fazer:
   {data}
   {obj}
   {json}
   {metadata}

5. Providers devem ser:
   - estáveis
   - determinísticos
   - sem efeitos colaterais na hidratação

━━━━━━━━━━━━━━━━━━━━━━━━━━━
ADAPTER LAYER (OBRIGATÓRIO)
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Toda UI consome DTOs normalizados:

Backend → DTO → Adapter → UI

Nunca:
Backend → UI direto

━━━━━━━━━━━━━━━━━━━━━━━━━━━
DIAG (PERMANENTE)
━━━━━━━━━━━━━━━━━━━━━━━━━━━

A rota /__diag é obrigatória.

Funções:
- testar sem providers
- isolar bugs de hidratação
- validar se erro é dado ou infraestrutura

Nunca remover.

━━━━━━━━━━━━━━━━━━━━━━━━━━━
DEFINIÇÃO
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Se um valor quebrar a UI,
o erro é do CONTRATO, não do React.
