/**
 * HUMANTRÍA — Account Sessions Page
 */

import { PageHeader, Card, Table, Button } from '@/design-system/components'
import './SessionsPage.css'

interface Session {
  id: string
  device: string
  location: string
  lastActive: string
  current: boolean
}

const mockSessions: Session[] = [
  { id: '1', device: 'Chrome on Windows', location: 'São Paulo, BR', lastActive: 'Agora', current: true },
  { id: '2', device: 'Safari on macOS', location: 'São Paulo, BR', lastActive: '2 horas atrás', current: false },
  { id: '3', device: 'Firefox on Linux', location: 'Rio de Janeiro, BR', lastActive: '1 dia atrás', current: false },
]

export function SessionsPage() {
  const columns = [
    { key: 'device', label: 'Dispositivo' },
    { key: 'location', label: 'Localização' },
    { key: 'lastActive', label: 'Última atividade' },
    { key: 'actions', label: 'Ações' },
  ]

  const data = mockSessions.map((session) => ({
    ...session,
    actions: (
      <div className="sessions-actions">
        {session.current ? (
          <span className="sessions-current-badge">Atual</span>
        ) : (
          <Button variant="ghost" size="sm">Encerrar</Button>
        )}
      </div>
    ),
  }))

  return (
    <div className="sessions-page">
      <PageHeader
        title="Sessões Ativas"
        description="Gerencie seus dispositivos e sessões conectadas"
      />
      <Card>
        <Table columns={columns} data={data} />
      </Card>
    </div>
  )
}
