/**
 * HUMANTRÍA — Sidebar
 * 
 * Menu lateral com produtos (Strategy, Talent, Ops, etc.).
 * Colapsa em mobile, expande/colapsa em desktop.
 */

import { useState } from 'react'
import strategyIconLight from '../assets/product-icons/strategy-icon-light.svg'
import strategyIconDark from '../assets/product-icons/strategy-icon-dark.svg'
import './Sidebar.css'

interface MenuItem {
  id: string
  label: string
  href: string
  icon?: string
  badge?: string
}

const menuItems: MenuItem[] = [
  { id: 'home', label: 'Home', href: '/' },
  { id: 'foundation', label: 'Foundation', href: '/foundation' },
  { id: 'core', label: 'Core', href: '/core' },
  { id: 'bridges', label: 'Bridges', href: '/bridges' },
  { id: 'strategy', label: 'Strategy', href: '/strategy', icon: strategyIconLight },
  { id: 'tools', label: 'Tools', href: '/tools' },
]

export function Sidebar() {
  const [collapsed, setCollapsed] = useState(false)
  const [activeItem, setActiveItem] = useState('home')

  return (
    <aside className={`app-sidebar ${collapsed ? 'collapsed' : ''}`}>
      <div className="app-sidebar-header">
        <button
          className="app-sidebar-toggle"
          onClick={() => setCollapsed(!collapsed)}
          aria-label={collapsed ? 'Expandir menu' : 'Colapsar menu'}
        >
          {collapsed ? '→' : '←'}
        </button>
      </div>
      <nav className="app-sidebar-nav">
        <ul className="app-sidebar-menu">
          {menuItems.map((item) => (
            <li key={item.id}>
              <a
                href={item.href}
                className={`app-sidebar-menu-item ${activeItem === item.id ? 'active' : ''}`}
                onClick={() => setActiveItem(item.id)}
              >
                {item.icon && (
                  <img
                    src={item.icon}
                    alt=""
                    className="app-sidebar-menu-icon"
                  />
                )}
                {!collapsed && (
                  <>
                    <span className="app-sidebar-menu-label">{item.label}</span>
                    {item.badge && (
                      <span className="app-sidebar-menu-badge">{item.badge}</span>
                    )}
                  </>
                )}
              </a>
            </li>
          ))}
        </ul>
      </nav>
    </aside>
  )
}
