-- HUMANTRÍA — GS-PATCH FK Cleanup V1 — Validação pós-patch
-- 1) Reexecutar introspecção: deve retornar 0 linhas (nenhuma FK strategy→core).
-- 2) Amostras SELECT nas tabelas principais.
-- 3) Qualquer teste de write em transação com ROLLBACK.

-- =============================================================================
-- 1) Confirmação: zero FKs strategy → core
-- =============================================================================
SELECT
    n1.nspname AS table_schema,
    c1.relname AS table_name,
    a1.attname AS column_name,
    con.conname AS constraint_name,
    n2.nspname AS referenced_schema,
    c2.relname AS referenced_table
FROM pg_constraint con
JOIN pg_class c1 ON c1.oid = con.conrelid
JOIN pg_namespace n1 ON n1.oid = c1.relnamespace
JOIN pg_attribute a1 ON a1.attrelid = c1.oid AND a1.attnum = ANY(con.conkey) AND a1.attisdropped = false
JOIN pg_class c2 ON c2.oid = con.confrelid
JOIN pg_namespace n2 ON n2.oid = c2.relnamespace
WHERE con.contype = 'f'
  AND n1.nspname = 'strategy'
  AND n2.nspname = 'core'
ORDER BY n1.nspname, c1.relname, a1.attname;
-- Esperado: 0 rows.

-- =============================================================================
-- 2) Amostras SELECT (objectives, key_results, initiatives)
-- =============================================================================
SELECT 'strategy.objectives' AS tbl, COUNT(*) AS cnt FROM strategy.objectives
UNION ALL
SELECT 'strategy.key_results', COUNT(*) FROM strategy.key_results
UNION ALL
SELECT 'strategy.initiatives', COUNT(*) FROM strategy.initiatives;

SELECT id, tenant_id, code, title, owner_person_id, status
FROM strategy.objectives
ORDER BY created_at
LIMIT 5;

SELECT id, tenant_id, objective_id, code, title, owner_person_id, status
FROM strategy.key_results
ORDER BY created_at
LIMIT 5;

SELECT id, tenant_id, objective_id, code, title, owner_person_id, status
FROM strategy.initiatives
ORDER BY created_at
LIMIT 5;

-- =============================================================================
-- 3) Teste de write (opcional, em transação com ROLLBACK)
-- =============================================================================
-- BEGIN;
-- INSERT INTO strategy.objectives (tenant_id, code, title, methodology_type, cycle_type, cycle_start_date, cycle_end_date, owner_person_id)
-- VALUES (
--     '00000000-0000-0000-0000-000000000001',
--     'VALIDATION_TEST',
--     'Test row',
--     'okr',
--     'annual',
--     CURRENT_DATE,
--     CURRENT_DATE + 365,
--     (SELECT id FROM core.people WHERE tenant_id = '00000000-0000-0000-0000-000000000001' LIMIT 1)
-- );
-- ROLLBACK;
