import { EmptyState } from '../../../providers/app/states'

export function ToolsLegacyIntegrationsPage() {
  return (
    <div>
      <h1>Integrações com Legados</h1>
      <EmptyState
        title="Nenhuma integração configurada"
        body="V1: este painel lista integrações existentes (quando houver). Enquanto isso, mantenha o bridge fora da UI e registre decisões via audit."
      />
    </div>
  )
}

