/**
 * HUMANTRÍA — Announcements Page
 */

import { PageHeader, Card, Banner } from '@/design-system/components'
import './AnnouncementsPage.css'

export function AnnouncementsPage() {
  return (
    <div className="announcements-page">
      <PageHeader title="Anúncios" />
      <div className="announcements-list">
        <Banner variant="info">
          <strong>Manutenção programada</strong>
          <p>O sistema estará em manutenção no dia 30/01/2026 das 02:00 às 04:00</p>
        </Banner>
        <Banner variant="success">
          <strong>Nova funcionalidade disponível</strong>
          <p>O módulo Strategy agora suporta simulações avançadas</p>
        </Banner>
      </div>
    </div>
  )
}
