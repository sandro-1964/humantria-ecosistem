import { toText } from '../../../lib/to-text'

export function ToolsDocsPage() {
  return (
    <div>
      <h1>{toText('Documentação')}</h1>
      <ul>
        <li>{toText('Canon: docs/_canon/*')}</li>
        <li>{toText('Foundation: docs/foundation/*')}</li>
        <li>{toText('Core: docs/core/*')}</li>
        <li>{toText('Releases: docs/releases/*')}</li>
      </ul>
      <p style={{ opacity: 0.8 }}>
        V1: esta tela é um hub simples. Pode evoluir para um viewer de markdown governado (sem puxar dados crus).
      </p>
    </div>
  )
}

