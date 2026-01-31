import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './ui/lovable/styles/index.css'
import './ui/lovable/styles/App.css'
import './index.css'
import './design-system/design-system.css'
import App from './App.tsx'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
