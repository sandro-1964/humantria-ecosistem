/**
 * HUMANTRÍA — Sidebar
 * 
 * Menu lateral com produtos (Strategy, Talent, Ops, etc.).
 * Colapsa em mobile, expande/colapsa em desktop.
 */

import { useState } from 'react'
import './Sidebar.css'

export function Sidebar() {
  const [collapsed, setCollapsed] = useState(false)

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
        {/* Menu de produtos será inserido aqui */}
        <ul className="app-sidebar-menu">
          <li>
            <a href="/strategy">Strategy</a>
          </li>
        </ul>
      </nav>
    </aside>
  )
}
