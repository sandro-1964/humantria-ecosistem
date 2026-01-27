/**
 * HUMANTRÍA — Strategy Objectives Page
 */

import { PageHeader, Card, Table, Button, Badge } from '@/design-system/components'
import './ObjectivesPage.css'

interface Objective {
  id: string
  name: string
  status: string
  progress: number
  owner: string
  dueDate: string
}

const mockObjectives: Objective[] = [
  { id: '1', name: 'Aumentar eficiência operacional', status: 'Em andamento', progress: 65, owner: 'João Silva', dueDate: '2026-06-30' },
  { id: '2', name: 'Reduzir custos de contratação', status: 'Planejado', progress: 0, owner: 'Maria Santos', dueDate: '2026-12-31' },
]

export function ObjectivesPage() {
  const columns = [
    { key: 'name', label: 'Nome' },
    { key: 'status', label: 'Status' },
    { key: 'progress', label: 'Progresso', render: (value: number) => `${value}%` },
    { key: 'owner', label: 'Responsável' },
    { key: 'dueDate', label: 'Prazo' },
    { key: 'actions', label: 'Ações' },
  ]

  const data = mockObjectives.map((obj) => ({
    ...obj,
    status: <Badge variant={obj.status === 'Em andamento' ? 'info' : 'neutral'}>{obj.status}</Badge>,
    actions: (
      <div className="objectives-actions">
        <Button variant="ghost" size="sm">Ver</Button>
      </div>
    ),
  }))

  return (
    <div className="objectives-page">
      <PageHeader
        title="Objetivos"
        description="Gerencie objetivos estratégicos"
        actions={<Button variant="primary">Novo Objetivo</Button>}
      />
      <Card>
        <Table columns={columns} data={data} />
      </Card>
    </div>
  )
}
