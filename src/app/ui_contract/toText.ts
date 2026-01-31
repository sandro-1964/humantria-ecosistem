/**
 * UI Contract: normalização para exibição (05_ui_contract.md).
 * Nunca renderizar objetos/arrays crus; usar toText/renderValue.
 */
export function toText(value: unknown): string {
  if (value === null || value === undefined) return ''
  if (typeof value === 'string' || typeof value === 'number' || typeof value === 'boolean') return String(value)
  if (typeof value === 'object') return '[object]'
  return String(value)
}
