export type StateCopy = {
  title: string
  message: string
}

/**
 * Microcopy mínima e reutilizável (V1).
 * Preferir i18n (`states.*`) como fonte; este arquivo serve como “shape” único
 * e utilitários de fallback quando necessário.
 */
export function normalizeStateCopy(input: Partial<StateCopy> | null | undefined): Partial<StateCopy> {
  if (!input) return {}
  return {
    title: input.title ?? undefined,
    message: input.message ?? undefined,
  }
}

