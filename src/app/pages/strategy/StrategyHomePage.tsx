import { PageLayout, NavCard } from '../../../design-system/components'

export function StrategyHomePage() {
  return (
    <PageLayout title="Strategy">
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(240px, 1fr))', gap: '1rem' }}>
        <NavCard to="/strategy/objectives" title="Objectives" description="Manage objectives and key results" />
        <NavCard to="/strategy/initiatives" title="Initiatives" description="Track initiatives linked to objectives" />
        <NavCard to="/strategy/snapshot" title="Snapshot" description="Portfolio KPIs and metrics" />
      </div>
    </PageLayout>
  )
}
