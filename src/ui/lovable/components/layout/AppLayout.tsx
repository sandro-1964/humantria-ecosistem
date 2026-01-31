import React from 'react';
import { AppHeader } from './AppHeader';
import { AppSidebar, MobileSidebar } from './AppSidebar';
import { AppFooter } from './AppFooter';
import { CommandPalette } from '@/components/features/CommandPalette';
import { cn } from '@/lib/utils';

interface AppLayoutProps {
  children: React.ReactNode;
}

export function AppLayout({ children }: AppLayoutProps) {
  return (
    <div className="layout-shell">
      <AppHeader />
      <div className="layout-main">
        <AppSidebar />
        <main className="layout-content scrollbar-thin">
          {children}
        </main>
      </div>
      <AppFooter />
      <CommandPalette />
    </div>
  );
}
