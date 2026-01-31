/**
 * Router canônico: BrowserRouter + Routes + Shell com Outlet.
 */
import { BrowserRouter, Routes } from 'react-router-dom'
import { routes } from './routes'

export function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        {routes()}
      </Routes>
    </BrowserRouter>
  )
}
