/**
 * DEMO MODE — sessão local (localStorage) para validação UI/UX sem Supabase.
 * Chave: humantria_demo_session_v1
 * Pode ser desativado por flag; não é feature final.
 */

export type DemoRole = 'admin' | 'manager' | 'analyst' | 'auditor'

export type DemoSession = {
  enabled: true
  tenantId: string
  tenantName: string
  userId: string
  userEmail: string
  userName: string
  role: DemoRole
}

const STORAGE_KEY = 'humantria_demo_session_v1'

const DEFAULT_TENANT_ID = 'tenant_demo'
const DEFAULT_TENANT_NAME = 'Humantría Demo'

function demoUserId(role: DemoRole): string {
  return `user_demo_${role}`
}

function demoUserEmail(role: DemoRole): string {
  return `demo+${role}@humantria.local`
}

function demoUserName(role: DemoRole): string {
  const labels: Record<DemoRole, string> = {
    admin: 'Demo Admin',
    manager: 'Demo Gestor',
    analyst: 'Demo Analista',
    auditor: 'Demo Auditor',
  }
  return labels[role]
}

export function getDemoSession(): DemoSession | null {
  if (typeof window === 'undefined' || !window.localStorage) return null
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY)
    if (!raw) return null
    const parsed = JSON.parse(raw) as unknown
    if (
      parsed &&
      typeof parsed === 'object' &&
      'enabled' in parsed &&
      parsed.enabled === true &&
      'tenantId' in parsed &&
      'role' in parsed
    ) {
      const r = (parsed as DemoSession).role
      const validRole: DemoRole[] = ['admin', 'manager', 'analyst', 'auditor']
      if (!validRole.includes(r)) return null
      return parsed as DemoSession
    }
    return null
  } catch {
    return null
  }
}

export const DEMO_SESSION_CHANGE_EVENT = 'humantria_demo_session_change'

export function setDemoSession(session: Omit<DemoSession, 'enabled'>): void {
  if (typeof window === 'undefined' || !window.localStorage) return
  const payload: DemoSession = { ...session, enabled: true }
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(payload))
  window.dispatchEvent(new CustomEvent(DEMO_SESSION_CHANGE_EVENT))
}

export function clearDemoSession(): void {
  if (typeof window === 'undefined' || !window.localStorage) return
  window.localStorage.removeItem(STORAGE_KEY)
  window.dispatchEvent(new CustomEvent(DEMO_SESSION_CHANGE_EVENT))
}

export function createDemoSession(role: DemoRole): DemoSession {
  return {
    enabled: true,
    tenantId: DEFAULT_TENANT_ID,
    tenantName: DEFAULT_TENANT_NAME,
    userId: demoUserId(role),
    userEmail: demoUserEmail(role),
    userName: demoUserName(role),
    role,
  }
}

export function startDemoWithRole(role: DemoRole): void {
  const session = createDemoSession(role)
  setDemoSession(session)
}
