/**
 * HUMANTRÍA — Help Center Page
 */

import { PageHeader, Card, Tabs } from '@/design-system/components'
import './HelpCenterPage.css'

export function HelpCenterPage() {
  const tabs = [
    {
      id: 'getting-started',
      label: 'Primeiros Passos',
      content: (
        <div className="help-content">
          <h3>Bem-vindo à HUMANTRÍA</h3>
          <p>Esta é a plataforma de governança, decisão e inteligência para capital humano.</p>
        </div>
      ),
    },
    {
      id: 'faq',
      label: 'FAQ',
      content: (
        <div className="help-content">
          <h3>Perguntas Frequentes</h3>
          <div className="faq-list">
            <div className="faq-item">
              <strong>Como criar um objetivo?</strong>
              <p>Vá para Strategy → Objectives e clique em "Novo Objetivo"</p>
            </div>
          </div>
        </div>
      ),
    },
    {
      id: 'glossary',
      label: 'Glossário',
      content: (
        <div className="help-content">
          <h3>Termos e Definições</h3>
          <div className="glossary-list">
            <div className="glossary-item">
              <strong>Objetivo</strong>
              <p>Meta estratégica definida para o capital humano</p>
            </div>
          </div>
        </div>
      ),
    },
  ]

  return (
    <div className="help-center-page">
      <PageHeader title="Central de Ajuda" />
      <Card>
        <Tabs tabs={tabs} />
      </Card>
    </div>
  )
}
