/**
 * HUMANTRÍA — Strategy Home
 * 
 * Container do primeiro produto: Strategy.
 * Navegação para todas as funcionalidades do produto.
 */

import { PageHeader, Card, Section } from '@/design-system/components'
import './StrategyHome.css'

export function StrategyHome() {
  return (
    <div className="strategy-home">
      <PageHeader
        title="Strategy"
        description="Governança e decisão estratégica de capital humano"
      />
      <div className="strategy-navigation">
        <Card title="Navegação Rápida">
          <div className="strategy-links">
            <a href="/strategy/dashboard" className="strategy-link">
              <strong>Dashboard</strong>
              <span>Visão geral e KPIs</span>
            </a>
            <a href="/strategy/objectives" className="strategy-link">
              <strong>Objetivos</strong>
              <span>Gerencie objetivos estratégicos</span>
            </a>
            <a href="/strategy/approvals" className="strategy-link">
              <strong>Aprovações</strong>
              <span>Pendentes e histórico</span>
            </a>
            <a href="/strategy/budget" className="strategy-link">
              <strong>Orçamentos</strong>
              <span>Versões e planejamento</span>
            </a>
            <a href="/strategy/staffing" className="strategy-link">
              <strong>Contratações</strong>
              <span>Planos de staffing</span>
            </a>
            <a href="/strategy/simulation" className="strategy-link">
              <strong>Simulações</strong>
              <span>Assistente de cenários</span>
            </a>
            <a href="/strategy/risks" className="strategy-link">
              <strong>Riscos</strong>
              <span>Alertas e monitoramento</span>
            </a>
          </div>
        </Card>
      </div>
    </div>
  )
}
