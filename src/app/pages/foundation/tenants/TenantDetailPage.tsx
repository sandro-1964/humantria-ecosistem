import { useQuery } from '@tanstack/react-query'
import { useParams } from 'react-router-dom'

import { LoadingState, ErrorState } from '../../../../providers/app/states'
import { getSupabaseClient } from '../../../../services/supabase/client'
import { toText } from '../../../../lib/to-text'
import { useStubSafe } from '../../../../hooks/use-stub-safe'
import { StubPageLayout } from '../../../../components/stubs/StubPageLayout'

type TenantRow = { id: string; name: string; slug: string; status: string; metadata: unknown }

export function TenantDetailPage() {
  const { tenantId } = useParams()
  const stubSafe = useStubSafe()

  const q = useQuery<TenantRow | null>({
    queryKey: ['foundation', 'tenants', 'detail', tenantId],
    enabled: Boolean(tenantId) && !stubSafe,
    queryFn: async () => {
      const supabase = getSupabaseClient()
      const res = await supabase
        .schema('foundation')
        .from('tenants')
        .select('id,name,slug,status,metadata')
        .eq('id', tenantId as string)
        .maybeSingle()
      if (res.error) throw res.error
      return (res.data as TenantRow | null) ?? null
    },
  })

  if (stubSafe) {
    const stubRow: TenantRow = {
      id: tenantId ?? 'tenant_demo',
      name: 'Humantría Demo',
      slug: 'demo',
      status: 'active',
      metadata: { locale: 'pt-BR' },
    }
    return (
      <StubPageLayout
        title="Tenant detail"
        expectedItems={['id', 'name', 'slug', 'status', 'metadata', 'CRUD: ver, editar (platform_owner)']}
        fakeList={
          <div>
            <p><strong>Name:</strong> {toText(stubRow.name)}</p>
            <p><strong>Slug:</strong> {toText(stubRow.slug)}</p>
            <p><strong>Status:</strong> {toText(stubRow.status)}</p>
          </div>
        }
      />
    )
  }

  if (q.isLoading) return <LoadingState />
  if (q.isError) return <ErrorState details={q.error instanceof Error ? q.error.message : 'tenant_error'} />
  if (!q.data) return <ErrorState title="Tenant not found" body="No tenant matched this id." />

  return (
    <div>
      <h1>{toText(q.data.name)}</h1>
      <p>Slug: {toText(q.data.slug)}</p>
      <p>Status: {toText(q.data.status)}</p>
      <h3>Metadata</h3>
      <pre style={{ whiteSpace: 'pre-wrap', fontSize: 12 }}>
        {toText(JSON.stringify(q.data.metadata, null, 2))}
      </pre>
    </div>
  )
}

