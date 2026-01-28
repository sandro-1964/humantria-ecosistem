import { EmptyState } from '../../../components/states'

export function ToolsLegacyIntegrationsPage() {
  return (
    <div>
      <h1>Integrações com Legados</h1>
      <EmptyState
        testid="state-empty-legacy-integrations"
        title="Nenhuma integração configurada"
        message="V1: este painel lista integrações existentes (quando houver). Enquanto isso, mantenha o bridge fora da UI e registre decisões via audit."
      />
    </div>
  )
}

