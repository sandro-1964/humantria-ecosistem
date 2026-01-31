import { getServiceClient } from './client.js'

type TenantRow = { id: string; slug: string; name: string }

export async function createTemporaryTenant(): Promise<TenantRow> {
  const client = getServiceClient()
  const timestamp = Date.now()
  const rand = Math.random().toString(36).slice(2, 8)
  const slug = `int-t9-${timestamp}-${rand}`
  const name = `T9 Integration ${timestamp}`

  const { data, error } = await client
    .schema('foundation')
    .from('tenants')
    .insert({ slug, name, status: 'active' })
    .select('id, slug, name')
    .single()

  if (error) {
    console.error('createTemporaryTenant error:', error.message)
    throw error
  }
  return data as TenantRow
}

export async function deleteTenantById(id: string): Promise<void> {
  const client = getServiceClient()
  const { error } = await client.schema('foundation').from('tenants').delete().eq('id', id)
  if (error) console.error('deleteTenantById error:', error.message)
}
