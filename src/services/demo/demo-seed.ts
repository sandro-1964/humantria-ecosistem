/**
 * Stub de seed para DEMO MODE (sem banco).
 * Dados fake para dashboard / Decision Hub quando demo ativo.
 */

export type DemoKpi = {
  id: string
  label: string
  value: string | number
  trend?: 'up' | 'down' | 'neutral'
  unit?: string
}

export type DemoChartPoint = {
  label: string
  value: number
}

export type DemoDashboardSeed = {
  kpis: DemoKpi[]
  chartSeries: DemoChartPoint[]
}

const DEMO_KPIS: DemoKpi[] = [
  { id: 'kpi-1', label: 'Colaboradores ativos', value: 1247, trend: 'up', unit: '' },
  { id: 'kpi-2', label: 'Taxa de adesão', value: 89, trend: 'up', unit: '%' },
  { id: 'kpi-3', label: 'Incidentes (30d)', value: 3, trend: 'down', unit: '' },
  { id: 'kpi-4', label: 'NPS', value: 72, trend: 'neutral', unit: '' },
]

const DEMO_CHART_SERIES: DemoChartPoint[] = [
  { label: 'Jan', value: 1180 },
  { label: 'Fev', value: 1205 },
  { label: 'Mar', value: 1198 },
  { label: 'Abr', value: 1220 },
  { label: 'Mai', value: 1235 },
  { label: 'Jun', value: 1247 },
]

/** Retorna dados fake para dashboard quando demo ativo (sem banco). */
export function getDemoSeed(): DemoDashboardSeed {
  return {
    kpis: [...DEMO_KPIS],
    chartSeries: [...DEMO_CHART_SERIES],
  }
}
