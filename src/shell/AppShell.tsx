import { NavLink, Outlet } from 'react-router-dom'
import { useTranslation } from 'react-i18next'

import { setLocale, getLocale } from '../i18n'
import { useBrand } from '../providers/brand/BrandProvider'
import { toText } from '../lib/to-text'
import { MenuGate } from '../components/guards/MenuGate'

function MenuItem({ to, label }: { to: string; label: string }) {
  return (
    <div>
      <NavLink
        to={to}
        style={({ isActive }) => ({
          display: 'block',
          padding: '8px 10px',
          textDecoration: 'none',
          color: isActive ? '#111' : '#333',
          fontWeight: isActive ? 700 : 500,
          borderRadius: 8,
          background: isActive ? 'rgba(0,0,0,0.06)' : 'transparent',
        })}
      >
        {toText(label)}
      </NavLink>
    </div>
  )
}

export function AppShell() {
  const { t } = useTranslation()
  const brand = useBrand()

  const locale = getLocale()

  return (
    <div style={{ display: 'grid', gridTemplateColumns: '260px 1fr', minHeight: '100vh' }}>
      <aside style={{ padding: 16, borderRight: '1px solid rgba(0,0,0,0.08)' }}>
        <div style={{ marginBottom: 16 }}>
          <div style={{ fontSize: 12, opacity: 0.7 }}>{toText(t('app.title'))}</div>
          <div style={{ fontSize: 16, fontWeight: 700 }}>
            {toText(brand.tenantName ?? t('nav.foundation'))}
          </div>
        </div>

        <div style={{ marginBottom: 16 }}>
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

        <nav style={{ display: 'grid', gap: 4 }}>
          <MenuItem to="/__diag" label={t('nav.diag')} />

          <div style={{ marginTop: 10, fontSize: 12, opacity: 0.7 }}>{toText(t('nav.foundation'))}</div>
          <MenuItem to="/foundation" label={t('nav.foundation')} />

          <MenuGate allowRoles={['platform_owner']}>
            <MenuItem to="/foundation/tenants" label={t('nav.tenants')} />
          </MenuGate>

          <MenuGate allowRoles={['platform_owner', 'tenant_admin']}>
            <MenuItem to="/foundation/admin/settings" label={t('nav.settings')} />
          </MenuGate>

          <MenuGate allowRoles={['platform_owner', 'tenant_admin']}>
            <MenuItem to="/foundation/admin/users-roles" label={t('nav.usersRoles')} />
          </MenuGate>

          <MenuGate allowRoles={['platform_owner', 'tenant_admin', 'auditor']}>
            <MenuItem to="/foundation/audit" label={t('nav.audit')} />
          </MenuGate>

          <MenuGate allowRoles={['platform_owner', 'tenant_admin']}>
            <MenuItem to="/foundation/wizard/bootstrap" label={t('nav.wizard')} />
          </MenuGate>

          <div style={{ marginTop: 10, fontSize: 12, opacity: 0.7 }}>{toText(t('nav.tools'))}</div>
          <MenuItem to="/tools/docs" label={t('nav.docs')} />
          <MenuGate allowRoles={['platform_owner', 'tenant_admin']}>
            <MenuItem to="/tools/legacy-integrations" label={t('nav.legacy')} />
          </MenuGate>
        </nav>
      </aside>

      <main style={{ padding: 20 }}>
        <Outlet />
      </main>
    </div>
  )
}

