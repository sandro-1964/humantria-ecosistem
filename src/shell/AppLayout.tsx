/**
 * HUMANTRÍA — App Layout
 * 
 * Container principal que envolve todas as páginas autenticadas.
 * Inclui Header, Sidebar, conteúdo principal e FooterTech.
 */

import { ReactNode } from 'react'
import { Header } from './Header'
import { Sidebar } from './Sidebar'
import { FooterTech } from './FooterTech'
import './AppLayout.css'

interface AppLayoutProps {
  children: ReactNode
}

export function AppLayout({ children }: AppLayoutProps) {
  return (
    <div className="app-layout">
      <Header />
      <div className="app-layout-body">
        <Sidebar />
        <main className="app-layout-main">
          {children}
        </main>
      </div>
      <FooterTech />
    </div>
  )
}
