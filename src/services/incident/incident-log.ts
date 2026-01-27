import { getSupabaseClient } from '../supabase/client'

export type UiIncidentInput = {
  decisionType: string
  entityType: string
  entityId: string | null
  context: Record<string, unknown>
  justification: string
}

export async function writeUiIncident(input: UiIncidentInput): Promise<void> {
  // Best-effort by contract: logging must never crash UI.
  try {
    const supabase = getSupabaseClient()
    await supabase.rpc('audit_log_functional_insert', {
      p_decision_type: input.decisionType,
      p_entity_type: input.entityType,
      p_entity_id: input.entityId,
      p_context: input.context,
      p_justification: input.justification,
      p_evidence_refs: [],
      p_attachments: [],
    })
  } catch {
    // swallow
  }
}

