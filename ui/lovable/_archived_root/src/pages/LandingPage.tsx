import React from 'react';
import { Link } from 'react-router-dom';
import { useApp } from '@/contexts/AppContext';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { cn } from '@/lib/utils';
import logoSvg from '@/assets/logo-humantria.svg';
import {
  Shield,
  Target,
  FileCheck,
  Brain,
  ArrowRight,
  CheckCircle,
  Sparkles,
} from 'lucide-react';

const features = [
  {
    icon: Shield,
    title: 'Governança',
    description: 'Controle total sobre políticas, acessos e conformidade organizacional com auditoria completa.',
  },
  {
    icon: Target,
    title: 'Decisão',
    description: 'Fluxos de aprovação estruturados com rastreabilidade e evidências documentadas.',
  },
  {
    icon: FileCheck,
    title: 'Evidência',
    description: 'Cada decisão registrada com histórico, justificativas e trilha de auditoria imutável.',
  },
  {
    icon: Brain,
    title: 'IA Assistiva',
    description: 'Insights inteligentes, sugestões contextuais e análise preditiva para decisões melhores.',
  },
];

const highlights = [
  'Multi-tenant enterprise-ready',
  'Conformidade LGPD/GDPR integrada',
  'Workflows customizáveis',
  'APIs abertas e conectores',
  'Relatórios e dashboards avançados',
  'Suporte a múltiplos idiomas',
];

export default function LandingPage() {
  const { theme } = useApp();

  return (
    <div className="min-h-screen bg-gradient-to-b from-background via-background to-muted/30">
      {/* Hero Section */}
      <header className="relative overflow-hidden">
        {/* Background decoration */}
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <div className="absolute -top-1/2 -right-1/4 w-[800px] h-[800px] rounded-full bg-primary/5 blur-3xl" />
          <div className="absolute -bottom-1/2 -left-1/4 w-[600px] h-[600px] rounded-full bg-teal/5 blur-3xl" />
        </div>

        <div className="relative max-w-7xl mx-auto px-6 pt-12 pb-24 lg:pt-20 lg:pb-32">
          {/* Logo institucional - 48-56px, menor que headline */}
          <div className="flex justify-center mb-6 md:mb-8">
            <img 
              src={logoSvg} 
              alt="HUMANTRÍA" 
              className="h-[38px] md:h-[43px] lg:h-12 w-auto"
              style={{ 
                filter: theme === 'dark' ? 'brightness(0) invert(1)' : 'none'
              }}
            />
          </div>

          {/* Headline */}
          <div className="text-center max-w-4xl mx-auto">
            <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold text-foreground tracking-tight mb-6">
              Plataforma de Governança de
              <span className="bg-gradient-to-r from-primary via-indigo to-teal bg-clip-text text-transparent"> Decisões</span>
            </h1>
            <p className="text-lg md:text-xl text-muted-foreground max-w-2xl mx-auto mb-10">
              Transforme decisões de capital humano em processos auditáveis, 
              evidenciados e assistidos por inteligência artificial.
            </p>

            {/* CTAs */}
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Button asChild size="lg" className="gap-2 h-12 px-8 text-base font-medium shadow-lg shadow-primary/25">
                <Link to="/decision-hub">
                  Entrar na Plataforma
                  <ArrowRight className="h-4 w-4" />
                </Link>
              </Button>
              <Button asChild variant="outline" size="lg" className="gap-2 h-12 px-8 text-base font-medium">
                <Link to="/tools/documentation">
                  Conhecer a Plataforma
                </Link>
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Value Props Section */}
      <section className="py-20 lg:py-28">
        <div className="max-w-7xl mx-auto px-6">
          <div className="text-center mb-16">
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-teal/10 text-teal mb-6">
              <Sparkles className="h-4 w-4" />
              <span className="text-sm font-medium">Solução Enterprise Completa</span>
            </div>
            <h2 className="text-3xl md:text-4xl font-bold text-foreground mb-4">
              Tudo que você precisa para governar decisões
            </h2>
            <p className="text-muted-foreground max-w-2xl mx-auto">
              Uma plataforma unificada para gestão de capital humano com foco em 
              compliance, evidências e inteligência de decisão.
            </p>
          </div>

          {/* Feature Cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {features.map((feature) => (
              <Card 
                key={feature.title} 
                className="group relative overflow-hidden border-border/50 bg-card/80 backdrop-blur-sm hover:shadow-lg hover:shadow-primary/5 transition-all duration-300"
              >
                <CardContent className="p-6">
                  <div className="h-12 w-12 rounded-xl bg-primary/10 flex items-center justify-center mb-4 group-hover:bg-primary/20 transition-colors">
                    <feature.icon className="h-6 w-6 text-primary" />
                  </div>
                  <h3 className="text-lg font-semibold text-foreground mb-2">
                    {feature.title}
                  </h3>
                  <p className="text-sm text-muted-foreground leading-relaxed">
                    {feature.description}
                  </p>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Highlights Section */}
      <section className="py-16 bg-muted/30">
        <div className="max-w-7xl mx-auto px-6">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            <div>
              <h2 className="text-3xl font-bold text-foreground mb-6">
                Pronto para a sua empresa
              </h2>
              <p className="text-muted-foreground mb-8">
                HUMANTRÍA foi construído para atender às necessidades de organizações 
                que exigem controle, segurança e rastreabilidade em suas operações de capital humano.
              </p>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                {highlights.map((item) => (
                  <div key={item} className="flex items-center gap-3">
                    <CheckCircle className="h-5 w-5 text-success shrink-0" />
                    <span className="text-sm text-foreground">{item}</span>
                  </div>
                ))}
              </div>
            </div>
            <div className="relative">
              <div className="aspect-video rounded-2xl bg-gradient-to-br from-primary/20 via-indigo/10 to-teal/20 border border-border/50 flex items-center justify-center">
                <div className="text-center p-8">
                  <div className="text-5xl font-bold text-primary mb-2">12+</div>
                  <div className="text-sm text-muted-foreground">Módulos Integrados</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-12 border-t border-border/50">
        <div className="max-w-7xl mx-auto px-6">
          <div className="flex flex-col md:flex-row items-center justify-between gap-6">
            <div className="flex items-center gap-3">
              <img 
                src={logoSvg} 
                alt="HUMANTRÍA" 
                className="h-7 w-auto"
                style={{ 
                  filter: theme === 'dark' ? 'brightness(0) invert(1)' : 'none'
                }}
              />
              <span className="text-sm text-muted-foreground">
                © 2024 HUMANTRÍA. Todos os direitos reservados.
              </span>
            </div>
            <div className="flex items-center gap-6 text-sm text-muted-foreground">
              <Link to="/foundation/privacy" className="hover:text-foreground transition-colors">
                Privacidade
              </Link>
              <Link to="/tools/documentation" className="hover:text-foreground transition-colors">
                Documentação
              </Link>
              <Link to="/tools/help" className="hover:text-foreground transition-colors">
                Suporte
              </Link>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
