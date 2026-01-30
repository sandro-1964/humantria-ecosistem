import type { ErrorInfo, ReactNode } from 'react'
import { Component } from 'react'

type Props = { children: ReactNode }

type State = { hasError: boolean }

export class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false }

  static getDerivedStateFromError(): State {
    return { hasError: true }
  }

  componentDidCatch(error: Error, info: ErrorInfo): void {
    console.error(error, info)
  }

  render() {
    if (this.state.hasError) {
      return (
        <div style={{ padding: 24, fontFamily: 'system-ui, sans-serif', maxWidth: 480 }}>
          <h1 style={{ margin: '0 0 12px 0', fontSize: 20 }}>Algo deu errado</h1>
          <p style={{ margin: '0 0 16px 0', color: '#555', fontSize: 14 }}>
            Ocorreu um erro inesperado. Use o link abaixo para abrir o diagnóstico e ver o estado da aplicação.
          </p>
          <a href="/__diag" style={{ fontSize: 14, color: '#0066cc' }}>
            Abrir diagnóstico
          </a>
        </div>
      )
    }
    return this.props.children
  }
}
