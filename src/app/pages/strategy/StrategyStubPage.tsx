import { StubPageLayout } from '../../../components/stubs/StubPageLayout'

export function StrategyStubPage() {
  return (
    <StubPageLayout
      title="Strategy"
      expectedItems={['cycles', 'initiatives', 'portfolio_snapshot', 'CRUD após Supabase']}
      fakeList={
        <ul>
          <li>Ciclo: Q1 2026</li>
          <li>Iniciativa: Objetivo Alpha</li>
        </ul>
      }
    />
  )
}
