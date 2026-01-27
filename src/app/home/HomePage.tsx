/**
 * HUMANTRÍA — Home Page
 * 
 * Página inicial macro da plataforma.
 * Visão geral, dashboards, acesso rápido a produtos.
 */

import { PageHeader, Card, StatsCard } from '@/design-system/components'
import './HomePage.css'

export function HomePage() {
  const quickStats = [
    { label: 'Produtos Ativos', value: '8' },
    { label: 'Usuários', value: '124' },
    { label: 'Decisões Hoje', value: '23' },
  ]

  return (
    <div className="home-page">
      <PageHeader
        title="HUMANTRÍA"
        description="Plataforma de Governança, Decisão e Inteligência para Capital Humano"
      />
      <div className="home-stats">
        {quickStats.map((stat) => (
          <StatsCard key={stat.label} label={stat.label} value={stat.value} />
        ))}
      </div>
      <div className="home-products">
        <Card title="Produtos">
          <div className="products-grid">
            <a href="/strategy" className="product-card">
              <h3>Strategy</h3>
              <p>Governança e decisão estratégica de capital humano</p>
            </a>
            <div className="product-card">
              <h3>Talent</h3>
              <p>Em breve</p>
            </div>
            <div className="product-card">
              <h3>Ops</h3>
              <p>Em breve</p>
            </div>
          </div>
        </Card>
      </div>
    </div>
  )
}
