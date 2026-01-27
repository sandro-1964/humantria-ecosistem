/**
 * HUMANTRÍA — Strategy Approvals Page
 */

import { PageHeader, Card, Table, Button, Badge, Tabs } from '@/design-system/components'
import './ApprovalsPage.css'

interface Approval {
  id: string
  title: string
  type: string
  requester: string
  status: string
  date: string
}

const mockApprovals: Approval[] = [
  { id: '1', title: 'Aprovação de Orçamento Q1', type: 'Orçamento', requester: 'João Silva', status: 'Pendente', date: '2026-01-25' },
  { id: '2', title: 'Revisão de Objetivo', type: 'Objetivo', requester: 'Maria Santos', status: 'Aprovado', date: '2026-01-24' },
]

export function ApprovalsPage() {
  const columns = [
    { key: 'title', label: 'Título' },
    { key: 'type', label: 'Tipo' },
    { key: 'requester', label: 'Solicitante' },
    { key: 'status', label: 'Status' },
    { key: 'date', label: 'Data' },
    { key: 'actions', label: 'Ações' },
  ]

  const pendingData = mockApprovals
    .filter((a) => a.status === 'Pendente')
    .map((a) => ({
      ...a,
      status: <Badge variant="warning">{a.status}</Badge>,
      actions: (
        <div className="approvals-actions">
          <Button variant="primary" size="sm">Aprovar</Button>
          <Button variant="secondary" size="sm">Rejeitar</Button>
        </div>
      ),
    }))

  const allData = mockApprovals.map((a) => ({
    ...a,
    status: <Badge variant={a.status === 'Aprovado' ? 'success' : 'warning'}>{a.status}</Badge>,
    actions: (
      <div className="approvals-actions">
        <Button variant="ghost" size="sm">Ver</Button>
      </div>
    ),
  }))

  const tabs = [
    {
      id: 'pending',
      label: 'Pendentes',
      content: <Table columns={columns} data={pendingData} />,
    },
    {
      id: 'all',
      label: 'Todas',
      content: <Table columns={columns} data={allData} />,
    },
  ]

  return (
    <div className="approvals-page">
      <PageHeader title="Aprovações" />
      <Card>
        <Tabs tabs={tabs} />
      </Card>
    </div>
  )
}
