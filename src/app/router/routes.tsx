/**
 * Rotas canônicas do app (Fase B0).
 * Strategy aponta para wrappers que reexportam páginas do Lovable kit.
 */
import { Navigate, Route } from 'react-router-dom'
import { lazy, Suspense } from 'react'
import { AppShell } from '@/shell/AppShell'

const StrategyDashboardPage = lazy(() => import('@/app/pages/strategy/DashboardPage').then((m) => ({ default: m.default })))
const StrategyObjectivesPage = lazy(() => import('@/app/pages/strategy/ObjectivesPage').then((m) => ({ default: m.default })))
const StrategyApprovalsPage = lazy(() => import('@/app/pages/strategy/ApprovalsPage').then((m) => ({ default: m.default })))
const DiagPage = lazy(() => import('@/app/pages/diag/DiagPage').then((m) => ({ default: m.default })))

export const ROUTES = {
  home: '/',
  strategy: '/strategy',
  strategyObjectives: '/strategy/objectives',
  strategyApprovals: '/strategy/approvals',
  diag: '/__diag',
} as const

function PageFallback() {
  return <div style={{ padding: '1rem' }}>Loading…</div>
}

export function routes() {
  return (
    <>
      <Route path="/" element={<Navigate to={ROUTES.strategy} replace />} />
      <Route path={ROUTES.strategy} element={<AppShell />}>
        <Route index element={<Suspense fallback={<PageFallback />}><StrategyDashboardPage /></Suspense>} />
        <Route path="objectives" element={<Suspense fallback={<PageFallback />}><StrategyObjectivesPage /></Suspense>} />
        <Route path="approvals" element={<Suspense fallback={<PageFallback />}><StrategyApprovalsPage /></Suspense>} />
      </Route>
      <Route path={ROUTES.diag} element={<Suspense fallback={<PageFallback />}><DiagPage /></Suspense>} />
    </>
  )
}
