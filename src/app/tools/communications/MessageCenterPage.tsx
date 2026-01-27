/**
 * HUMANTRÍA — Message Center Page
 */

import { PageHeader, Card, EmptyState, Button } from '@/design-system/components'
import './MessageCenterPage.css'

export function MessageCenterPage() {
  return (
    <div className="message-center-page">
      <PageHeader title="Central de Mensagens" />
      <Card>
        <EmptyState
          title="Nenhuma mensagem"
          description="Você não tem mensagens no momento"
          action={{
            label: 'Nova mensagem',
            onClick: () => {},
          }}
        />
      </Card>
    </div>
  )
}
