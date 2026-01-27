/**
 * HUMANTRÍA — Footer Tech
 * 
 * Rodapé técnico com versão, ambiente, links técnicos.
 */

import './FooterTech.css'

export function FooterTech() {
  const version = import.meta.env.VITE_APP_VERSION || '0.0.0'
  const environment = import.meta.env.MODE || 'development'

  return (
    <footer className="app-footer-tech">
      <div className="app-footer-tech-content">
        <div className="app-footer-tech-info">
          <span>v{version}</span>
          <span className="app-footer-tech-separator">•</span>
          <span>{environment}</span>
        </div>
        <div className="app-footer-tech-links">
          <a href="/__diag" target="_blank" rel="noopener noreferrer">
            DIAG
          </a>
        </div>
      </div>
    </footer>
  )
}
