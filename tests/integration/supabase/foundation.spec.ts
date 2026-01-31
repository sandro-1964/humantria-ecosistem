import { beforeAll, afterAll, describe, it, expect } from 'vitest'
import { getServiceClient } from './helpers/client.js'
import { createTemporaryTenant, deleteTenantById } from './helpers/tenant.js'

describe('foundation integration', () => {
  let tenantId: string

  beforeAll(async () => {
    const row = await createTemporaryTenant()
    tenantId = row.id
  })

  afterAll(async () => {
    if (tenantId) await deleteTenantById(tenantId)
  })

  it('lists tenants via service client', async () => {
    const client = getServiceClient()
    const { data, error } = await client.schema('foundation').from('tenants').select('id, name, slug').eq('id', tenantId).single()
    expect(error).toBeNull()
    expect(data?.id).toBe(tenantId)
  })
})
