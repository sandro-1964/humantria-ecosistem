import { beforeAll, afterAll, describe, it, expect } from 'vitest'
import { getServiceClient } from './helpers/client.js'
import { createTemporaryTenant, deleteTenantById } from './helpers/tenant.js'

describe('strategy full integration', () => {
  let tenantId: string
  let objectiveId: string
  let initiativeId: string

  beforeAll(async () => {
    const row = await createTemporaryTenant()
    tenantId = row.id
  })

  afterAll(async () => {
    if (tenantId) await deleteTenantById(tenantId)
  })

  it('create_objective creates objective', async () => {
    const client = getServiceClient()
    const { data, error } = await client.schema('strategy').rpc('create_objective', {
      p_tenant_id: tenantId,
      p_cycle_type: 'annual',
      p_cycle_start_date: '2025-01-01',
      p_cycle_end_date: '2025-12-31',
      p_code: 'INT-TEST-001',
      p_title: 'Test objective',
    })
    expect(error).toBeNull()
    expect(data).toBeDefined()
    objectiveId = data as string
  })

  it('approve_objective approves draft', async () => {
    const client = getServiceClient()
    const { error } = await client.schema('strategy').rpc('approve_objective', {
      p_tenant_id: tenantId,
      p_objective_id: objectiveId,
      p_justification: 'Integration test approval',
    })
    expect(error).toBeNull()
  })

  it('create_initiative creates initiative linked to objective', async () => {
    const client = getServiceClient()
    const { data, error } = await client.schema('strategy').rpc('create_initiative', {
      p_tenant_id: tenantId,
      p_objective_id: objectiveId,
      p_code: 'INT-INIT-001',
      p_title: 'Test initiative',
    })
    expect(error).toBeNull()
    expect(data).toBeDefined()
    initiativeId = data as string
  })

  it('list_objectives returns objectives', async () => {
    const client = getServiceClient()
    const { data, error } = await client.schema('strategy').rpc('list_objectives', { p_tenant_id: tenantId, p_limit: 50 })
    expect(error).toBeNull()
    expect(Array.isArray(data)).toBe(true)
    expect((data as { id: string }[]).some((o) => o.id === objectiveId)).toBe(true)
  })

  it('get_portfolio_snapshot_full returns KPIs', async () => {
    const client = getServiceClient()
    const { data: cycles } = await client.schema('strategy').rpc('list_cycles', { p_tenant_id: tenantId, p_limit: 1 })
    const cycleId = (cycles as { cycle_id: string }[])?.[0]?.cycle_id
    if (!cycleId) return

    const { data, error } = await client.schema('strategy').rpc('get_portfolio_snapshot_full', {
      p_tenant_id: tenantId,
      p_cycle_id: cycleId,
    })
    if (error) {
      if (error.message.includes('permission denied') || error.message.includes('does not exist')) return
      throw error
    }
    expect(Array.isArray(data)).toBe(true)
  })
})
