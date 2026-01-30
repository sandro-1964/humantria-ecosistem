import type { ReactNode } from 'react'

import { useRbac } from '../../providers/rbac/RbacProvider'
import { toText } from '../../lib/to-text'

type Props = {
  title: string
  expectedItems: string[]
  fakeList: ReactNode
  /** Quando true (ex.: auditor), não mostra botões de ação / criar / editar */
  readOnly?: boolean
}

export function StubPageLayout({ title, expectedItems, fakeList, readOnly }: Props) {
  const rbac = useRbac()
  const isReadOnly = readOnly ?? rbac.role === 'auditor'

  return (
    <div>
      <div
        style={{
          display: 'inline-block',
          marginBottom: 12,
          padding: '4px 8px',
          fontSize: 11,
          background: 'rgba(0,0,0,0.06)',
          borderRadius: 4,
          fontWeight: 600,
        }}
      >
        DEMO / Pré-Supabase
      </div>
      <h1>{toText(title)}</h1>
      <p style={{ fontSize: 12, opacity: 0.8 }}>
        Esta tela usa dados fake. Após conectar Supabase, virão listagem e CRUD reais.
      </p>

      <section style={{ marginTop: 16, marginBottom: 16 }}>
        <h2 style={{ fontSize: 14, marginBottom: 8 }}>O que existirá depois</h2>
        <ul style={{ fontSize: 12, opacity: 0.9, margin: 0, paddingLeft: 20 }}>
          {expectedItems.map((item) => (
            <li key={item}>{toText(item)}</li>
          ))}
        </ul>
      </section>

      <section>
        <h2 style={{ fontSize: 14, marginBottom: 8 }}>Fake list (layout)</h2>
        {fakeList}
      </section>

      {isReadOnly ? (
        <p style={{ marginTop: 12, fontSize: 11, opacity: 0.7 }}>Somente leitura (compliance).</p>
      ) : null}
    </div>
  )
}
