/**
 * HUMANTRÍA — Account Preferences Page
 */

import { useState } from 'react'
import { PageHeader, Card, Switch, Select, Button } from '@/design-system/components'
import './PreferencesPage.css'

export function PreferencesPage() {
  const [theme, setTheme] = useState<'light' | 'dark'>('light')
  const [density, setDensity] = useState<'compact' | 'comfortable' | 'spacious'>('comfortable')
  const [language, setLanguage] = useState('pt-BR')
  const [timezone, setTimezone] = useState('America/Sao_Paulo')

  const handleThemeChange = (checked: boolean) => {
    const newTheme = checked ? 'dark' : 'light'
    setTheme(newTheme)
    document.documentElement.setAttribute('data-theme', newTheme)
  }

  const handleDensityChange = (value: string) => {
    setDensity(value as any)
    document.documentElement.setAttribute('data-density', value)
  }

  return (
    <div className="preferences-page">
      <PageHeader
        title="Preferências"
        description="Personalize sua experiência na plataforma"
      />
      <div className="preferences-grid">
        <Card title="Aparência">
          <div className="preferences-section">
            <Switch
              label="Tema escuro"
              checked={theme === 'dark'}
              onChange={(e) => handleThemeChange(e.target.checked)}
            />
          </div>
          <div className="preferences-section">
            <Select
              label="Densidade"
              value={density}
              onChange={(e) => handleDensityChange(e.target.value)}
              options={[
                { value: 'compact', label: 'Compacta' },
                { value: 'comfortable', label: 'Confortável' },
                { value: 'spacious', label: 'Espaçosa' },
              ]}
            />
          </div>
        </Card>
        <Card title="Localização">
          <div className="preferences-section">
            <Select
              label="Idioma"
              value={language}
              onChange={(e) => setLanguage(e.target.value)}
              options={[
                { value: 'pt-BR', label: 'Português (Brasil)' },
                { value: 'en-US', label: 'English (US)' },
                { value: 'es-ES', label: 'Español' },
              ]}
            />
          </div>
          <div className="preferences-section">
            <Select
              label="Fuso horário"
              value={timezone}
              onChange={(e) => setTimezone(e.target.value)}
              options={[
                { value: 'America/Sao_Paulo', label: 'America/São Paulo (UTC-3)' },
                { value: 'America/New_York', label: 'America/New York (UTC-5)' },
                { value: 'Europe/London', label: 'Europe/London (UTC+0)' },
              ]}
            />
          </div>
        </Card>
      </div>
      <div className="preferences-actions">
        <Button variant="primary">Salvar preferências</Button>
      </div>
    </div>
  )
}
