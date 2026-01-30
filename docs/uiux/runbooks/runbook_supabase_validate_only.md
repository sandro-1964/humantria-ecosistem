# Runbook — Validação Supabase (somente leitura)

**Objetivo:** Validar integração Supabase sem executar migrations nem alterar banco.

**Regras:** SEM migrations. SEM SQL de alteração. SOMENTE leitura + testes + evidências.

---

## 1. Pré-requisitos

- Branch `qa-t9-supabase-integration` (ou branch com T9 ativo).
- `.env.local` na raiz com `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` (não imprimir valores).
- MCP Supabase ativo no Cursor (ex.: `project-0-humantria-backend-supabase`).

---

## 2. Checar MCP (somente leitura)

Via MCP Supabase → `execute_sql`:

**Query — listar schemas:**

```sql
SELECT schema_name FROM information_schema.schemata
WHERE schema_name IN ('foundation','core','strategy','public') ORDER BY schema_name;
```

**Critério:** Resposta deve incluir `foundation`, `core`, `strategy`, `public`.

Se MCP falhar → parar e reportar.

---

## 3. Exposição de schemas na API (manual)

Para que `test:int` passe, o PostgREST do Supabase precisa expor os schemas customizados.

**Ação manual (fora do código):**

1. Acessar Supabase Dashboard → projeto alvo.
2. **Settings** → **API** → **Expose schemas** (ou equivalente).
3. Garantir expostos: `public`, `foundation`, `core`, `strategy`.

**Não automatizar este passo.** Após confirmação, prosseguir.

---

## 4. Rodar testes de integração

No terminal (raiz do repo):

```bash
npm run test:int
```

**Critério de aceite:**

- Exit code **0**.
- Todas as suites verdes (foundation.spec.ts, strategy.spec.ts).
- Nenhum erro "Invalid schema".

Se **FAIL** → parar e reportar. Não corrigir banco; verificar exposição de schemas (passo 3).

---

## 5. Evidências

Registrar em `docs/qa/t9_integration_report.md`:

- Resultado da query MCP (schemas).
- Resultado de `npm run test:int` (PASS/FAIL e trecho de log).
- Timestamp, branch, commit hash.

---

## 6. O que NÃO fazer

- Não executar migrations (001–005).
- Não executar DROP/CREATE/ALTER em policies ou schema.
- Não executar seed (005) sem GO explícito do comandante.
- Não usar Supabase SQL Editor para alterações.
- Não fazer merge nem tag sem validação humana.
