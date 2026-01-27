/**
 * HUMANTRÍA — Strategy Budget Versions Page
 */

import { PageHeader, Card, Table, Button, Badge } from '@/design-system/components'
import './BudgetVersionsPage.css'

interface BudgetVersion {
  id: string
  name: string
  period: string
  amount: string
  status: string
  createdBy: string
}

const mockVersions: BudgetVersion[] = [
  { id: '1', name: 'Orçamento 2026', period: '2026', amount: 'R$ 2.5M', status: 'Ativo', createdBy: 'João Silva' },
  { id: '2', name: 'Revisão Q1', period: 'Q1 2026', amount: 'R$ 650K', status: 'Rascunho', createdBy: 'Maria Santos' },
]

export function BudgetVersionsPage() {
  const columns = [
    { key: 'name', label: 'Nome' },
    { key: 'period', label: 'Período' },
    { key: 'amount', label: 'Valor' },
    { key: 'status', label: 'Status' },
    { key: 'createdBy', label: 'Criado por' },
    { key: 'actions', label: 'Ações' },
  ]

  const data = mockVersions.map((v) => ({
    ...v,
    status: <Badge variant={v.status === 'Ativo' ? 'success' : 'neutral'}>{v.status}</Badge>,
    actions: (
      <div className="budget-actions">
        <Button variant="ghost" size="sm">Ver</Button>
        <Button variant="ghost" size="sm">Editar</Button>
      </div>
    ),
  }))

  return (
    <div className="budget-versions-page">
      <PageHeader
        title="Versões de Orçamento"
        actions={<Button variant="primary">Nova Versão</Button>}
      />
      <Card>
        <Table columns={columns} data={data} onRowClick={(row) => console.log('View budget:', row)} />
      </Card>
    </div>
  )
}
