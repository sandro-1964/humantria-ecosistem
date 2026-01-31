import * as React from "react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { LucideIcon, Inbox, Plus, Search, FileX, FolderOpen, Users, BarChart3 } from "lucide-react";

interface EmptyStateProps {
  icon?: LucideIcon;
  title: string;
  description?: string;
  action?: {
    label: string;
    onClick: () => void;
  };
  secondaryAction?: {
    label: string;
    onClick: () => void;
  };
  variant?: 'default' | 'search' | 'files' | 'data' | 'users';
  className?: string;
}

const variantConfig = {
  default: { icon: Inbox, illustration: 'inbox' },
  search: { icon: Search, illustration: 'search' },
  files: { icon: FolderOpen, illustration: 'files' },
  data: { icon: BarChart3, illustration: 'data' },
  users: { icon: Users, illustration: 'users' },
};

export function EmptyState({
  icon,
  title,
  description,
  action,
  secondaryAction,
  variant = 'default',
  className,
}: EmptyStateProps) {
  const config = variantConfig[variant];
  const Icon = icon || config.icon;

  return (
    <div className={cn(
      "flex flex-col items-center justify-center py-16 px-6 text-center",
      "animate-in fade-in-50 duration-500",
      className
    )}>
      {/* Illustrated icon container */}
      <div className="relative mb-6">
        {/* Background decoration */}
        <div className="absolute inset-0 -m-4 rounded-full bg-gradient-to-br from-muted/50 to-muted/20 blur-xl" />
        
        {/* Main icon container */}
        <div className="relative rounded-2xl bg-gradient-to-br from-muted to-muted/50 p-6 shadow-sm border border-border/30">
          <Icon className="h-10 w-10 text-muted-foreground/70" strokeWidth={1.5} />
        </div>
        
        {/* Decorative dots */}
        <div className="absolute -top-1 -right-1 h-3 w-3 rounded-full bg-primary/20" />
        <div className="absolute -bottom-2 -left-2 h-2 w-2 rounded-full bg-primary/10" />
      </div>
      
      {/* Text content */}
      <h3 className="text-lg font-semibold text-foreground">{title}</h3>
      {description && (
        <p className="mt-2 max-w-md text-sm text-muted-foreground leading-relaxed">
          {description}
        </p>
      )}
      
      {/* Actions */}
      {(action || secondaryAction) && (
        <div className="mt-6 flex items-center gap-3">
          {action && (
            <Button onClick={action.onClick} className="gap-2">
              <Plus className="h-4 w-4" />
              {action.label}
            </Button>
          )}
          {secondaryAction && (
            <Button variant="outline" onClick={secondaryAction.onClick}>
              {secondaryAction.label}
            </Button>
          )}
        </div>
      )}
    </div>
  );
}

// Preset empty states for common scenarios
export function EmptySearchState({ onClear }: { onClear?: () => void }) {
  return (
    <EmptyState
      variant="search"
      title="Nenhum resultado encontrado"
      description="Tente ajustar seus filtros ou termos de busca para encontrar o que procura."
      action={onClear ? { label: "Limpar busca", onClick: onClear } : undefined}
    />
  );
}

export function EmptyDataState({ onCreate }: { onCreate?: () => void }) {
  return (
    <EmptyState
      variant="data"
      title="Nenhum dado disponível"
      description="Comece adicionando seu primeiro registro para visualizar informações aqui."
      action={onCreate ? { label: "Adicionar primeiro", onClick: onCreate } : undefined}
    />
  );
}
