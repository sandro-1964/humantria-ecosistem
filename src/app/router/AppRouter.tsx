import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { AppShell } from '../../shell/AppShell'
import { RequireAuth } from './RequireAuth'
import StrategyHomePage from '../pages/strategy/StrategyHomePage'
import LoginPage from '../pages/auth/LoginPage'
import DiagnosticsPage from '../pages/DiagnosticsPage'

export default function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        <Route element={<AppShell />}>
          <Route path="/" element={<Navigate to="/strategy" replace />} />
          <Route path="/login" element={<LoginPage />} />
          <Route
            path="/strategy"
            element={
              <RequireAuth>
                <StrategyHomePage />
              </RequireAuth>
            }
          />
          <Route path="/__diag" element={<DiagnosticsPage />} />
        </Route>
      </Routes>
    </BrowserRouter>
  )
}
