function safeStringify(value: unknown): string {
  const seen = new WeakSet<object>()

  return JSON.stringify(
    value,
    (_key, v: unknown) => {
      if (v instanceof Error) {
        return { name: v.name, message: v.message }
      }
      if (typeof v === 'bigint') return v.toString()
      if (typeof v === 'symbol') return v.description ? `Symbol(${v.description})` : 'Symbol'
      if (typeof v === 'function') return '[function]'
      if (v && typeof v === 'object') {
        if (seen.has(v as object)) return '[circular]'
        seen.add(v as object)
      }
      return v
    },
    2,
  )
}

function truncate(s: string, max = 800): string {
  if (s.length <= max) return s
  return `${s.slice(0, max)}…`
}

export function toText(value: unknown): string {
  if (value === null || value === undefined) return ''

  if (typeof value === 'string') return value
  if (typeof value === 'number') return Number.isFinite(value) ? String(value) : ''
  if (typeof value === 'boolean') return value ? 'true' : 'false'
  if (typeof value === 'bigint') return value.toString()
  if (typeof value === 'symbol') return value.description ? `Symbol(${value.description})` : 'Symbol'
  if (typeof value === 'function') return ''

  if (value instanceof Date) return value.toISOString()
  if (value instanceof Error) return truncate(`${value.name}: ${value.message}`)

  // Contract: never render raw objects/arrays -> stringify to safe text.
  try {
    return truncate(safeStringify(value))
  } catch {
    return '[unserializable]'
  }
}

