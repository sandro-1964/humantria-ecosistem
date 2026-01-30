import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { RouterProvider } from 'react-router-dom'

import '../../i18n'
import { createAppRouter } from '../router/routes'
import { AppProviders } from './AppProviders'
import { ErrorBoundary } from '../../components/ErrorBoundary'

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
})

const router = createAppRouter()

export function AppRoot() {
  return (
    <QueryClientProvider client={queryClient}>
      <ErrorBoundary>
        <AppProviders>
          <RouterProvider router={router} />
        </AppProviders>
      </ErrorBoundary>
    </QueryClientProvider>
  )
}

