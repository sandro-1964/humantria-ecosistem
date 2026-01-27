/**
 * HUMANTRÍA — Diagnostics Meta Page
 */

import { PageHeader, Card, Table } from '@/design-system/components'
import './DiagMetaPage.css'

export function DiagMetaPage() {
  const metaData = [
    { key: 'Versão', value: '0.0.0' },
    { key: 'Ambiente', value: 'development' },
    { key: 'Build', value: 'dev-20260126' },
    { key: 'Timestamp', value: new Date().toISOString() },
  ]

  const columns = [
    { key: 'key', label: 'Chave' },
    { key: 'value', label: 'Valor' },
  ]

  return (
    <div className="diag-meta-page">
      <PageHeader title="DIAG — Meta" />
      <Card>
        <Table columns={columns} data={metaData} />
      </Card>
    </div>
  )
}
