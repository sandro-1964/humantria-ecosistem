/**
 * HUMANTRÍA — Strategy Risk Alerts Page
 */

import { PageHeader, Card, Table, Badge, Banner } from '@/design-system/components'
import './RiskAlertsPage.css'

interface RiskAlert {
  id: string
  title: string
  severity: string
  category: string
  detectedAt: string
  status: string
}

const mockAlerts: RiskAlert[] = [
  { id: '1', title: 'Orçamento excedido em 15%', severity: 'Alto', category: 'Financeiro', detectedAt: '2026-01-25', status: 'Aberto' },
  { id: '2', title: 'Atraso em contratações críticas', severity: 'Médio', category: 'Operacional', detectedAt: '2026-01-24', status: 'Em análise' },
]

export function RiskAlertsPage() {
  const columns = [
    { key: 'title', label: 'Alerta' },
    { key: 'severity', label: 'Severidade' },
    { key: 'category', label: 'Categoria' },
    { key: 'detectedAt', label: 'Detectado em' },
    { key: 'status', label: 'Status' },
  ]

  const data = mockAlerts.map((a) => ({
    ...a,
    severity: <Badge variant={a.severity === 'Alto' ? 'error' : 'warning'}>{a.severity}</Badge>,
    status: <Badge variant={a.status === 'Aberto' ? 'error' : 'info'}>{a.status}</Badge>,
  }))

  return (
    <div className="risk-alerts-page">
      <PageHeader title="Alertas de Risco" />
      <Banner variant="warning">
        <strong>5 alertas ativos</strong>
        <p>Revisar e tomar ações corretivas</p>
      </Banner>
      <Card>
        <Table columns={columns} data={data} />
      </Card>
    </div>
  )
}
