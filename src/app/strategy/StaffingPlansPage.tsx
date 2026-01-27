/**
 * HUMANTRÍA — Strategy Staffing Plans Page
 */

import { PageHeader, Card, Table, Button, Badge } from '@/design-system/components'
import './StaffingPlansPage.css'

interface StaffingPlan {
  id: string
  name: string
  department: string
  positions: number
  status: string
  createdBy: string
}

const mockPlans: StaffingPlan[] = [
  { id: '1', name: 'Plano Q1 2026', department: 'TI', positions: 15, status: 'Ativo', createdBy: 'João Silva' },
  { id: '2', name: 'Expansão Comercial', department: 'Vendas', positions: 8, status: 'Rascunho', createdBy: 'Maria Santos' },
]

export function StaffingPlansPage() {
  const columns = [
    { key: 'name', label: 'Nome' },
    { key: 'department', label: 'Departamento' },
    { key: 'positions', label: 'Posições' },
    { key: 'status', label: 'Status' },
    { key: 'createdBy', label: 'Criado por' },
    { key: 'actions', label: 'Ações' },
  ]

  const data = mockPlans.map((p) => ({
    ...p,
    status: <Badge variant={p.status === 'Ativo' ? 'success' : 'neutral'}>{p.status}</Badge>,
    actions: (
      <div className="staffing-actions">
        <Button variant="ghost" size="sm">Ver</Button>
        <Button variant="ghost" size="sm">Editar</Button>
      </div>
    ),
  }))

  return (
    <div className="staffing-plans-page">
      <PageHeader
        title="Planos de Contratação"
        actions={<Button variant="primary">Novo Plano</Button>}
      />
      <Card>
        <Table columns={columns} data={data} />
      </Card>
    </div>
  )
}
