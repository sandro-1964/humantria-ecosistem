# HUMANTRÍA — RESPONSIVE CONTRACT (LOCAL) — V1

Status: BLOQUEANTE  
Escopo: layout responsivo (shell + páginas)

━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRINCÍPIO
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Responsivo é requisito de plataforma:
- desktop-first
- tablet e smartphone suportados sem quebrar navegação
- sem “layout invisível” que vira tela em branco

━━━━━━━━━━━━━━━━━━━━━━━━━━━
BREAKPOINTS (V1)
━━━━━━━━━━━━━━━━━━━━━━━━━━━

O Design System deve expor tokens/breakpoints equivalentes a:
- sm: 0–639
- md: 640–1023
- lg: 1024+

(Valores exatos podem variar no design system, mas devem ser consistentes.)

━━━━━━━━━━━━━━━━━━━━━━━━━━━
SHELL (REGRAS)
━━━━━━━━━━━━━━━━━━━━━━━━━━━

1) Existe apenas **uma** navegação lateral (sidebar) da plataforma.
2) É proibido “sidebar por produto”. Produtos entram como itens no menu global.
3) Em mobile:
   - sidebar vira drawer
   - header mantém acesso ao seletor de idioma e perfil

━━━━━━━━━━━━━━━━━━━━━━━━━━━
PÁGINAS (REGRAS)
━━━━━━━━━━━━━━━━━━━━━━━━━━━

1) Padrões V1 obrigatórios:
- lista → detalhe
- admin/settings
- timeline
- wizard

2) Componentes devem lidar com conteúdo longo e tabelas:
- scroll interno controlado
- truncation/overflow seguro
