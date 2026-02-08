import AppRouter from './app/router/AppRouter'
import { AppProvider } from './ui/lovable/contexts/AppContext'
import { TooltipProvider } from './ui/lovable/components/ui/tooltip'
import './App.css'

export default function App() {
  return (
    <AppProvider>
      <TooltipProvider>
        <AppRouter />
      </TooltipProvider>
    </AppProvider>
  )
}
