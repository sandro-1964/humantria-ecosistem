# Próximos passos — Fase B (integrar Supabase)

**Objetivo:** Checklist para ligar Supabase quando quisermos, sem quebrar DEMO MODE.

---

## Variáveis de ambiente (Vite)

Padronizadas no app:

- `VITE_SUPABASE_URL` — URL do projeto Supabase (ex.: `https://xxx.supabase.co`)
- `VITE_SUPABASE_ANON_KEY` — chave anônima (pública) do projeto

Se estiverem ausentes, o app continua: DEMO funciona 100%; tela de Acesso exibe aviso "Supabase não configurado".

---

## Checklist para ligar Supabase depois

1. **Criar projeto no Supabase** (se ainda não existir).
2. **Copiar `.env.example` para `.env`** (ou criar `.env` com as chaves).
3. **Preencher no `.env`:**
   - `VITE_SUPABASE_URL=https://<project-ref>.supabase.co`
   - `VITE_SUPABASE_ANON_KEY=<anon-key>`
4. **Reiniciar o dev server** (`npm run dev`) para carregar as variáveis.
5. **Garantir que o schema/RLS e seeds** (contracts) estão aplicados no banco (migrations/patches já executados).
6. **Testar fluxo real:** sair do DEMO, na tela de Acesso fazer login com usuário do Supabase; conferir tenant e RBAC vindos do JWT/banco.
7. **Manter DEMO:** "Entrar em DEMO" e "Escolher perfil DEMO" continuam disponíveis na tela de Acesso; DEMO não depende de env.

---

## Comportamento atual (sem env)

- **Demo ativo:** sessão local, tenant/RBAC fake, Home usa `demo-seed` (KPIs/charts fake).
- **Demo inativo e env ausente:** tela de Acesso com aviso "Supabase não configurado"; cadastro manual não é obrigatório (usuário pode usar DEMO).
- **Demo inativo e env preenchido:** tela de Acesso normal; login via Supabase Auth; dados reais do banco.

---

## Arquivos relevantes

- Leitura de env: `src/services/supabase/client.ts` (`hasSupabaseEnv()`, `getSupabaseClient()`).
- Auth: `src/providers/auth/AuthProvider.tsx` (usa `hasSupabaseEnv()` antes de chamar Supabase).
- Aviso na tela de Acesso: `src/app/pages/auth/AuthPage.tsx` (`supabaseNotConfigured`).
- Stub de dashboard (demo): `src/services/demo/demo-seed.ts`; uso em `src/app/pages/foundation/FoundationHomePage.tsx` quando demo ativo.
