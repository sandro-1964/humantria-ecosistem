import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import StrategyHomePage from '../pages/strategy/StrategyHomePage'
import DiagnosticsPage from '../pages/DiagnosticsPage'

export default function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/strategy" replace />} />
        <Route path="/strategy" element={<StrategyHomePage />} />
        <Route path="/__diag" element={<DiagnosticsPage />} />
      </Routes>
    </BrowserRouter>
  )
}
