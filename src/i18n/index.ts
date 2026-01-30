import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'

import enUS from './locales/en-US.json'
import esES from './locales/es-ES.json'
import ptBR from './locales/pt-BR.json'

const DEFAULT_LOCALE = 'pt-BR'

function getInitialLocale(): string {
  const stored = localStorage.getItem('humantria.locale')
  if (stored) return stored
  return DEFAULT_LOCALE
}

export function setLocale(locale: string) {
  i18n.changeLanguage(locale)
  localStorage.setItem('humantria.locale', locale)
}

export function getLocale(): string {
  return i18n.language || DEFAULT_LOCALE
}

void i18n.use(initReactI18next).init({
  lng: getInitialLocale(),
  fallbackLng: DEFAULT_LOCALE,
  interpolation: { escapeValue: false },
  resources: {
    'pt-BR': { translation: ptBR },
    'en-US': { translation: enUS },
    'es-ES': { translation: esES },
  },
})

export default i18n

