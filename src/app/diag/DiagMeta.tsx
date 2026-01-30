import { useLocation } from 'react-router-dom'

import { useAuth } from '../../providers/auth/AuthProvider'
import { useTenant } from '../../providers/tenant/TenantProvider'
import { useRbac } from '../../providers/rbac/RbacProvider'
import { useFlags } from '../../providers/flags/FlagsProvider'
import { getDemoSession } from '../../services/demo/demo-session'
import { toText } from '../../lib/to-text'

export function DiagMeta() {
  const location = useLocation()
  const auth = useAuth()
  const tenant = useTenant()
  const rbac = useRbac()
  const flags = useFlags()
  const demo = getDemoSession()

  const meta = {
    app: {
      version: import.meta.env.VITE_APP_VERSION ?? 'dev',
      mode: import.meta.env.MODE,
      buildCommit: import.meta.env.VITE_BUILD_COMMIT ?? null,
    },
    route: {
      pathname: location.pathname,
    },
    demo: {
      enabled: demo?.enabled ?? false,
      role: demo?.role ?? null,
      tenantId: demo?.tenantId ?? null,
      userEmail: demo?.userEmail ?? null,
    },
    auth: {
      status: auth.status,
      userId: auth.user?.id ?? null,
      email: auth.user?.email ?? null,
    },
    tenant: {
      status: tenant.status,
      tenantId: tenant.tenantId,
      role: tenant.role,
      tenantName: tenant.tenantName,
      errorMessage: tenant.errorMessage,
    },
    rbac: {
      status: rbac.status,
      role: rbac.role,
      permissionsCount: rbac.permissions.length,
      permissions: rbac.permissions,
    },
    flags: {
      status: flags.status,
      enabledCount: Object.values(flags.flags).filter(Boolean).length,
    },
  }

  return (
    <div style={{ padding: 24 }}>
      <h1>__diag/meta</h1>
      <pre style={{ whiteSpace: 'pre-wrap', fontSize: 12 }}>
        {toText(JSON.stringify(meta, null, 2))}
      </pre>
    </div>
  )
}

