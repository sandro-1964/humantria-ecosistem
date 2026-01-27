import { useState } from 'react'

import { EmptyState } from '../../../../providers/app/states'
import { toText } from '../../../../lib/to-text'

export function TenantBootstrapWizardPage() {
  const [step, setStep] = useState(1)

  // V1: UI-guided wizard only (no new DB contracts here).
  return (
    <div>
      <h1>Tenant Bootstrap Wizard</h1>
      <p style={{ opacity: 0.8 }}>
        V1: Wizard mínimo apenas para guiar o operador. Execuções reais (templates/bootstrap_runs) entram como patch controlado.
      </p>

      <div style={{ display: 'flex', gap: 8, marginBottom: 12 }}>
        <button onClick={() => setStep(1)} disabled={step === 1}>
          Step 1
        </button>
        <button onClick={() => setStep(2)} disabled={step === 2}>
          Step 2
        </button>
        <button onClick={() => setStep(3)} disabled={step === 3}>
          Step 3
        </button>
      </div>

      {step === 1 ? (
        <EmptyState title="Step 1" body="Confirme tenant, role e settings básicos (locale/timezone)." />
      ) : null}
      {step === 2 ? (
        <EmptyState title="Step 2" body="Revise flags/quotas e templates aplicáveis (sem executar automaticamente)." />
      ) : null}
      {step === 3 ? (
        <EmptyState
          title="Step 3"
          body={toText('Finalize com validação + evidência no validation_report e auditoria final (sem tag).')}
        />
      ) : null}
    </div>
  )
}

