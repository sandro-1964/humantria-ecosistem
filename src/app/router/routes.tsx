import { createBrowserRouter, Navigate } from 'react-router-dom'

import { DiagHome } from '../diag/DiagHome'
import { DiagMeta } from '../diag/DiagMeta'
import { FoundationHomePage } from '../pages/foundation/FoundationHomePage'
import { TenantsListPage } from '../pages/foundation/tenants/TenantsListPage'
import { TenantDetailPage } from '../pages/foundation/tenants/TenantDetailPage'
import { TenantSettingsPage } from '../pages/foundation/admin/TenantSettingsPage'
import { UsersAndRolesPage } from '../pages/foundation/admin/UsersAndRolesPage'
import { AuditTimelinePage } from '../pages/foundation/audit/AuditTimelinePage'
import { TenantBootstrapWizardPage } from '../pages/foundation/wizard/TenantBootstrapWizardPage'
import { CoreStubPage } from '../pages/core/CoreStubPage'
import { StrategyStubPage } from '../pages/strategy/StrategyStubPage'
import { ToolsDocsPage } from '../pages/tools/ToolsDocsPage'
import { ToolsLegacyIntegrationsPage } from '../pages/tools/ToolsLegacyIntegrationsPage'
import { AppShell } from '../../shell/AppShell'
import { RequireAuth, RequireRole, RequireTenant } from './guards'

export function createAppRouter() {
  return createBrowserRouter([
    { path: '/', element: <Navigate to="/foundation" replace /> },

    { path: '/__diag', element: <DiagHome /> },
    { path: '/__diag/meta', element: <DiagMeta /> },

    {
      path: '/',
      element: (
        <RequireAuth>
          <RequireTenant>
            <AppShell />
          </RequireTenant>
        </RequireAuth>
      ),
      children: [
        { path: '/foundation', element: <FoundationHomePage /> },
        {
          path: '/foundation/tenants',
          element: (
            <RequireRole roles={['platform_owner', 'admin']}>
              <TenantsListPage />
            </RequireRole>
          ),
        },
        {
          path: '/foundation/tenants/:tenantId',
          element: (
            <RequireRole roles={['platform_owner', 'admin']}>
              <TenantDetailPage />
            </RequireRole>
          ),
        },
        {
          path: '/foundation/admin/settings',
          element: (
            <RequireRole roles={['tenant_admin', 'admin']}>
              <TenantSettingsPage />
            </RequireRole>
          ),
        },
        {
          path: '/foundation/admin/users-roles',
          element: (
            <RequireRole roles={['tenant_admin', 'admin']}>
              <UsersAndRolesPage />
            </RequireRole>
          ),
        },
        {
          path: '/foundation/audit',
          element: (
            <RequireRole roles={['platform_owner', 'tenant_admin', 'auditor', 'admin', 'manager', 'analyst', 'auditor']}>
              <AuditTimelinePage />
            </RequireRole>
          ),
        },
        {
          path: '/foundation/wizard/bootstrap',
          element: (
            <RequireRole roles={['tenant_admin', 'admin']}>
              <TenantBootstrapWizardPage />
            </RequireRole>
          ),
        },

        { path: '/core', element: <CoreStubPage /> },
        { path: '/strategy', element: <StrategyStubPage /> },

        { path: '/tools/docs', element: <ToolsDocsPage /> },
        {
          path: '/tools/legacy-integrations',
          element: (
            <RequireRole roles={['platform_owner', 'tenant_admin', 'admin']}>
              <ToolsLegacyIntegrationsPage />
            </RequireRole>
          ),
        },
      ],
    },
  ])
}

