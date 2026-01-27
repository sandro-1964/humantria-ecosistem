/**
 * HUMANTRÍA — Header
 * 
 * Cabeçalho com branding, navegação principal, perfil do usuário.
 */

import { useState } from 'react'
import logoLight from '../assets/brand/humantria-logo-light-exact.svg'
import logoDark from '../assets/brand/humantria-logo-dark-exact.svg'
import './Header.css'

export function Header() {
  const [theme, setTheme] = useState<'light' | 'dark'>('light')
  const [showProductSwitcher, setShowProductSwitcher] = useState(false)
  const [showUserMenu, setShowUserMenu] = useState(false)
  const [showSearch, setShowSearch] = useState(false)

  const logo = theme === 'dark' ? logoDark : logoLight

  return (
    <header className="app-header">
      <div className="app-header-content">
        <div className="app-header-brand">
          <div className="app-header-product-switcher">
            <button
              className="app-header-product-switcher-button"
              onClick={() => setShowProductSwitcher(!showProductSwitcher)}
              aria-label="Trocar produto"
            >
              <img src={logo} alt="HUMANTRÍA" className="app-header-logo" />
              <span className="app-header-logo-text">HUMANTRÍA</span>
              <span className="app-header-chevron">▼</span>
            </button>
            {showProductSwitcher && (
              <div className="app-header-product-switcher-menu">
                <a href="/" className="app-header-product-switcher-item">HUMANTRÍA Platform</a>
                <a href="/strategy" className="app-header-product-switcher-item">Strategy</a>
              </div>
            )}
          </div>
        </div>
        <div className="app-header-center">
          <div className="app-header-tenant">
            <span className="app-header-tenant-label">Tenant:</span>
            <span className="app-header-tenant-value">Acme Corp</span>
          </div>
          <div className="app-header-search">
            <button
              className="app-header-search-button"
              onClick={() => setShowSearch(!showSearch)}
              aria-label="Buscar"
            >
              🔍
            </button>
            {showSearch && (
              <div className="app-header-search-dropdown">
                <input
                  type="text"
                  placeholder="Buscar..."
                  className="app-header-search-input"
                  autoFocus
                />
              </div>
            )}
          </div>
        </div>
        <div className="app-header-actions">
          <button
            className="app-header-notifications"
            aria-label="Notificações"
          >
            🔔
          </button>
          <div className="app-header-user">
            <button
              className="app-header-user-button"
              onClick={() => setShowUserMenu(!showUserMenu)}
              aria-label="Menu do usuário"
            >
              <div className="app-header-user-avatar">U</div>
              <span className="app-header-user-name">Usuário</span>
            </button>
            {showUserMenu && (
              <div className="app-header-user-menu">
                <a href="/tools/account/profile" className="app-header-user-menu-item">Perfil</a>
                <a href="/tools/account/preferences" className="app-header-user-menu-item">Preferências</a>
                <hr className="app-header-user-menu-divider" />
                <button className="app-header-user-menu-item">Sair</button>
              </div>
            )}
          </div>
        </div>
      </div>
    </header>
  )
}
