// HUMANTRÍA Mock Data - Realistic enterprise data for UI development
// Personas: Admin, Manager, Analyst, Auditor

export interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'manager' | 'analyst' | 'auditor' | 'viewer';
  department: string;
  avatar?: string;
  status: 'active' | 'inactive' | 'pending';
  lastLogin: string;
}

export interface Tenant {
  id: string;
  name: string;
  domain: string;
  plan: 'enterprise' | 'professional' | 'starter';
  users: number;
  status: 'active' | 'inactive' | 'trial';
  createdAt: string;
}

export interface Decision {
  id: string;
  title: string;
  description: string;
  type: 'budget' | 'headcount' | 'policy' | 'strategic' | 'operational';
  status: 'approved' | 'pending' | 'rejected' | 'draft';
  priority: 'critical' | 'high' | 'medium' | 'low';
  owner: string;
  department: string;
  dueDate: string;
  createdAt: string;
  approvers: string[];
  evidence?: string[];
}

export interface Objective {
  id: string;
  title: string;
  description: string;
  type: 'okr' | 'bsc' | 'kpi';
  status: 'on_track' | 'at_risk' | 'behind' | 'completed';
  progress: number;
  owner: string;
  department: string;
  startDate: string;
  endDate: string;
  keyResults?: { title: string; progress: number }[];
}

export interface AuditEvent {
  id: string;
  action: string;
  entity: string;
  entityId: string;
  user: string;
  timestamp: string;
  details: string;
  ipAddress: string;
  risk: 'high' | 'medium' | 'low';
}

export interface BridgeEvent {
  id: string;
  type: 'sync' | 'webhook' | 'api' | 'batch';
  source: string;
  target: string;
  status: 'success' | 'failed' | 'pending' | 'processing';
  timestamp: string;
  duration: number;
  payload?: string;
  errorMessage?: string;
}

// Mock Users
export const mockUsers: User[] = [
  { id: '1', name: 'Ana Carolina Silva', email: 'ana.silva@empresa.com', role: 'admin', department: 'TI', status: 'active', lastLogin: '2026-01-27T10:30:00Z' },
  { id: '2', name: 'Ricardo Oliveira', email: 'ricardo.oliveira@empresa.com', role: 'manager', department: 'RH', status: 'active', lastLogin: '2026-01-27T09:15:00Z' },
  { id: '3', name: 'Marina Costa', email: 'marina.costa@empresa.com', role: 'analyst', department: 'Finanças', status: 'active', lastLogin: '2026-01-26T16:45:00Z' },
  { id: '4', name: 'Fernando Mendes', email: 'fernando.mendes@empresa.com', role: 'auditor', department: 'Compliance', status: 'active', lastLogin: '2026-01-27T08:00:00Z' },
  { id: '5', name: 'Juliana Santos', email: 'juliana.santos@empresa.com', role: 'manager', department: 'Comercial', status: 'active', lastLogin: '2026-01-26T14:20:00Z' },
  { id: '6', name: 'Carlos Pereira', email: 'carlos.pereira@empresa.com', role: 'analyst', department: 'Operações', status: 'pending', lastLogin: '2026-01-25T11:00:00Z' },
  { id: '7', name: 'Beatriz Lima', email: 'beatriz.lima@empresa.com', role: 'viewer', department: 'Marketing', status: 'active', lastLogin: '2026-01-27T07:30:00Z' },
  { id: '8', name: 'Thiago Fernandes', email: 'thiago.fernandes@empresa.com', role: 'admin', department: 'TI', status: 'inactive', lastLogin: '2026-01-15T10:00:00Z' },
];

// Mock Tenants
export const mockTenants: Tenant[] = [
  { id: '1', name: 'ACME Corporation', domain: 'acme.humantria.io', plan: 'enterprise', users: 1250, status: 'active', createdAt: '2024-01-15' },
  { id: '2', name: 'TechStart Inc', domain: 'techstart.humantria.io', plan: 'professional', users: 85, status: 'active', createdAt: '2024-06-20' },
  { id: '3', name: 'Global Industries', domain: 'global.humantria.io', plan: 'enterprise', users: 3400, status: 'active', createdAt: '2023-09-10' },
  { id: '4', name: 'Innovate Labs', domain: 'innovate.humantria.io', plan: 'starter', users: 25, status: 'trial', createdAt: '2026-01-01' },
];

// Mock Decisions
export const mockDecisions: Decision[] = [
  { id: '1', title: 'Alocação Orçamentária Q1 2026', description: 'Distribuição do orçamento para o primeiro trimestre', type: 'budget', status: 'approved', priority: 'critical', owner: 'Ana Carolina Silva', department: 'Finanças', dueDate: '2026-01-31', createdAt: '2026-01-15', approvers: ['Ricardo Oliveira', 'Fernando Mendes'] },
  { id: '2', title: 'Expansão Headcount - Engenharia', description: 'Aprovação de 15 novas contratações para o time de engenharia', type: 'headcount', status: 'pending', priority: 'high', owner: 'Ricardo Oliveira', department: 'RH', dueDate: '2026-02-15', createdAt: '2026-01-20', approvers: ['Ana Carolina Silva'] },
  { id: '3', title: 'Política de Trabalho Remoto', description: 'Atualização das diretrizes de trabalho híbrido', type: 'policy', status: 'approved', priority: 'medium', owner: 'Juliana Santos', department: 'RH', dueDate: '2026-02-01', createdAt: '2026-01-10', approvers: ['Ricardo Oliveira', 'Ana Carolina Silva'] },
  { id: '4', title: 'Investimento em IA Generativa', description: 'Projeto piloto de IA para automação de processos', type: 'strategic', status: 'pending', priority: 'high', owner: 'Carlos Pereira', department: 'TI', dueDate: '2026-03-01', createdAt: '2026-01-22', approvers: ['Ana Carolina Silva', 'Fernando Mendes'] },
  { id: '5', title: 'Renovação Contrato Cloud', description: 'Renovação do contrato de infraestrutura cloud por 3 anos', type: 'operational', status: 'rejected', priority: 'medium', owner: 'Thiago Fernandes', department: 'TI', dueDate: '2026-01-25', createdAt: '2026-01-05', approvers: ['Ana Carolina Silva'] },
  { id: '6', title: 'Programa de Desenvolvimento de Líderes', description: 'Implementação de programa de capacitação para gestores', type: 'strategic', status: 'draft', priority: 'low', owner: 'Marina Costa', department: 'RH', dueDate: '2026-04-01', createdAt: '2026-01-25', approvers: [] },
];

// Mock Objectives
export const mockObjectives: Objective[] = [
  { id: '1', title: 'Aumentar Receita Recorrente', description: 'Crescer ARR em 40% até o final do ano', type: 'okr', status: 'on_track', progress: 72, owner: 'Juliana Santos', department: 'Comercial', startDate: '2026-01-01', endDate: '2026-12-31', keyResults: [{ title: 'Novos contratos enterprise', progress: 85 }, { title: 'Upsell base existente', progress: 60 }] },
  { id: '2', title: 'Reduzir Turnover', description: 'Diminuir taxa de rotatividade para menos de 10%', type: 'okr', status: 'at_risk', progress: 45, owner: 'Ricardo Oliveira', department: 'RH', startDate: '2026-01-01', endDate: '2026-12-31', keyResults: [{ title: 'Implementar programa de retenção', progress: 80 }, { title: 'Pesquisa de clima mensal', progress: 30 }] },
  { id: '3', title: 'NPS Acima de 70', description: 'Melhorar satisfação do cliente', type: 'kpi', status: 'on_track', progress: 88, owner: 'Beatriz Lima', department: 'CX', startDate: '2026-01-01', endDate: '2026-06-30' },
  { id: '4', title: 'Compliance 100%', description: 'Garantir conformidade total com LGPD e SOC2', type: 'bsc', status: 'completed', progress: 100, owner: 'Fernando Mendes', department: 'Compliance', startDate: '2025-07-01', endDate: '2026-01-15' },
  { id: '5', title: 'Automatização de Processos', description: 'Automatizar 60% dos processos manuais de RH', type: 'okr', status: 'behind', progress: 25, owner: 'Carlos Pereira', department: 'TI', startDate: '2026-01-01', endDate: '2026-06-30', keyResults: [{ title: 'Integração de sistemas', progress: 40 }, { title: 'Workflows automatizados', progress: 15 }] },
];

// Mock Audit Events
export const mockAuditEvents: AuditEvent[] = [
  { id: '1', action: 'USER_LOGIN', entity: 'User', entityId: '1', user: 'Ana Carolina Silva', timestamp: '2026-01-27T10:30:00Z', details: 'Login successful from São Paulo, BR', ipAddress: '189.45.123.45', risk: 'low' },
  { id: '2', action: 'DECISION_APPROVED', entity: 'Decision', entityId: '1', user: 'Ricardo Oliveira', timestamp: '2026-01-27T09:45:00Z', details: 'Aprovação de decisão orçamentária Q1', ipAddress: '189.45.123.46', risk: 'low' },
  { id: '3', action: 'PERMISSION_CHANGED', entity: 'Role', entityId: '3', user: 'Ana Carolina Silva', timestamp: '2026-01-27T08:15:00Z', details: 'Permissão de admin adicionada ao usuário Carlos Pereira', ipAddress: '189.45.123.45', risk: 'high' },
  { id: '4', action: 'DATA_EXPORT', entity: 'Report', entityId: '15', user: 'Marina Costa', timestamp: '2026-01-26T16:00:00Z', details: 'Export de relatório financeiro completo', ipAddress: '189.45.123.50', risk: 'medium' },
  { id: '5', action: 'BULK_DELETE', entity: 'Employee', entityId: 'batch', user: 'Ricardo Oliveira', timestamp: '2026-01-26T14:30:00Z', details: 'Exclusão em lote de 12 registros de colaboradores desligados', ipAddress: '189.45.123.46', risk: 'high' },
];

// Mock Bridge Events
export const mockBridgeEvents: BridgeEvent[] = [
  { id: '1', type: 'sync', source: 'SAP HR', target: 'HUMANTRÍA Core', status: 'success', timestamp: '2026-01-27T10:00:00Z', duration: 1250 },
  { id: '2', type: 'webhook', source: 'Gupy ATS', target: 'HUMANTRÍA Talent', status: 'success', timestamp: '2026-01-27T09:55:00Z', duration: 85 },
  { id: '3', type: 'api', source: 'Workday', target: 'HUMANTRÍA Core', status: 'failed', timestamp: '2026-01-27T09:30:00Z', duration: 30000, errorMessage: 'Connection timeout - endpoint unreachable' },
  { id: '4', type: 'batch', source: 'HUMANTRÍA', target: 'PowerBI', status: 'processing', timestamp: '2026-01-27T09:00:00Z', duration: 0 },
  { id: '5', type: 'sync', source: 'TOTVS Protheus', target: 'HUMANTRÍA Core', status: 'success', timestamp: '2026-01-27T08:00:00Z', duration: 3400 },
  { id: '6', type: 'webhook', source: 'Slack', target: 'HUMANTRÍA Notifications', status: 'success', timestamp: '2026-01-27T07:45:00Z', duration: 120 },
];

// Dashboard KPI Data
export const mockKPIs = {
  totalEmployees: 2847,
  employeesChange: 3.2,
  activeDecisions: 142,
  decisionsChange: -5.1,
  budgetUtilization: 78.4,
  budgetChange: 2.8,
  objectivesOnTrack: 86,
  objectivesChange: 4.5,
  pendingApprovals: 28,
  risksIdentified: 47,
  aiInsights: 156,
  integrationHealth: 94.2,
};

// Chart Data
export const mockChartData = {
  budgetVsActual: [
    { month: 'Jan', budget: 4200, actual: 4000 },
    { month: 'Fev', budget: 3500, actual: 3000 },
    { month: 'Mar', budget: 4800, actual: 5000 },
    { month: 'Abr', budget: 4600, actual: 4500 },
    { month: 'Mai', budget: 5500, actual: 6000 },
    { month: 'Jun', budget: 5800, actual: 5500 },
  ],
  decisionsByStatus: [
    { name: 'Aprovadas', value: 65, color: 'hsl(var(--success))' },
    { name: 'Pendentes', value: 25, color: 'hsl(var(--warning))' },
    { name: 'Rejeitadas', value: 10, color: 'hsl(var(--destructive))' },
  ],
  departmentProgress: [
    { name: 'Comercial', completed: 85, target: 100 },
    { name: 'Engenharia', completed: 72, target: 100 },
    { name: 'Marketing', completed: 90, target: 100 },
    { name: 'RH', completed: 65, target: 100 },
    { name: 'Finanças', completed: 78, target: 100 },
  ],
  headcountTrend: [
    { month: 'Jul', count: 2650 },
    { month: 'Ago', count: 2700 },
    { month: 'Set', count: 2720 },
    { month: 'Out', count: 2780 },
    { month: 'Nov', count: 2810 },
    { month: 'Dez', count: 2847 },
  ],
};

// Generate random ID
export const generateId = (): string => {
  return Math.random().toString(36).substring(2, 15);
};

// Format date
export const formatDate = (dateString: string): string => {
  return new Date(dateString).toLocaleDateString('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  });
};

// Format datetime
export const formatDateTime = (dateString: string): string => {
  return new Date(dateString).toLocaleString('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
};

// Get status color
export const getStatusColor = (status: string): string => {
  const colors: Record<string, string> = {
    active: 'success',
    approved: 'success',
    completed: 'success',
    on_track: 'success',
    success: 'success',
    pending: 'warning',
    at_risk: 'warning',
    processing: 'warning',
    inactive: 'muted',
    draft: 'muted',
    rejected: 'destructive',
    failed: 'destructive',
    behind: 'destructive',
    critical: 'destructive',
    high: 'warning',
    medium: 'info',
    low: 'muted',
  };
  return colors[status] || 'muted';
};
