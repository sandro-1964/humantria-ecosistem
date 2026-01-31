/**
 * Shell mínimo do app — layout Lovable + Outlet.
 * TODO: plugar MenuGate / RequireRole quando providers existirem.
 * Safe: renderiza mesmo sem auth/tenant.
 */
import { Outlet } from 'react-router-dom'
import { AppLayout } from '@/components/layout/AppLayout'

export function AppShell() {
  return (
    <AppLayout>
      <Outlet />
    </AppLayout>
  )
}
