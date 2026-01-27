/**
 * HUMANTRÍA — Header
 * 
 * Cabeçalho com branding, navegação principal, perfil do usuário.
 */

import './Header.css'

export function Header() {
  return (
    <header className="app-header">
      <div className="app-header-content">
        <div className="app-header-brand">
          {/* Logo será inserido aqui */}
          <span className="app-header-logo-text">HUMANTRÍA</span>
        </div>
        <nav className="app-header-nav">
          {/* Navegação principal */}
        </nav>
        <div className="app-header-actions">
          {/* Perfil, notificações, etc. */}
        </div>
      </div>
    </header>
  )
}
