/**
 * HUMANTRÍA — Strategy Dashboard Page
 */

import { PageHeader, StatsCard, Card, KPIBlock, Table } from '@/design-system/components'
import './DashboardPage.css'

export function DashboardPage() {
  const stats = [
    { label: 'Objetivos Ativos', value: '12', trend: { value: 5, isPositive: true } },
    { label: 'Aprovações Pendentes', value: '3', trend: { value: -2, isPositive: true } },
    { label: 'Orçamento Total', value: 'R$ 2.5M', trend: { value: 10, isPositive: true } },
    { label: 'Riscos Identificados', value: '5', trend: { value: 1, isPositive: false } },
  ]

  const recentApprovals = [
    { id: '1', title: 'Aprovação de Orçamento Q1', status: 'Pendente', date: '2026-01-25' },
    { id: '2', title: 'Revisão de Objetivo', status: 'Aprovado', date: '2026-01-24' },
  ]

  const columns = [
    { key: 'title', label: 'Título' },
    { key: 'status', label: 'Status' },
    { key: 'date', label: 'Data' },
  ]

  return (
    <div className="strategy-dashboard-page">
      <PageHeader
        title="Strategy Dashboard"
        description="Visão geral do planejamento estratégico"
      />
      <div className="dashboard-stats">
        {stats.map((stat) => (
          <StatsCard
            key={stat.label}
            label={stat.label}
            value={stat.value}
            trend={stat.trend}
          />
        ))}
      </div>
      <div className="dashboard-grid">
        <Card title="KPIs Principais">
          <div className="dashboard-kpis">
            <KPIBlock title="ROI Projetado" value="18.5%" variant="success" />
            <KPIBlock title="Cobertura de Cargos" value="87%" variant="info" />
            <KPIBlock title="Eficiência" value="92%" variant="success" />
          </div>
        </Card>
        <Card title="Aprovações Recentes">
          <Table columns={columns} data={recentApprovals} />
        </Card>
      </div>
    </div>
  )
}
