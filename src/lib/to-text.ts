export function toText(value: unknown): string {
  if (value === null || value === undefined) return ''
  if (typeof value === 'string') return value
  if (typeof value === 'number') return String(value)
  if (typeof value === 'boolean') return value ? 'true' : 'false'
  if (value instanceof Date) return value.toISOString()

  // Contract: never render raw objects/arrays -> stringify to text safely.
  try {
    return JSON.stringify(value)
  } catch {
    return '[unserializable]'
  }
}

