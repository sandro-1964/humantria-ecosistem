import { NavLink, Outlet } from 'react-router-dom'
import { useTranslation } from 'react-i18next'

import { setLocale, getLocale } from '../i18n'
import { useBrand } from '../providers/brand/BrandProvider'
import { useTenant } from '../providers/tenant/TenantProvider'
import { useRbac } from '../providers/rbac/RbacProvider'
import { toText } from '../lib/to-text'
import { MenuGate } from '../components/guards/MenuGate'
import { ActionGate } from '../components/guards/ActionGate'
import {
  getDemoSession,
  setDemoSession,
  clearDemoSession,
  createDemoSession,
  type DemoRole,
} from '../services/demo/demo-session'

const DEMO_ROLES: { value: DemoRole; label: string }[] = [
  { value: 'admin', label: 'Admin' },
  { value: 'manager', label: 'Gestor' },
  { value: 'analyst', label: 'Analista' },
  { value: 'auditor', label: 'Auditor' },
]

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
  const tenant = useTenant()
  const rbac = useRbac()
  const demo = getDemoSession()

  const locale = getLocale()

  return (
    <div style={{ display: 'grid', gridTemplateColumns: '260px 1fr', minHeight: '100vh' }}>
      <aside style={{ padding: 16, borderRight: '1px solid rgba(0,0,0,0.08)' }}>
        <div style={{ marginBottom: 16 }}>
          <div style={{ fontSize: 12, opacity: 0.7 }}>{toText(t('app.title'))}</div>
          <div style={{ fontSize: 16, fontWeight: 700, display: 'flex', alignItems: 'center', gap: 8 }}>
            {toText(brand.tenantName ?? t('nav.foundation'))}
            {demo?.enabled ? (
              <span
                style={{
                  fontSize: 10,
                  padding: '2px 6px',
                  borderRadius: 4,
                  background: '#e0f2fe',
                  color: '#0369a1',
                  fontWeight: 600,
                }}
              >
                DEMO
              </span>
            ) : null}
          </div>
        </div>

        {demo?.enabled ? (
          <div style={{ marginBottom: 16, padding: 10, background: 'rgba(0,0,0,0.04)', borderRadius: 8 }}>
            <div style={{ fontSize: 11, fontWeight: 600, opacity: 0.8, marginBottom: 6 }}>
              {toText(t('shell.demoProfileTitle'))}
            </div>
            <select
              value={demo.role}
              onChange={(e) => {
                const role = e.target.value as DemoRole
                if (['admin', 'manager', 'analyst', 'auditor'].includes(role)) {
                  setDemoSession(createDemoSession(role))
                }
              }}
              style={{ width: '100%', padding: 6, borderRadius: 6, fontSize: 12 }}
            >
              {DEMO_ROLES.map((r) => (
                <option key={r.value} value={r.value}>
                  {r.label}
                </option>
              ))}
            </select>
            <button
              type="button"
              onClick={() => clearDemoSession()}
              style={{
                marginTop: 6,
                width: '100%',
                padding: 6,
                fontSize: 11,
                borderRadius: 6,
                background: 'transparent',
                border: '1px solid rgba(0,0,0,0.2)',
              }}
            >
              {toText(t('shell.exitDemo'))}
            </button>
          </div>
        ) : null}

        <div style={{ marginBottom: 16 }}>
          <label style={{ fontSize: 12, opacity: 0.7 }}>{toText(t('shell.language'))}</label>
          <div>
            <select
              value={locale}
              onChange={(e) => setLocale(e.target.value)}
              style={{ width: '100%', padding: 8, borderRadius: 8 }}
            >
              <option value="pt-BR">pt-BR</option>
              <option value="en-US">en-US</option>
              <option value="es-ES">es-ES</option>
            </select>
          </div>
        </div>

        <nav style={{ display: 'grid', gap: 4 }}>
          <MenuItem to="/__diag" label={t('nav.diag')} />

          <div style={{ marginTop: 10, fontSize: 12, opacity: 0.7 }}>{toText(t('nav.foundation'))}</div>
          <MenuItem to="/foundation" label={t('nav.foundation')} />

          <MenuGate allowRoles={['platform_owner', 'admin']}>
            <MenuItem to="/foundation/tenants" label={t('nav.tenants')} />
          </MenuGate>

          <MenuGate allowRoles={['platform_owner', 'tenant_admin', 'admin']}>
            <MenuItem to="/foundation/admin/settings" label={t('nav.settings')} />
          </MenuGate>

          <MenuGate allowRoles={['platform_owner', 'tenant_admin', 'admin']}>
            <MenuItem to="/foundation/admin/users-roles" label={t('nav.usersRoles')} />
          </MenuGate>

          <MenuGate allowRoles={['platform_owner', 'tenant_admin', 'auditor', 'admin', 'manager', 'analyst', 'auditor']}>
            <MenuItem to="/foundation/audit" label={t('nav.audit')} />
          </MenuGate>

          <MenuGate allowRoles={['platform_owner', 'tenant_admin', 'admin']}>
            <MenuItem to="/foundation/wizard/bootstrap" label={t('nav.wizard')} />
          </MenuGate>

          <div style={{ marginTop: 10, fontSize: 12, opacity: 0.7 }}>{toText(t('nav.tools'))}</div>
          <MenuItem to="/tools/docs" label={t('nav.docs')} />
          <MenuGate allowRoles={['platform_owner', 'tenant_admin', 'admin']}>
            <MenuItem to="/tools/legacy-integrations" label={t('nav.legacy')} />
          </MenuGate>
        </nav>
      </aside>

      <main style={{ padding: 20, display: 'flex', flexDirection: 'column', minHeight: 0 }}>
        {demo?.enabled ? (
          <div
            style={{
              display: 'flex',
              gap: 8,
              marginBottom: 12,
              paddingBottom: 8,
              borderBottom: '1px solid rgba(0,0,0,0.06)',
              flexWrap: 'wrap',
            }}
          >
            <ActionGate permission="action:simulate">
              <button type="button" style={{ padding: '6px 10px', borderRadius: 6, fontSize: 12 }}>
                Simulate
              </button>
            </ActionGate>
            <ActionGate permission="action:suggest_ai">
              <button type="button" style={{ padding: '6px 10px', borderRadius: 6, fontSize: 12 }}>
                Suggest with AI
              </button>
            </ActionGate>
            <ActionGate permission="action:explain_ai">
              <button type="button" style={{ padding: '6px 10px', borderRadius: 6, fontSize: 12 }}>
                Explain with AI
              </button>
            </ActionGate>
          </div>
        ) : null}
        <div style={{ flex: 1 }}>
          <Outlet />
        </div>
        {demo?.enabled ? (
          <footer
            style={{
              marginTop: 16,
              paddingTop: 8,
              borderTop: '1px solid rgba(0,0,0,0.06)',
              fontSize: 11,
              opacity: 0.7,
            }}
          >
            DEMO • {toText(rbac.role ?? '—')} • {toText(tenant.tenantName ?? '—')}
          </footer>
        ) : null}
      </main>
    </div>
  )
}

