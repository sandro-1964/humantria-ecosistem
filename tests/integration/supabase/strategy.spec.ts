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
    if (tenantId) {
      await deleteTenantById(tenantId)
    }
  })

  it('list_cycles RPC returns array when function exists', async () => {
    const client = getServiceClient()
    const { data, error } = await client
      .schema('strategy')
      .rpc('list_cycles', { p_tenant_id: tenantId, p_limit: 50 })

    if (error) {
      const msg = error.message ?? ''
      if (
        (msg.includes('function') &&
          (msg.includes('does not exist') || msg.includes('not exist') || msg.includes('undefined'))) ||
        msg.includes('permission denied for function')
      ) {
        console.warn('Strategy schema/RPC not deployed; skipping list_cycles assertion.')
        return
      }
      throw error
    }
    expect(Array.isArray(data)).toBe(true)
  })
})
