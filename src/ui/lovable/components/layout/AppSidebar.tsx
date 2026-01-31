import React, { useState, useEffect } from 'react';
import { useApp } from '@/contexts/AppContext';
import { cn } from '@/lib/utils';
import { NavLink, useLocation } from 'react-router-dom';
import {
  Home,
  Compass,
  Database,
  Users,
  GitBranch,
  LineChart,
  Wrench,
  Settings,
  ChevronLeft,
  ChevronRight,
  UserCheck,
  TrendingUp,
  Clock,
  Shield,
  Brain,
  Layers,
  Music2,
  LucideIcon,
  Menu,
  AlertTriangle,
  Scale,
  Briefcase,
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { ScrollArea } from '@/components/ui/scroll-area';
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from '@/components/ui/tooltip';
import { Sheet, SheetContent, SheetTrigger } from '@/components/ui/sheet';

interface NavItem {
  label: string;
  icon: LucideIcon;
  href: string;
  productId?: string;
  adminOnly?: boolean;
  children?: { label: string; href: string; adminOnly?: boolean }[];
}

interface NavGroup {
  label: string;
  items: NavItem[];
}

// Grouped navigation structure
const navigationGroups: NavGroup[] = [
  {
    label: '',
    items: [
      { label: 'Home', icon: Home, href: '/home' },
      { label: 'Decision Hub', icon: Compass, href: '/decision-hub' },
    ],
  },
  {
    label: 'Platform',
    items: [
      {
        label: 'Foundation',
        icon: Database,
        href: '/foundation',
        productId: 'foundation',
        adminOnly: true,
        children: [
          { label: 'Tenants', href: '/foundation/tenants', adminOnly: true },
          { label: 'IAM', href: '/foundation/iam', adminOnly: true },
          { label: 'Feature Flags', href: '/foundation/feature-flags', adminOnly: true },
          { label: 'Audit', href: '/foundation/audit' },
          { label: 'Events', href: '/foundation/events' },
          { label: 'Privacy/LGPD', href: '/foundation/privacy' },
          { label: 'AI Governance', href: '/foundation/ai-governance' },
          { label: 'Billing', href: '/foundation/billing', adminOnly: true },
          { label: 'Templates', href: '/foundation/templates' },
          { label: 'Owner Console', href: '/foundation/owner', adminOnly: true },
        ],
      },
      {
        label: 'Core',
        icon: Users,
        href: '/core',
        productId: 'core',
        children: [
          { label: 'Organization', href: '/core/organization' },
          { label: 'People', href: '/core/people' },
          { label: 'Assignments', href: '/core/assignments' },
          { label: 'Jobs & Levels', href: '/core/jobs' },
          { label: 'Import Center', href: '/core/import' },
          { label: 'Economics', href: '/core/economics' },
        ],
      },
      {
        label: 'Bridges',
        icon: GitBranch,
        href: '/bridges',
        productId: 'bridges',
        adminOnly: true,
        children: [
          { label: 'Event Monitor', href: '/bridges/events' },
          { label: 'Consumers', href: '/bridges/consumers' },
          { label: 'Failures', href: '/bridges/failures' },
          { label: 'Retries', href: '/bridges/retries' },
          { label: 'Correlation', href: '/bridges/correlation' },
          { label: 'Connectors', href: '/bridges/connectors' },
          { label: 'Diagnostics', href: '/bridges/diagnostics' },
        ],
      },
    ],
  },
  {
    label: 'Products',
    items: [
      {
        label: 'Strategy',
        icon: LineChart,
        href: '/strategy',
        productId: 'strategy',
        children: [
          { label: 'Dashboard', href: '/strategy/dashboard' },
          { label: 'Objectives', href: '/strategy/objectives' },
          { label: 'Templates', href: '/strategy/templates' },
          { label: 'Approvals', href: '/strategy/approvals' },
          { label: 'Budget', href: '/strategy/budget' },
          { label: 'Staffing', href: '/strategy/staffing' },
          { label: 'Scenarios', href: '/strategy/scenarios' },
          { label: 'Workflows', href: '/strategy/workflows' },
          { label: 'Risk Alerts', href: '/strategy/risks' },
          { label: 'AI Insights', href: '/strategy/ai' },
          { label: 'Org Chart', href: '/strategy/org-chart' },
        ],
      },
      {
        label: 'Talent',
        icon: UserCheck,
        href: '/talent',
        productId: 'talent',
        children: [
          { label: 'Dashboard', href: '/talent/dashboard' },
          { label: 'Vacancies', href: '/talent/vacancies' },
          { label: 'Candidates', href: '/talent/candidates' },
          { label: 'Talent Pool', href: '/talent/pool' },
        ],
      },
      {
        label: 'Evolution',
        icon: TrendingUp,
        href: '/evolution',
        productId: 'evolution',
        children: [
          { label: 'Dashboard', href: '/evolution/dashboard' },
          { label: 'Assessments', href: '/evolution/assessments' },
          { label: 'Development', href: '/evolution/development' },
          { label: 'Learning Paths', href: '/evolution/learning' },
        ],
      },
      {
        label: 'Chronos',
        icon: Clock,
        href: '/chronos',
        productId: 'chronos',
        children: [
          { label: 'Dashboard', href: '/chronos/dashboard' },
          { label: 'Time Planning', href: '/chronos/planning' },
          { label: 'Schedules', href: '/chronos/schedules' },
          { label: 'Allocation', href: '/chronos/allocation' },
        ],
      },
      {
        label: 'Operations & Risk',
        icon: AlertTriangle,
        href: '/operations',
        productId: 'operations',
        children: [
          { label: 'Dashboard', href: '/operations/dashboard' },
          { label: 'Controls', href: '/operations/controls' },
          { label: 'Incidents', href: '/operations/incidents' },
          { label: 'Mitigation', href: '/operations/mitigation' },
        ],
      },
      {
        label: 'GRC',
        icon: Scale,
        href: '/grc',
        productId: 'grc',
        children: [
          { label: 'Dashboard', href: '/grc/dashboard' },
          { label: 'Policies', href: '/grc/policies' },
          { label: 'Audits', href: '/grc/audits' },
          { label: 'Action Plans', href: '/grc/action-plans' },
        ],
      },
      {
        label: 'Intelligence',
        icon: Brain,
        href: '/intelligence',
        productId: 'intelligence',
        children: [
          { label: 'Dashboard', href: '/intelligence/dashboard' },
          { label: 'Insights', href: '/intelligence/insights' },
          { label: 'Recommendations', href: '/intelligence/recommendations' },
          { label: 'Narratives', href: '/intelligence/narratives' },
        ],
      },
      {
        label: 'Synergy',
        icon: Layers,
        href: '/synergy',
        productId: 'synergy',
        children: [
          { label: 'Dashboard', href: '/synergy/dashboard' },
          { label: 'Job Architecture', href: '/synergy/jobs' },
          { label: 'Competencies', href: '/synergy/competencies' },
          { label: 'Compensation', href: '/synergy/compensation' },
        ],
      },
      {
        label: 'Orchestra',
        icon: Music2,
        href: '/orchestra',
        productId: 'orchestra',
        children: [
          { label: 'Dashboard', href: '/orchestra/dashboard' },
          { label: 'HRBP', href: '/orchestra/hrbp' },
          { label: 'SSC', href: '/orchestra/ssc' },
          { label: 'CoEs', href: '/orchestra/coes' },
          { label: 'Change Management', href: '/orchestra/change' },
        ],
      },
    ],
  },
  {
    label: 'Tools',
    items: [
      {
        label: 'Tools',
        icon: Wrench,
        href: '/tools',
        productId: 'tools',
        children: [
          { label: 'Sandbox', href: '/tools/sandbox' },
          { label: 'Import Center', href: '/tools/import' },
          { label: 'Export Center', href: '/tools/export' },
          { label: 'Files Hub', href: '/tools/files' },
          { label: 'Notifications', href: '/tools/notifications' },
          { label: 'Messages', href: '/tools/messages' },
          { label: 'Help Center', href: '/tools/help' },
          { label: 'Diagnostics', href: '/tools/diagnostics' },
          { label: 'Languages', href: '/tools/languages' },
          { label: 'Personalization', href: '/tools/personalization' },
          { label: 'Documentation', href: '/tools/documentation' },
          { label: 'Legacy Integrations', href: '/tools/legacy-integrations' },
        ],
      },
    ],
  },
  {
    label: '',
    items: [
      { label: 'Settings', icon: Settings, href: '/settings' },
    ],
  },
];

function SidebarContent({ 
  collapsed, 
  onNavigate 
}: { 
  collapsed: boolean;
  onNavigate?: () => void;
}) {
  const location = useLocation();
  const { hasProduct, canAccess, currentRole } = useApp();
  const [expandedItem, setExpandedItem] = React.useState<string | null>(null);

  // Check if user can see item based on role
  const canSeeItem = (item: NavItem) => {
    // Check product availability
    if (item.productId && !hasProduct(item.productId)) {
      return false;
    }
    // Check admin-only items
    if (item.adminOnly && !canAccess('canSeeAdmin')) {
      return false;
    }
    return true;
  };

  // Exclusive accordion: find which group contains current route
  const getActiveGroup = React.useCallback(() => {
    for (const group of navigationGroups) {
      for (const item of group.items) {
        if (item.children) {
          for (const child of item.children) {
            if (location.pathname === child.href || location.pathname.startsWith(child.href + '/')) {
              return item.label;
            }
          }
        }
      }
    }
    return null;
  }, [location.pathname]);

  // Update expanded item when route changes
  React.useEffect(() => {
    const newActiveGroup = getActiveGroup();
    if (newActiveGroup) {
      setExpandedItem(newActiveGroup);
    }
  }, [getActiveGroup]);

  // Exclusive accordion toggle - only one open at a time
  const toggleExpand = (label: string) => {
    setExpandedItem(prev => prev === label ? null : label);
  };

  const isActive = (href: string) => location.pathname === href || location.pathname.startsWith(href + '/');

  const handleNavClick = () => {
    if (onNavigate) {
      onNavigate();
    }
  };

  // Filter visible children based on role
  const getVisibleChildren = (children: NavItem['children']) => {
    if (!children) return [];
    return children.filter(child => {
      if (child.adminOnly && !canAccess('canSeeAdmin')) return false;
      return true;
    });
  };

  return (
    <ScrollArea className="flex-1 py-3">
      <nav className="px-2 space-y-1">
        {navigationGroups.map((group, groupIndex) => {
          // Filter items based on product/role visibility
          const visibleItems = group.items.filter(canSeeItem);
          if (visibleItems.length === 0) return null;

          return (
            <div key={groupIndex} className="mb-2">
              {/* Group Label */}
              {group.label && !collapsed && (
                <div className="px-3 py-2">
                  <span className="text-[10px] font-semibold uppercase tracking-wider text-muted-foreground/70">
                    {group.label}
                  </span>
                </div>
              )}
              
              {/* Group Items */}
              {visibleItems.map((item) => {
                const hasChildren = item.children && item.children.length > 0;
                const visibleChildren = getVisibleChildren(item.children);
                const isExpanded = expandedItem === item.label;
                const isItemActive = isActive(item.href);

                if (collapsed) {
                  return (
                    <Tooltip key={item.label} delayDuration={0}>
                      <TooltipTrigger asChild>
                        <NavLink
                          to={hasChildren && visibleChildren.length > 0 ? visibleChildren[0].href : item.href}
                          onClick={handleNavClick}
                          className={cn(
                            'flex items-center justify-center h-10 w-full rounded-lg transition-all duration-150',
                            isItemActive
                              ? 'bg-sidebar-accent text-sidebar-accent-foreground shadow-sm'
                              : 'text-sidebar-foreground hover:bg-sidebar-accent/50 hover:text-sidebar-accent-foreground'
                          )}
                        >
                          <item.icon className="h-5 w-5" />
                        </NavLink>
                      </TooltipTrigger>
                      <TooltipContent side="right" className="flex flex-col gap-1 max-h-80 overflow-y-auto">
                        <p className="font-medium">{item.label}</p>
                        {hasChildren && visibleChildren.length > 0 && (
                          <div className="space-y-1 pt-1 border-t border-border/50">
                            {visibleChildren.map((child) => (
                              <NavLink
                                key={child.href}
                                to={child.href}
                                onClick={handleNavClick}
                                className="block text-xs hover:text-foreground transition-colors"
                              >
                                {child.label}
                              </NavLink>
                            ))}
                          </div>
                        )}
                      </TooltipContent>
                    </Tooltip>
                  );
                }

                return (
                  <div key={item.label} className="mb-0.5">
                    {hasChildren && visibleChildren.length > 0 ? (
                      <>
                        <button
                          onClick={() => toggleExpand(item.label)}
                          className={cn(
                            'flex items-center justify-between w-full h-9 px-3 rounded-lg text-sm transition-all duration-150',
                            isItemActive
                              ? 'bg-sidebar-accent text-sidebar-accent-foreground font-medium shadow-sm'
                              : 'text-sidebar-foreground hover:bg-sidebar-accent/50 hover:text-sidebar-accent-foreground'
                          )}
                        >
                          <div className="flex items-center gap-3">
                            <item.icon className="h-4 w-4 shrink-0" />
                            <span className="truncate">{item.label}</span>
                          </div>
                          <ChevronRight
                            className={cn(
                              'h-4 w-4 transition-transform duration-200 shrink-0',
                              isExpanded && 'rotate-90'
                            )}
                          />
                        </button>
                        <div 
                          className={cn(
                            'overflow-hidden transition-all duration-200 ease-out',
                            isExpanded ? 'max-h-[500px] opacity-100' : 'max-h-0 opacity-0'
                          )}
                        >
                          <div className="ml-7 mt-1 space-y-0.5 border-l border-sidebar-border/30 pl-3 py-1">
                            {visibleChildren.map((child) => (
                              <NavLink
                                key={child.href}
                                to={child.href}
                                onClick={handleNavClick}
                                className={cn(
                                  'block py-1.5 px-2 text-sm rounded-md transition-all duration-150',
                                  location.pathname === child.href
                                    ? 'text-sidebar-primary font-medium bg-sidebar-accent/80'
                                    : 'text-sidebar-foreground/70 hover:text-sidebar-foreground hover:bg-sidebar-accent/40'
                                )}
                              >
                                {child.label}
                              </NavLink>
                            ))}
                          </div>
                        </div>
                      </>
                    ) : (
                      <NavLink
                        to={item.href}
                        onClick={handleNavClick}
                        className={cn(
                          'flex items-center gap-3 h-9 px-3 rounded-lg text-sm transition-all duration-150',
                          isItemActive
                            ? 'bg-sidebar-accent text-sidebar-accent-foreground font-medium shadow-sm'
                            : 'text-sidebar-foreground hover:bg-sidebar-accent/50 hover:text-sidebar-accent-foreground'
                        )}
                      >
                        <item.icon className="h-4 w-4 shrink-0" />
                        <span className="truncate">{item.label}</span>
                      </NavLink>
                    )}
                  </div>
                );
              })}
            </div>
          );
        })}
      </nav>
    </ScrollArea>
  );
}

// Mobile Drawer Component
export function MobileSidebar() {
  const [open, setOpen] = useState(false);

  return (
    <Sheet open={open} onOpenChange={setOpen}>
      <SheetTrigger asChild>
        <Button variant="ghost" size="sm" className="md:hidden">
          <Menu className="h-5 w-5" />
        </Button>
      </SheetTrigger>
      <SheetContent side="left" className="w-72 p-0 bg-sidebar border-r border-sidebar-border/50">
        <div className="h-full flex flex-col">
          <div className="h-14 flex items-center px-4 border-b border-sidebar-border/30">
            <span className="font-semibold text-sidebar-foreground">Menu</span>
          </div>
          <SidebarContent collapsed={false} onNavigate={() => setOpen(false)} />
        </div>
      </SheetContent>
    </Sheet>
  );
}

// Desktop Sidebar Component
export function AppSidebar() {
  const { sidebarCollapsed, setSidebarCollapsed } = useApp();

  return (
    <aside
      className={cn(
        'hidden md:flex h-full bg-sidebar border-r border-sidebar-border/50 flex-col shrink-0 transition-all duration-200 ease-out',
        sidebarCollapsed ? 'w-16' : 'w-60'
      )}
    >
      <SidebarContent collapsed={sidebarCollapsed} />

      {/* Collapse Toggle */}
      <div className="border-t border-sidebar-border/30 p-2">
        <Button
          variant="ghost"
          size="sm"
          onClick={() => setSidebarCollapsed(!sidebarCollapsed)}
          className="w-full justify-center hover:bg-sidebar-accent/50"
        >
          {sidebarCollapsed ? (
            <ChevronRight className="h-4 w-4" />
          ) : (
            <>
              <ChevronLeft className="h-4 w-4 mr-2" />
              <span className="text-xs">Recolher</span>
            </>
          )}
        </Button>
      </div>
    </aside>
  );
}
