/**
 * HUMANTRÍA — Account Profile Page
 */

import { PageHeader, Card, Input, Button } from '@/design-system/components'
import './ProfilePage.css'

export function ProfilePage() {
  return (
    <div className="profile-page">
      <PageHeader
        title="Perfil"
        description="Gerencie suas informações pessoais"
      />
      <Card title="Informações Pessoais">
        <div className="profile-form">
          <Input label="Nome completo" defaultValue="João Silva" />
          <Input label="Email" type="email" defaultValue="joao@example.com" />
          <Input label="Telefone" type="tel" defaultValue="+55 11 99999-9999" />
          <div className="profile-form-actions">
            <Button variant="primary">Salvar alterações</Button>
            <Button variant="secondary">Cancelar</Button>
          </div>
        </div>
      </Card>
    </div>
  )
}
