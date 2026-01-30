import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'

import { LoadingState, ErrorState } from '../../../../providers/app/states'
import { useTenant } from '../../../../providers/tenant/TenantProvider'
import { getSupabaseClient } from '../../../../services/supabase/client'
import { toText } from '../../../../lib/to-text'
import { writeUiIncident } from '../../../../services/incident/incident-log'
import { useStubSafe } from '../../../../hooks/use-stub-safe'
import { StubPageLayout } from '../../../../components/stubs/StubPageLayout'

type TenantSettingsRow = {
  tenant_id: string
  locale: string | null
  timezone: string | null
  base_currency: string | null
  metadata: unknown
}

export function TenantSettingsPage() {
  const tenant = useTenant()
  const qc = useQueryClient()
  const stubSafe = useStubSafe()

  const q = useQuery<TenantSettingsRow | null>({
    queryKey: ['foundation', 'tenant_settings', tenant.tenantId],
    enabled: Boolean(tenant.tenantId) && !stubSafe,
    queryFn: async () => {
      const supabase = getSupabaseClient()
      const res = await supabase
        .schema('foundation')
        .from('tenant_settings')
        .select('*')
        .eq('tenant_id', tenant.tenantId as string)
        .maybeSingle()
      if (res.error) throw res.error
      return (res.data as TenantSettingsRow | null) ?? null
    },
  })

  const m = useMutation({
    mutationFn: async () => {
      const supabase = getSupabaseClient()
      const res = await supabase
        .schema('foundation')
        .from('tenant_settings')
        .update({ locale: 'pt-BR' })
        .eq('tenant_id', tenant.tenantId as string)
      if (res.error) throw res.error
      await writeUiIncident({
        decisionType: 'ui.action',
        entityType: 'tenant_settings',
        entityId: null,
        context: { action: 'set_locale_ptbr' },
        justification: 'UI action (demo) set locale',
      })
    },
    onSuccess: async () => {
      await qc.invalidateQueries({ queryKey: ['foundation', 'tenant_settings', tenant.tenantId] })
    },
    onError: async (err) => {
      await writeUiIncident({
        decisionType: 'ui.error',
        entityType: 'tenant_settings',
        entityId: null,
        context: { error: err instanceof Error ? err.message : 'mutation_error' },
        justification: 'UI mutation failed',
      })
    },
  })

  if (stubSafe) {
    return (
      <StubPageLayout
        title="Tenant Settings"
        expectedItems={['tenant_id', 'locale', 'timezone', 'base_currency', 'metadata', 'CRUD: ler, atualizar (tenant_admin)']}
        fakeList={
          <ul>
            <li>Locale: pt-BR</li>
            <li>Timezone: America/Sao_Paulo</li>
            <li>Base currency: BRL</li>
          </ul>
        }
        readOnly={false}
      />
    )
  }

  if (q.isLoading) return <LoadingState />
  if (q.isError) return <ErrorState details={q.error instanceof Error ? q.error.message : 'settings_error'} />
  if (!q.data) return <ErrorState title="Settings missing" body="No tenant_settings row found for this tenant." />

  return (
    <div>
      <h1>Tenant Settings</h1>
      <p>Locale: {toText(q.data.locale ?? '')}</p>
      <p>Timezone: {toText(q.data.timezone ?? '')}</p>
      <p>Base currency: {toText(q.data.base_currency ?? '')}</p>
      <button onClick={() => m.mutate()} disabled={m.isPending}>
        {m.isPending ? 'Saving…' : 'Set locale to pt-BR (demo)'}
      </button>
      {m.isError ? (
        <ErrorState
          title="Save failed"
          body="Não foi possível salvar."
          details={m.error instanceof Error ? m.error.message : 'save_error'}
        />
      ) : null}
    </div>
  )
}

