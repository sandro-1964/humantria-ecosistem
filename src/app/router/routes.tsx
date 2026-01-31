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
import { StrategyHomePage } from '../pages/strategy/StrategyHomePage'
import { ObjectivesListPage } from '../pages/strategy/objectives/ObjectivesListPage'
import { ObjectiveDetailPage } from '../pages/strategy/objectives/ObjectiveDetailPage'
import { ObjectiveFormPage } from '../pages/strategy/objectives/ObjectiveFormPage'
import { ObjectiveApprovePage } from '../pages/strategy/objectives/ObjectiveApprovePage'
import { InitiativesListPage } from '../pages/strategy/initiatives/InitiativesListPage'
import { InitiativeDetailPage } from '../pages/strategy/initiatives/InitiativeDetailPage'
import { InitiativeFormPage } from '../pages/strategy/initiatives/InitiativeFormPage'
import { SnapshotPage } from '../pages/strategy/SnapshotPage'
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
            <RequireRole roles={['platform_owner']}>
              <TenantsListPage />
            </RequireRole>
          ),
        },
        {
          path: '/foundation/tenants/:tenantId',
          element: (
            <RequireRole roles={['platform_owner']}>
              <TenantDetailPage />
            </RequireRole>
          ),
        },
        {
          path: '/foundation/admin/settings',
          element: (
            <RequireRole roles={['tenant_admin']}>
              <TenantSettingsPage />
            </RequireRole>
          ),
        },
        {
          path: '/foundation/admin/users-roles',
          element: (
            <RequireRole roles={['tenant_admin']}>
              <UsersAndRolesPage />
            </RequireRole>
          ),
        },
        {
          path: '/foundation/audit',
          element: (
            <RequireRole roles={['platform_owner', 'tenant_admin', 'auditor']}>
              <AuditTimelinePage />
            </RequireRole>
          ),
        },
        {
          path: '/foundation/wizard/bootstrap',
          element: (
            <RequireRole roles={['tenant_admin']}>
              <TenantBootstrapWizardPage />
            </RequireRole>
          ),
        },

        { path: '/tools/docs', element: <ToolsDocsPage /> },
        {
          path: '/tools/legacy-integrations',
          element: (
            <RequireRole roles={['platform_owner', 'tenant_admin']}>
              <ToolsLegacyIntegrationsPage />
            </RequireRole>
          ),
        },

        {
          path: '/strategy',
          element: (
            <RequireRole roles={['platform_owner', 'tenant_admin', 'gestor', 'especialista', 'auditor']}>
              <StrategyHomePage />
            </RequireRole>
          ),
        },
        {
          path: '/strategy/objectives',
          element: (
            <RequireRole roles={['platform_owner', 'tenant_admin', 'gestor', 'especialista', 'auditor']}>
              <ObjectivesListPage />
            </RequireRole>
          ),
        },
        {
          path: '/strategy/objectives/new',
          element: (
            <RequireRole roles={['platform_owner', 'tenant_admin', 'gestor']}>
              <ObjectiveFormPage />
            </RequireRole>
          ),
        },
        {
          path: '/strategy/objectives/:id',
          element: (
            <RequireRole roles={['platform_owner', 'tenant_admin', 'gestor', 'especialista', 'auditor']}>
              <ObjectiveDetailPage />
            </RequireRole>
          ),
        },
        {
          path: '/strategy/objectives/:id/approve',
          element: (
            <RequireRole roles={['platform_owner', 'tenant_admin', 'gestor']}>
              <ObjectiveApprovePage />
            </RequireRole>
          ),
        },
        {
          path: '/strategy/initiatives',
          element: (
            <RequireRole roles={['platform_owner', 'tenant_admin', 'gestor', 'especialista', 'auditor']}>
              <InitiativesListPage />
            </RequireRole>
          ),
        },
        {
          path: '/strategy/initiatives/new',
          element: (
            <RequireRole roles={['platform_owner', 'tenant_admin', 'gestor']}>
              <InitiativeFormPage />
            </RequireRole>
          ),
        },
        {
          path: '/strategy/initiatives/:id',
          element: (
            <RequireRole roles={['platform_owner', 'tenant_admin', 'gestor', 'especialista', 'auditor']}>
              <InitiativeDetailPage />
            </RequireRole>
          ),
        },
        {
          path: '/strategy/snapshot',
          element: (
            <RequireRole roles={['platform_owner', 'tenant_admin', 'gestor', 'especialista', 'auditor']}>
              <SnapshotPage />
            </RequireRole>
          ),
        },
      ],
    },
  ])
}

