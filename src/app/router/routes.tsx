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
import { ToolsDocsPage } from '../pages/tools/ToolsDocsPage'
import { ToolsLegacyIntegrationsPage } from '../pages/tools/ToolsLegacyIntegrationsPage'
import { AppShell } from '../../shell/AppShell'
import { RequireAuth, RequireTenant } from './guards'

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
        { path: '/foundation/tenants', element: <TenantsListPage /> },
        { path: '/foundation/tenants/:tenantId', element: <TenantDetailPage /> },
        { path: '/foundation/admin/settings', element: <TenantSettingsPage /> },
        { path: '/foundation/admin/users-roles', element: <UsersAndRolesPage /> },
        { path: '/foundation/audit', element: <AuditTimelinePage /> },
        { path: '/foundation/wizard/bootstrap', element: <TenantBootstrapWizardPage /> },

        { path: '/tools/docs', element: <ToolsDocsPage /> },
        { path: '/tools/legacy-integrations', element: <ToolsLegacyIntegrationsPage /> }
      ],
    },
  ])
}

