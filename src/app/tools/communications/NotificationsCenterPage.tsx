/**
 * HUMANTRÍA — Notifications Center Page
 */

import { PageHeader, Card, Tabs, Badge } from '@/design-system/components'
import './NotificationsCenterPage.css'

export function NotificationsCenterPage() {
  const tabs = [
    {
      id: 'all',
      label: 'Todas',
      content: (
        <div className="notifications-list">
          <div className="notification-item">
            <div className="notification-content">
              <strong>Nova aprovação pendente</strong>
              <p>Você tem uma nova solicitação de aprovação no Strategy</p>
              <span className="notification-time">há 5 minutos</span>
            </div>
            <Badge variant="error">Não lida</Badge>
          </div>
        </div>
      ),
    },
    {
      id: 'unread',
      label: 'Não lidas',
      content: <div className="notifications-empty">Nenhuma notificação não lida</div>,
    },
  ]

  return (
    <div className="notifications-center-page">
      <PageHeader title="Central de Notificações" />
      <Card>
        <Tabs tabs={tabs} />
      </Card>
    </div>
  )
}
