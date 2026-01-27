/**
 * HUMANTRÍA — Strategy Simulation Wizard Page
 */

import { useState } from 'react'
import { PageHeader, Card, Input, Select, Button, Section } from '@/design-system/components'
import './SimulationWizardPage.css'

export function SimulationWizardPage() {
  const [step, setStep] = useState(1)

  return (
    <div className="simulation-wizard-page">
      <PageHeader title="Assistente de Simulação" />
      <Card>
        <div className="wizard-progress">
          <div className={`wizard-step ${step >= 1 ? 'active' : ''}`}>1. Parâmetros</div>
          <div className={`wizard-step ${step >= 2 ? 'active' : ''}`}>2. Cenários</div>
          <div className={`wizard-step ${step >= 3 ? 'active' : ''}`}>3. Resultados</div>
        </div>
        <div className="wizard-content">
          {step === 1 && (
            <Section title="Parâmetros da Simulação">
              <div className="wizard-form">
                <Input label="Nome da simulação" placeholder="Ex: Cenário Base 2026" />
                <Select
                  label="Período"
                  options={[
                    { value: '2026', label: '2026' },
                    { value: '2027', label: '2027' },
                  ]}
                />
                <Input label="Orçamento inicial" type="number" placeholder="R$ 0,00" />
                <div className="wizard-actions">
                  <Button variant="primary" onClick={() => setStep(2)}>Próximo</Button>
                </div>
              </div>
            </Section>
          )}
          {step === 2 && (
            <Section title="Cenários">
              <div className="wizard-form">
                <p>Configure os cenários da simulação</p>
                <div className="wizard-actions">
                  <Button variant="secondary" onClick={() => setStep(1)}>Voltar</Button>
                  <Button variant="primary" onClick={() => setStep(3)}>Próximo</Button>
                </div>
              </div>
            </Section>
          )}
          {step === 3 && (
            <Section title="Resultados">
              <div className="wizard-form">
                <p>Resultados da simulação serão exibidos aqui</p>
                <div className="wizard-actions">
                  <Button variant="secondary" onClick={() => setStep(2)}>Voltar</Button>
                  <Button variant="primary">Finalizar</Button>
                </div>
              </div>
            </Section>
          )}
        </div>
      </Card>
    </div>
  )
}
