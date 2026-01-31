import { Outlet } from 'react-router-dom'
import { useTranslation } from 'react-i18next'

import { setLocale, getLocale } from '../i18n'
import { useBrand } from '../providers/brand/BrandProvider'
import { toText } from '../lib/to-text'
import { MenuGate } from '../components/guards/MenuGate'
import { Sidebar, SidebarNav, SidebarNavItem } from '../design-system/components'

export function AppShell() {
  const { t } = useTranslation()
  const brand = useBrand()
  const locale = getLocale()

  return (
    <div style={{ display: 'grid', gridTemplateColumns: '260px 1fr', minHeight: '100vh' }}>
      <Sidebar>
        <div style={{ marginBottom: '1rem' }}>
          <div style={{ fontSize: 12, opacity: 0.7 }}>{toText(t('app.title'))}</div>
          <div style={{ fontSize: 16, fontWeight: 700 }}>
            {toText(brand.tenantName ?? t('nav.foundation'))}
          </div>
        </div>

        <div style={{ marginBottom: '1rem' }}>
          <label style={{ fontSize: 12, opacity: 0.7 }}>Language</label>
          <div>
            <select
              value={locale}
              onChange={(e) => setLocale(e.target.value)}
              style={{ width: '100%', padding: 8, borderRadius: 8 }}
            >
              <option value="pt-BR">pt-BR</option>
              <option value="en-US">en-US</option>
            </select>
          </div>
        </div>

        <SidebarNav>
          <SidebarNavItem to="/__diag" label={t('nav.diag')} />
        </SidebarNav>

        <SidebarNav label={toText(t('nav.foundation'))}>
          <SidebarNavItem to="/foundation" label={t('nav.foundation')} />
          <MenuGate allowRoles={['platform_owner']}>
            <SidebarNavItem to="/foundation/tenants" label={t('nav.tenants')} />
          </MenuGate>
          <MenuGate allowRoles={['platform_owner', 'tenant_admin']}>
            <SidebarNavItem to="/foundation/admin/settings" label={t('nav.settings')} />
          </MenuGate>
          <MenuGate allowRoles={['platform_owner', 'tenant_admin']}>
            <SidebarNavItem to="/foundation/admin/users-roles" label={t('nav.usersRoles')} />
          </MenuGate>
          <MenuGate allowRoles={['platform_owner', 'tenant_admin', 'auditor']}>
            <SidebarNavItem to="/foundation/audit" label={t('nav.audit')} />
          </MenuGate>
          <MenuGate allowRoles={['platform_owner', 'tenant_admin']}>
            <SidebarNavItem to="/foundation/wizard/bootstrap" label={t('nav.wizard')} />
          </MenuGate>
        </SidebarNav>

        <SidebarNav label="Strategy">
          <MenuGate allowRoles={['platform_owner', 'tenant_admin', 'gestor', 'especialista', 'auditor']}>
            <SidebarNavItem to="/strategy" label="Strategy" />
            <SidebarNavItem to="/strategy/objectives" label="Objectives" />
            <SidebarNavItem to="/strategy/initiatives" label="Initiatives" />
            <SidebarNavItem to="/strategy/snapshot" label="Snapshot" />
          </MenuGate>
        </SidebarNav>

        <SidebarNav label={toText(t('nav.tools'))}>
          <SidebarNavItem to="/tools/docs" label={t('nav.docs')} />
          <MenuGate allowRoles={['platform_owner', 'tenant_admin']}>
            <SidebarNavItem to="/tools/legacy-integrations" label={t('nav.legacy')} />
          </MenuGate>
        </SidebarNav>
      </Sidebar>

      <main style={{ padding: 20 }}>
        <Outlet />
      </main>
    </div>
  )
}
