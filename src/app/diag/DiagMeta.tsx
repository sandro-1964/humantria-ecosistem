import { useLocation } from 'react-router-dom'

import { useAuth } from '../../providers/auth/AuthProvider'
import { useTenant } from '../../providers/tenant/TenantProvider'
import { useRbac } from '../../providers/rbac/RbacProvider'
import { useFlags } from '../../providers/flags/FlagsProvider'
import { useBrand } from '../../providers/brand/BrandProvider'
import { getDemoSession } from '../../services/demo/demo-session'
import { hasSupabaseEnv } from '../../services/supabase/client'
import { buildInfo } from '../../lib/build-info'
import { toText } from '../../lib/to-text'

function buildFallbackMeta(error: unknown) {
  return {
    error: 'diag_render_error',
    build: buildInfo,
    timestamp: new Date().toISOString(),
    message: error instanceof Error ? error.message : String(error),
  }
}

export function DiagMeta() {
  const location = useLocation()
  const auth = useAuth()
  const tenant = useTenant()
  const rbac = useRbac()
  const flags = useFlags()
  const brand = useBrand()
  const demo = getDemoSession()

  let meta: object
  try {
    meta = {
      build: buildInfo,
      environment: {
        env: import.meta.env.MODE,
        supabaseConfigured: hasSupabaseEnv(),
        demo: { enabled: demo?.enabled ?? false },
      },
      health: {
        auth: { status: auth.status },
        tenant: { status: tenant.status },
        rbac: { status: rbac.status },
        flags: { status: flags.status },
        brand: { status: brand.status },
      },
      route: { pathname: location.pathname },
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
  } catch (err) {
    meta = buildFallbackMeta(err)
  }

  let jsonText: string
  try {
    jsonText = JSON.stringify(meta, null, 2)
  } catch {
    jsonText = JSON.stringify(buildFallbackMeta(new Error('JSON.stringify failed')), null, 2)
  }

  return (
    <div style={{ padding: 24 }}>
      <h1>__diag/meta</h1>
      <pre style={{ whiteSpace: 'pre-wrap', fontSize: 12 }}>{toText(jsonText)}</pre>
    </div>
  )
}
