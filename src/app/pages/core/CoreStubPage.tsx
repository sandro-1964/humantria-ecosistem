import { StubPageLayout } from '../../../components/stubs/StubPageLayout'

export function CoreStubPage() {
  return (
    <StubPageLayout
      title="Core"
      expectedItems={['jobs', 'job_levels', 'org_tree', 'job_matrix', 'CRUD após Supabase']}
      fakeList={
        <ul>
          <li>Job: Engenheiro</li>
          <li>Job: Analista</li>
          <li>Org tree: placeholder</li>
        </ul>
      }
    />
  )
}
