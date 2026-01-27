/**
 * HUMANTRÍA — Footer Tech
 * 
 * Rodapé técnico com versão, ambiente, links técnicos.
 */

import './FooterTech.css'

export function FooterTech() {
  const version = import.meta.env.VITE_APP_VERSION || '0.0.0'
  const environment = import.meta.env.MODE || 'development'
  const gitTag = import.meta.env.VITE_GIT_TAG || 'unknown'
  const fingerprint = import.meta.env.VITE_BUILD_FINGERPRINT || 'dev'
  const health = 'healthy' // Placeholder

  return (
    <footer className="app-footer-tech">
      <div className="app-footer-tech-content">
        <div className="app-footer-tech-info">
          <span>v{version}</span>
          <span className="app-footer-tech-separator">•</span>
          <span>{environment}</span>
          <span className="app-footer-tech-separator">•</span>
          <span>tag: {gitTag}</span>
          <span className="app-footer-tech-separator">•</span>
          <span>fp: {fingerprint.substring(0, 8)}</span>
        </div>
        <div className="app-footer-tech-right">
          <span className={`app-footer-tech-health app-footer-tech-health--${health}`}>
            {health}
          </span>
          <div className="app-footer-tech-links">
            <a href="/__diag" target="_blank" rel="noopener noreferrer">
              DIAG
            </a>
          </div>
        </div>
      </div>
    </footer>
  )
}
