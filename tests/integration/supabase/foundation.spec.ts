import { beforeAll, afterAll, describe, it, expect } from 'vitest'
import { getServiceClient, getAnonClient } from './helpers/client.js'
import { createTemporaryTenant, deleteTenantById } from './helpers/tenant.js'

describe('foundation integration', () => {
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

  it('lists tenants via service client and created tenant is present', async () => {
    const client = getServiceClient()
    const { data, error } = await client
      .schema('foundation')
      .from('tenants')
      .select('id, name, slug, status')
      .eq('id', tenantId)
      .single()

    expect(error).toBeNull()
    expect(data).not.toBeNull()
    expect(data?.id).toBe(tenantId)
    expect(data?.slug).toMatch(/^int-t9-\d+-[a-z0-9]+$/)
  })

  it('anon client select foundation.tenants returns 0 rows or access denied', async () => {
    const client = getAnonClient()
    const { data, error } = await client
      .schema('foundation')
      .from('tenants')
      .select('id, name, slug')

    if (error) {
      expect(error.message).toBeDefined()
      return
    }
    expect(Array.isArray(data)).toBe(true)
    expect(data?.length).toBe(0)
  })
})
