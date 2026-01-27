/**
 * HUMANTRÍA — Diagnostics Health Page
 */

import { PageHeader, Card, Badge } from '@/design-system/components'
import './DiagHealthPage.css'

export function DiagHealthPage() {
  const services = [
    { name: 'API', status: 'healthy' },
    { name: 'Database', status: 'healthy' },
    { name: 'Cache', status: 'degraded' },
  ]

  return (
    <div className="diag-health-page">
      <PageHeader title="DIAG — Health" />
      <Card>
        <div className="health-services">
          {services.map((service) => (
            <div key={service.name} className="health-service">
              <span className="health-service-name">{service.name}</span>
              <Badge variant={service.status === 'healthy' ? 'success' : 'warning'}>
                {service.status}
              </Badge>
            </div>
          ))}
        </div>
      </Card>
    </div>
  )
}
