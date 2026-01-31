/**
 * Wrapper Strategy: Dashboard — reexport do Lovable kit.
 * UI Contract: dados exibidos via toText/renderValue (Lovable page usa strings/numbers nas células).
 */
import LovableDashboardPage from '@/ui/lovable/pages/strategy/DashboardPage'

export default function DashboardPage() {
  return <LovableDashboardPage />
}
