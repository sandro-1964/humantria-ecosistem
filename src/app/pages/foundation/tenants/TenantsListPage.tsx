import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'

import { LoadingState, EmptyState, ErrorState } from '../../../../components/states'
import { getSupabaseClient } from '../../../../services/supabase/client'
import { toText } from '../../../../lib/to-text'
import { useStubSafe } from '../../../../hooks/use-stub-safe'
import { StubPageLayout } from '../../../../components/stubs/StubPageLayout'

type TenantRow = { id: string; name: string; slug: string; status: string }

const STUB_TENANTS: TenantRow[] = [
  { id: 'tenant_demo', name: 'Humantría Demo', slug: 'demo', status: 'active' },
  { id: 'tenant_acme', name: 'Acme Corp', slug: 'acme', status: 'active' },
  { id: 'tenant_beta', name: 'Beta Inc', slug: 'beta', status: 'pending' },
]

export function TenantsListPage() {
  const stubSafe = useStubSafe()

  const q = useQuery<TenantRow[]>({
    queryKey: ['foundation', 'tenants', 'list'],
    enabled: !stubSafe,
    queryFn: async () => {
      const supabase = getSupabaseClient()
      const res = await supabase.schema('foundation').from('tenants').select('id,name,slug,status').order('created_at', { ascending: false })
      if (res.error) throw res.error
      return (res.data as TenantRow[]) ?? []
    },
  })

  if (stubSafe) {
    return (
      <StubPageLayout
        title="Tenants"
        expectedItems={['id', 'name', 'slug', 'status', 'created_at', 'CRUD: listar, detalhe, criar (platform_owner)']}
        fakeList={
          <ul>
            {STUB_TENANTS.map((t) => (
              <li key={t.id}>
                <Link to={`/foundation/tenants/${encodeURIComponent(t.id)}`}>{toText(t.name)}</Link>{' '}
                <span style={{ opacity: 0.7 }}>({toText(t.slug)} / {toText(t.status)})</span>
              </li>
            ))}
          </ul>
        }
      />
    )
  }

  if (q.isLoading) return <LoadingState testid="state-loading-tenants" />
  if (q.isError)
    return (
      <ErrorState
        testid="state-error-tenants"
        actions={
          <pre style={{ whiteSpace: 'pre-wrap', fontSize: 12, opacity: 0.85 }}>
            {toText(q.error instanceof Error ? q.error.message : 'tenants_error')}
          </pre>
        }
      />
    )

  const rows = q.data ?? []
  if (rows.length === 0) return <EmptyState testid="state-empty-tenants" />

  return (
    <div>
      <h1>Tenants</h1>
      <ul>
        {rows.map((t) => (
          <li key={t.id}>
            <Link to={`/foundation/tenants/${encodeURIComponent(t.id)}`}>{toText(t.name)}</Link>{' '}
            <span style={{ opacity: 0.7 }}>({toText(t.slug)} / {toText(t.status)})</span>
          </li>
        ))}
      </ul>
    </div>
  )
}

