import React from 'react';
import { useApp, tenantConfigs } from '@/contexts/AppContext';
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
  Building2,
  ChevronDown,
  Package,
} from 'lucide-react';

export function TenantSwitcher() {
  const { currentTenant, setCurrentTenant } = useApp();

  const tenants = Object.values(tenantConfigs);

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="sm" className="gap-2 h-8 px-2">
          <div className="flex items-center gap-1.5 px-2 py-1 rounded-md bg-muted/50">
            <Building2 className="h-3.5 w-3.5 text-muted-foreground" />
            <span className="text-sm text-muted-foreground max-w-[100px] truncate">
              {currentTenant.name}
            </span>
          </div>
          <ChevronDown className="h-3 w-3 text-muted-foreground" />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="start" className="w-72">
        <DropdownMenuLabel className="font-normal">
          <div className="flex flex-col gap-1">
            <span className="text-xs text-muted-foreground">Simulação de Tenant</span>
            <span className="text-sm font-medium">Selecione uma organização</span>
          </div>
        </DropdownMenuLabel>
        <DropdownMenuSeparator />
        {tenants.map((tenant) => {
          const isActive = tenant.id === currentTenant.id;
          const productCount = tenant.products.length;
          
          return (
            <DropdownMenuItem
              key={tenant.id}
              onClick={() => setCurrentTenant(tenant.id)}
              className={`gap-3 cursor-pointer ${isActive ? 'bg-muted' : ''}`}
            >
              <div className="h-8 w-8 rounded-lg bg-primary/10 flex items-center justify-center">
                <Building2 className="h-4 w-4 text-primary" />
              </div>
              <div className="flex-1">
                <div className="text-sm font-medium">{tenant.name}</div>
                <div className="flex items-center gap-1 text-xs text-muted-foreground">
                  <Package className="h-3 w-3" />
                  <span>{productCount} produtos</span>
                </div>
              </div>
              {isActive && (
                <div className="h-2 w-2 rounded-full bg-primary" />
              )}
            </DropdownMenuItem>
          );
        })}
        <DropdownMenuSeparator />
        <div className="px-2 py-1.5">
          <p className="text-xs text-muted-foreground">
            Alterar tenant simula diferentes configurações de produtos e funcionalidades.
          </p>
        </div>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
