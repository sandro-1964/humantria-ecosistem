import { useTenant } from '../../../providers/tenant/TenantProvider'
import { useRbac } from '../../../providers/rbac/RbacProvider'
import { getDemoSession } from '../../../services/demo/demo-session'
import { getDemoSeed } from '../../../services/demo/demo-seed'
import { toText } from '../../../lib/to-text'

export function FoundationHomePage() {
  const tenant = useTenant()
  const rbac = useRbac()
  const demo = getDemoSession()

  if (demo?.enabled) {
    const seed = getDemoSeed()
    return (
      <div>
        <h1>Foundation (Decision Hub)</h1>
        <p style={{ fontSize: 12, opacity: 0.8 }}>
          Tenant: {toText(tenant.tenantName ?? tenant.tenantId ?? 'unknown')} · Role: {toText(rbac.role ?? '—')}
        </p>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(160px, 1fr))', gap: 12, marginTop: 16 }}>
          {seed.kpis.map((k) => (
            <div
              key={k.id}
              style={{
                padding: 12,
                border: '1px solid rgba(0,0,0,0.08)',
                borderRadius: 8,
                background: 'rgba(0,0,0,0.02)',
              }}
            >
              <div style={{ fontSize: 11, opacity: 0.7 }}>{toText(k.label)}</div>
              <div style={{ fontSize: 18, fontWeight: 700 }}>
                {typeof k.value === 'number' ? k.value : toText(k.value)}
                {k.unit ? toText(k.unit) : ''}
              </div>
              {k.trend ? (
                <div style={{ fontSize: 10, marginTop: 4, opacity: 0.7 }}>
                  {k.trend === 'up' ? '↑' : k.trend === 'down' ? '↓' : '→'}
                </div>
              ) : null}
            </div>
          ))}
        </div>
        <div style={{ marginTop: 24 }}>
          <div style={{ fontSize: 12, opacity: 0.7, marginBottom: 8 }}>Demo chart (últimos 6 meses)</div>
          <div style={{ display: 'flex', alignItems: 'flex-end', gap: 8, height: 120 }}>
            {seed.chartSeries.map((p) => (
              <div
                key={p.label}
                style={{
                  flex: 1,
                  minWidth: 40,
                  height: `${Math.max(20, (p.value / 1300) * 100)}%`,
                  background: 'rgba(0,0,0,0.1)',
                  borderRadius: 4,
                  fontSize: 10,
                  display: 'flex',
                  alignItems: 'flex-end',
                  justifyContent: 'center',
                  paddingBottom: 4,
                }}
                title={`${p.label}: ${p.value}`}
              >
                {p.value}
              </div>
            ))}
          </div>
          <div style={{ display: 'flex', gap: 8, marginTop: 4, fontSize: 10, opacity: 0.7 }}>
            {seed.chartSeries.map((p) => (
              <span key={p.label}>{toText(p.label)}</span>
            ))}
          </div>
        </div>
      </div>
    )
  }

  return (
    <div>
      <h1>Foundation</h1>
      <p>Tenant: {toText(tenant.tenantName ?? tenant.tenantId ?? 'unknown')}</p>
      <p>Role: {toText(rbac.role ?? 'unknown')}</p>
    </div>
  )
}

