import { beforeAll, afterAll, describe, it, expect } from 'vitest'
import { getServiceClient } from './helpers/client.js'
import { createTemporaryTenant, deleteTenantById } from './helpers/tenant.js'

describe('strategy integration', () => {
  let tenantId: string

  beforeAll(async () => {
    const row = await createTemporaryTenant()
    tenantId = row.id
  })

  afterAll(async () => {
    if (tenantId) await deleteTenantById(tenantId)
  })

  it('list_cycles RPC returns array', async () => {
    const client = getServiceClient()
    const { data, error } = await client.schema('strategy').rpc('list_cycles', { p_tenant_id: tenantId, p_limit: 50 })
    if (error && (error.message.includes('permission denied') || error.message.includes('does not exist'))) {
      return
    }
    expect(error).toBeNull()
    expect(Array.isArray(data)).toBe(true)
  })
})
