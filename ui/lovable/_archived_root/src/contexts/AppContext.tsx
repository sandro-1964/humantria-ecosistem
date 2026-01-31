import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { Language } from '@/lib/i18n';

type Theme = 'light' | 'dark';
type Density = 'compact' | 'comfortable' | 'spacious';
export type UserRole = 'admin' | 'gestor' | 'analista' | 'auditor';

// Tenant configuration with enabled products
export interface TenantConfig {
  id: string;
  name: string;
  products: string[];
  features: string[];
}

export const tenantConfigs: Record<string, TenantConfig> = {
  'acme-corp': {
    id: 'acme-corp',
    name: 'Acme Corp',
    products: ['foundation', 'core', 'bridges', 'strategy', 'talent', 'evolution', 'chronos', 'operations', 'grc', 'intelligence', 'synergy', 'orchestra', 'tools'],
    features: ['ai', 'advanced-analytics', 'workflows'],
  },
  'beta-ltd': {
    id: 'beta-ltd',
    name: 'Beta Ltd',
    products: ['foundation', 'core', 'bridges', 'strategy', 'talent', 'tools'],
    features: ['ai'],
  },
  'gamma-smb': {
    id: 'gamma-smb',
    name: 'Gamma SMB',
    products: ['core', 'strategy', 'tools'],
    features: [],
  },
};

// Role permissions for UI visibility
export const rolePermissions: Record<UserRole, {
  canSeeAdmin: boolean;
  canSeeBilling: boolean;
  canSeeAudit: boolean;
  canEditData: boolean;
  canApprove: boolean;
}> = {
  admin: {
    canSeeAdmin: true,
    canSeeBilling: true,
    canSeeAudit: true,
    canEditData: true,
    canApprove: true,
  },
  gestor: {
    canSeeAdmin: false,
    canSeeBilling: false,
    canSeeAudit: false,
    canEditData: true,
    canApprove: true,
  },
  analista: {
    canSeeAdmin: false,
    canSeeBilling: false,
    canSeeAudit: false,
    canEditData: false,
    canApprove: false,
  },
  auditor: {
    canSeeAdmin: false,
    canSeeBilling: false,
    canSeeAudit: true,
    canEditData: false,
    canApprove: false,
  },
};

interface AppContextType {
  theme: Theme;
  setTheme: (theme: Theme) => void;
  language: Language;
  setLanguage: (lang: Language) => void;
  density: Density;
  setDensity: (density: Density) => void;
  sidebarCollapsed: boolean;
  setSidebarCollapsed: (collapsed: boolean) => void;
  commandPaletteOpen: boolean;
  setCommandPaletteOpen: (open: boolean) => void;
  // Role and Tenant
  currentRole: UserRole;
  setCurrentRole: (role: UserRole) => void;
  currentTenant: TenantConfig;
  setCurrentTenant: (tenantId: string) => void;
  // Helpers
  hasProduct: (productId: string) => boolean;
  hasFeature: (featureId: string) => boolean;
  canAccess: (permission: keyof typeof rolePermissions.admin) => boolean;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export const AppProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [theme, setThemeState] = useState<Theme>(() => {
    const saved = localStorage.getItem('humantria-theme');
    return (saved as Theme) || 'light';
  });
  
  const [language, setLanguageState] = useState<Language>(() => {
    const saved = localStorage.getItem('humantria-language');
    return (saved as Language) || 'en';
  });
  
  const [density, setDensityState] = useState<Density>(() => {
    const saved = localStorage.getItem('humantria-density');
    return (saved as Density) || 'comfortable';
  });
  
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [commandPaletteOpen, setCommandPaletteOpen] = useState(false);
  
  // Role and Tenant state
  const [currentRole, setCurrentRole] = useState<UserRole>('admin');
  const [currentTenant, setCurrentTenantState] = useState<TenantConfig>(tenantConfigs['acme-corp']);

  const setCurrentTenant = (tenantId: string) => {
    const tenant = tenantConfigs[tenantId];
    if (tenant) {
      setCurrentTenantState(tenant);
    }
  };

  // Helper functions
  const hasProduct = (productId: string) => currentTenant.products.includes(productId);
  const hasFeature = (featureId: string) => currentTenant.features.includes(featureId);
  const canAccess = (permission: keyof typeof rolePermissions.admin) => rolePermissions[currentRole][permission];

  useEffect(() => {
    const root = window.document.documentElement;
    root.classList.remove('light', 'dark');
    root.classList.add(theme);
    localStorage.setItem('humantria-theme', theme);
  }, [theme]);

  useEffect(() => {
    localStorage.setItem('humantria-language', language);
  }, [language]);

  useEffect(() => {
    localStorage.setItem('humantria-density', density);
    const root = window.document.documentElement;
    root.classList.remove('density-compact', 'density-comfortable', 'density-spacious');
    root.classList.add(`density-${density}`);
  }, [density]);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault();
        setCommandPaletteOpen(prev => !prev);
      }
    };
    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, []);

  const setTheme = (newTheme: Theme) => setThemeState(newTheme);
  const setLanguage = (newLang: Language) => setLanguageState(newLang);
  const setDensity = (newDensity: Density) => setDensityState(newDensity);

  return (
    <AppContext.Provider
      value={{
        theme,
        setTheme,
        language,
        setLanguage,
        density,
        setDensity,
        sidebarCollapsed,
        setSidebarCollapsed,
        commandPaletteOpen,
        setCommandPaletteOpen,
        currentRole,
        setCurrentRole,
        currentTenant,
        setCurrentTenant,
        hasProduct,
        hasFeature,
        canAccess,
      }}
    >
      {children}
    </AppContext.Provider>
  );
};

export const useApp = () => {
  const context = useContext(AppContext);
  if (context === undefined) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
};
