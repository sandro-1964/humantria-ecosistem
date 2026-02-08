-- HUMANTRÍA — GS-PATCH FK Cleanup V1 — Introspecção (somente leitura)
-- Lista todas as FKs onde table_schema = 'strategy' e referenced_schema = 'core'.
-- Executar via MCP (execute_sql) e colar resultado no validation_report.md.
-- Usa pg_catalog (information_schema pode não expor ref_schema corretamente em alguns ambientes).

SELECT
    n1.nspname AS table_schema,
    c1.relname AS table_name,
    a1.attname AS column_name,
    con.conname AS constraint_name,
    n2.nspname AS referenced_schema,
    c2.relname AS referenced_table,
    a2.attname AS referenced_column
FROM pg_constraint con
JOIN pg_class c1 ON c1.oid = con.conrelid
JOIN pg_namespace n1 ON n1.oid = c1.relnamespace
JOIN pg_attribute a1 ON a1.attrelid = c1.oid AND a1.attnum = ANY(con.conkey) AND a1.attisdropped = false
JOIN pg_class c2 ON c2.oid = con.confrelid
JOIN pg_namespace n2 ON n2.oid = c2.relnamespace
JOIN pg_attribute a2 ON a2.attrelid = c2.oid AND a2.attnum = ANY(con.confkey) AND a2.attisdropped = false
WHERE con.contype = 'f'
  AND n1.nspname = 'strategy'
  AND n2.nspname = 'core'
ORDER BY n1.nspname, c1.relname, a1.attname;
