/**
 * HUMANTRÍA — Home Page
 * 
 * Página inicial macro da plataforma.
 * Visão geral, dashboards, acesso rápido a produtos.
 */

import './HomePage.css'

export function HomePage() {
  return (
    <div className="home-page">
      <h1>HUMANTRÍA</h1>
      <p>Plataforma de Governança, Decisão e Inteligência para Capital Humano</p>
      
      <section className="home-page-products">
        <h2>Produtos</h2>
        <div className="home-page-product-grid">
          {/* Cards de produtos serão inseridos aqui */}
        </div>
      </section>
    </div>
  )
}
