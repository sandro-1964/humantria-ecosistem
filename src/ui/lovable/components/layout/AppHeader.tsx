import React from 'react';
import { useApp } from '@/contexts/AppContext';
import { cn } from '@/lib/utils';
import {
  Search,
  Bell,
  MessageSquare,
  Moon,
  Sun,
  Languages,
  ChevronDown,
  User,
  LogOut,
  Settings,
  Grid3X3,
} from 'lucide-react';
import logoSvg from '@/assets/logo-humantria.svg';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { RoleSwitcher } from './RoleSwitcher';
import { TenantSwitcher } from './TenantSwitcher';
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from '@/components/ui/tooltip';
import { MobileSidebar } from './AppSidebar';

export function AppHeader() {
  const { theme, setTheme, language, setLanguage, setCommandPaletteOpen } = useApp();

  return (
    <header className="h-14 border-b border-border/50 bg-card px-4 flex items-center justify-between shrink-0">
      {/* Left Section - Logo & Product Switcher */}
      <div className="flex items-center gap-3 md:gap-4">
        {/* Mobile Menu */}
        <MobileSidebar />
        
        {/* Logo container - 34px visual height, 40-44px total area */}
        <div className="h-10 md:h-11 flex items-center py-2 md:py-2.5">
          <img 
            src={logoSvg} 
            alt="HUMANTRÍA" 
            className="h-[28px] md:h-[31px] lg:h-[34px] w-auto object-contain"
            style={{ 
              filter: theme === 'dark' ? 'brightness(0) invert(1)' : 'none'
            }}
          />
        </div>

        <div className="hidden md:block h-6 w-px bg-border/50" />

        {/* Tenant Switcher - Hidden on mobile */}
        <div className="hidden lg:block">
          <TenantSwitcher />
        </div>

        {/* Product Switcher - Hidden on mobile */}
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" size="sm" className="gap-2 hidden md:flex">
              <Grid3X3 className="h-4 w-4" />
              <span>Strategy</span>
              <ChevronDown className="h-3 w-3" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="start" className="w-48">
            <DropdownMenuLabel>Produtos</DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem>Decision Hub</DropdownMenuItem>
            <DropdownMenuItem>Foundation</DropdownMenuItem>
            <DropdownMenuItem>Core</DropdownMenuItem>
            <DropdownMenuItem>Bridges</DropdownMenuItem>
            <DropdownMenuItem className="font-medium">Strategy</DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>

      {/* Center - Global Search - Hidden on mobile */}
      <div className="hidden md:flex flex-1 max-w-md mx-8">
        <div className="relative w-full">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            placeholder="Buscar... (⌘K)"
            className="pl-9 bg-muted/50 border-border/50 focus:border-primary/50"
            onClick={() => setCommandPaletteOpen(true)}
            readOnly
          />
        </div>
      </div>

      {/* Right Section */}
      <div className="flex items-center gap-1">
        {/* Role Switcher - Hidden on mobile */}
        <div className="hidden lg:block">
          <RoleSwitcher />
        </div>

        <div className="hidden lg:block h-6 w-px bg-border/50 mx-1" />

        {/* Language Selector - Hidden on mobile */}
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" size="sm" className="gap-1.5 hidden md:flex">
              <Languages className="h-4 w-4" />
              <span className="uppercase text-xs">{language}</span>
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem onClick={() => setLanguage('en')}>
              English
            </DropdownMenuItem>
            <DropdownMenuItem onClick={() => setLanguage('pt')}>
              Português
            </DropdownMenuItem>
            <DropdownMenuItem onClick={() => setLanguage('es')}>
              Español
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>

        {/* Theme Toggle */}
        <Tooltip>
          <TooltipTrigger asChild>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}
            >
              {theme === 'light' ? (
                <Moon className="h-4 w-4" />
              ) : (
                <Sun className="h-4 w-4" />
              )}
            </Button>
          </TooltipTrigger>
          <TooltipContent>Alternar tema</TooltipContent>
        </Tooltip>

        {/* Notifications */}
        <Tooltip>
          <TooltipTrigger asChild>
            <Button variant="ghost" size="sm" className="relative">
              <Bell className="h-4 w-4" />
              <span className="absolute -top-0.5 -right-0.5 h-4 w-4 rounded-full bg-destructive text-destructive-foreground text-[10px] flex items-center justify-center">
                3
              </span>
            </Button>
          </TooltipTrigger>
          <TooltipContent>Notificações</TooltipContent>
        </Tooltip>

        {/* Messages */}
        <Tooltip>
          <TooltipTrigger asChild>
            <Button variant="ghost" size="sm">
              <MessageSquare className="h-4 w-4" />
            </Button>
          </TooltipTrigger>
          <TooltipContent>Mensagens</TooltipContent>
        </Tooltip>

        <div className="h-6 w-px bg-border/50 mx-1" />

        {/* User Menu */}
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" size="sm" className="gap-2">
              <div className="h-7 w-7 rounded-full bg-primary/10 flex items-center justify-center">
                <User className="h-4 w-4 text-primary" />
              </div>
              <div className="text-left hidden lg:block">
                <p className="text-sm font-medium">John Doe</p>
              </div>
              <ChevronDown className="h-3 w-3" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-56">
            <DropdownMenuLabel>
              <div>
                <p className="font-medium">John Doe</p>
                <p className="text-xs text-muted-foreground">john.doe@acme.com</p>
              </div>
            </DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem>
              <User className="h-4 w-4 mr-2" />
              Perfil
            </DropdownMenuItem>
            <DropdownMenuItem>
              <Settings className="h-4 w-4 mr-2" />
              Preferências
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem className="text-destructive">
              <LogOut className="h-4 w-4 mr-2" />
              Sair
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  );
}
