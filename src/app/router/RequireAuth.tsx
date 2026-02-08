import { useEffect, useState } from 'react'
import { Navigate, useLocation } from 'react-router-dom'
import { getSession } from '../../lib/auth'

export function RequireAuth({ children }: { children: React.ReactNode }) {
  const [status, setStatus] = useState<'loading' | 'authenticated' | 'unauthenticated'>('loading')
  const location = useLocation()

  useEffect(() => {
    getSession().then(({ session }) => {
      setStatus(session ? 'authenticated' : 'unauthenticated')
    })
  }, [])

  if (status === 'loading') return <div style={{ padding: 24 }}>Carregando…</div>
  if (status === 'unauthenticated') return <Navigate to="/login" state={{ from: location }} replace />
  return <>{children}</>
}
