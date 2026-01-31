import React from 'react';
import { useApp, UserRole } from '@/contexts/AppContext';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import {
  Shield,
  Users,
  BarChart3,
  Eye,
  ChevronDown,
} from 'lucide-react';

interface RoleConfig {
  label: string;
  description: string;
  icon: React.ElementType;
  color: string;
}

const roleConfigs: Record<UserRole, RoleConfig> = {
  admin: {
    label: 'Admin',
    description: 'Acesso completo à plataforma',
    icon: Shield,
    color: 'bg-destructive/10 text-destructive',
  },
  gestor: {
    label: 'Gestor',
    description: 'Gestão de equipe e aprovações',
    icon: Users,
    color: 'bg-primary/10 text-primary',
  },
  analista: {
    label: 'Analista',
    description: 'Análise e relatórios',
    icon: BarChart3,
    color: 'bg-teal/10 text-teal',
  },
  auditor: {
    label: 'Auditor',
    description: 'Somente leitura e compliance',
    icon: Eye,
    color: 'bg-warning/10 text-warning',
  },
};

export function RoleSwitcher() {
  const { currentRole, setCurrentRole } = useApp();
  const config = roleConfigs[currentRole];
  const Icon = config.icon;

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="sm" className="gap-2 h-8">
          <Badge variant="secondary" className={`${config.color} gap-1.5 font-medium`}>
            <Icon className="h-3 w-3" />
            {config.label}
          </Badge>
          <ChevronDown className="h-3 w-3 text-muted-foreground" />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-56">
        <DropdownMenuLabel className="font-normal">
          <div className="flex flex-col gap-1">
            <span className="text-xs text-muted-foreground">Simulação de Perfil</span>
            <span className="text-sm font-medium">Selecione um perfil para teste</span>
          </div>
        </DropdownMenuLabel>
        <DropdownMenuSeparator />
        {(Object.keys(roleConfigs) as UserRole[]).map((role) => {
          const roleConfig = roleConfigs[role];
          const RoleIcon = roleConfig.icon;
          const isActive = role === currentRole;
          
          return (
            <DropdownMenuItem
              key={role}
              onClick={() => setCurrentRole(role)}
              className={`gap-3 cursor-pointer ${isActive ? 'bg-muted' : ''}`}
            >
              <div className={`h-8 w-8 rounded-lg flex items-center justify-center ${roleConfig.color}`}>
                <RoleIcon className="h-4 w-4" />
              </div>
              <div className="flex-1">
                <div className="text-sm font-medium">{roleConfig.label}</div>
                <div className="text-xs text-muted-foreground">{roleConfig.description}</div>
              </div>
              {isActive && (
                <div className="h-2 w-2 rounded-full bg-primary" />
              )}
            </DropdownMenuItem>
          );
        })}
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
