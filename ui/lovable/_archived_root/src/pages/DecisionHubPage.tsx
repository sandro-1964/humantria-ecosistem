import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { 
  Target, 
  DollarSign, 
  Users, 
  AlertTriangle, 
  TrendingUp, 
  Clock,
  CheckCircle2,
  XCircle,
  ArrowRight,
  ChevronDown,
  ChevronUp,
  FileText,
  Calendar,
  User,
} from 'lucide-react';
import { StatusBadge } from '@/components/ui/status-badge';
import { useToast } from '@/hooks/use-toast';
import { Tooltip, TooltipContent, TooltipTrigger } from '@/components/ui/tooltip';
import { useComingSoon, ComingSoonModal } from '@/components/ui/coming-soon-modal';
import { cn } from '@/lib/utils';

const pendingDecisions = [
  { 
    id: '1', 
    title: 'Q2 Budget Allocation', 
    type: 'Budget', 
    priority: 'high', 
    dueDate: '2024-02-15', 
    owner: 'Sarah Chen',
    summary: 'Aprovação de R$ 2.5M para expansão de time de engenharia no Q2.',
    evidence: ['Forecast 2024.xlsx', 'Headcount Plan.pdf'],
    timeline: [
      { date: '2024-01-28', action: 'Criada por CFO' },
      { date: '2024-02-01', action: 'Análise financeira concluída' },
      { date: '2024-02-05', action: 'Aguardando aprovação CEO' },
    ],
  },
  { 
    id: '2', 
    title: 'New Hire Approval - Engineering', 
    type: 'Staffing', 
    priority: 'medium', 
    dueDate: '2024-02-10', 
    owner: 'Michael Torres',
    summary: 'Contratação de 3 Senior Engineers para projeto Alpha.',
    evidence: ['Job Descriptions.pdf', 'Budget Impact.xlsx'],
    timeline: [
      { date: '2024-02-01', action: 'Requisição aberta' },
      { date: '2024-02-03', action: 'Aprovação do gestor direto' },
    ],
  },
  { 
    id: '3', 
    title: 'Risk Mitigation Plan - Project Alpha', 
    type: 'Risk', 
    priority: 'high', 
    dueDate: '2024-02-08', 
    owner: 'Ana Silva',
    summary: 'Plano de contingência para riscos identificados no projeto Alpha.',
    evidence: ['Risk Assessment.pdf', 'Mitigation Matrix.xlsx'],
    timeline: [
      { date: '2024-01-25', action: 'Riscos identificados' },
      { date: '2024-02-02', action: 'Plano elaborado' },
    ],
  },
  { 
    id: '4', 
    title: 'OKR Adjustments - Sales Team', 
    type: 'Objectives', 
    priority: 'low', 
    dueDate: '2024-02-20', 
    owner: 'James Wilson',
    summary: 'Revisão de metas do time comercial após Q1.',
    evidence: ['Q1 Results.pdf'],
    timeline: [
      { date: '2024-02-10', action: 'Proposta criada' },
    ],
  },
];

const recentDecisions = [
  { id: '1', title: 'Marketing Campaign Budget', status: 'approved', date: '2024-02-01', approver: 'CEO' },
  { id: '2', title: 'Remote Work Policy Update', status: 'rejected', date: '2024-01-28', approver: 'HR Director' },
  { id: '3', title: 'Vendor Contract Renewal', status: 'approved', date: '2024-01-25', approver: 'CFO' },
];

export default function DecisionHubPage() {
  const { toast } = useToast();
  const { modalState, showComingSoon, hideComingSoon } = useComingSoon();
  const [expandedDecision, setExpandedDecision] = React.useState<string | null>(null);

  const handleAISuggest = () => {
    showComingSoon({
      title: 'Sugestão com IA',
      description: 'Analisa as decisões pendentes e sugere priorização baseada em impacto, urgência e dependências.',
      dataSource: 'pending_decisions, risk_matrix, org_hierarchy',
      states: ['loading', 'success'],
    });
  };

  const handleAIExplain = () => {
    showComingSoon({
      title: 'Explicar com IA',
      description: 'Gera uma narrativa explicativa sobre o fluxo de decisão e critérios de aprovação.',
      dataSource: 'workflow_rules, approval_history',
      states: ['loading', 'success'],
    });
  };

  const handleAISimulate = () => {
    showComingSoon({
      title: 'Simular Cenário',
      description: 'Simula o impacto das decisões pendentes em orçamento, headcount e timeline.',
      dataSource: 'budget_forecast, staffing_plan, project_timeline',
      states: ['loading', 'empty', 'success'],
    });
  };

  const handleApprove = () => {
    showComingSoon({
      title: 'Aprovar Decisão',
      description: 'Registra a aprovação com assinatura digital, timestamp e evidências anexadas.',
      dataSource: 'user_session, decision_record, audit_log',
      states: ['loading', 'success', 'error'],
    });
  };

  const handleReject = () => {
    showComingSoon({
      title: 'Rejeitar Decisão',
      description: 'Registra a rejeição com justificativa obrigatória e notifica stakeholders.',
      dataSource: 'user_session, decision_record, notification_queue',
      states: ['loading', 'success'],
    });
  };

  const toggleExpand = (id: string) => {
    setExpandedDecision(prev => prev === id ? null : id);
  };

  return (
    <AppLayout>
      <PageHeader 
        title="Decision Hub" 
        description="Central de comando para governança estratégica de decisões"
        breadcrumbs={[{ label: 'Decision Hub' }]}
        actions={
          <AIActions 
            onSuggest={handleAISuggest} 
            onExplain={handleAIExplain}
            onSimulate={handleAISimulate}
          />
        }
      />
      
      <div className="p-6 space-y-6">
        {/* Quick Stats */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <Tooltip>
            <TooltipTrigger asChild>
              <Card className="card-interactive hover-lift cursor-pointer">
                <CardContent className="pt-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">Pendentes</p>
                      <p className="text-3xl font-bold text-warning">12</p>
                    </div>
                    <div className="p-3 rounded-xl bg-warning/10">
                      <Clock className="h-6 w-6 text-warning" />
                    </div>
                  </div>
                </CardContent>
              </Card>
            </TooltipTrigger>
            <TooltipContent>Decisões aguardando aprovação</TooltipContent>
          </Tooltip>
          
          <Tooltip>
            <TooltipTrigger asChild>
              <Card className="card-interactive hover-lift cursor-pointer">
                <CardContent className="pt-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">Aprovadas (Mês)</p>
                      <p className="text-3xl font-bold text-success">28</p>
                    </div>
                    <div className="p-3 rounded-xl bg-success/10">
                      <CheckCircle2 className="h-6 w-6 text-success" />
                    </div>
                  </div>
                </CardContent>
              </Card>
            </TooltipTrigger>
            <TooltipContent>Decisões aprovadas neste mês</TooltipContent>
          </Tooltip>
          
          <Tooltip>
            <TooltipTrigger asChild>
              <Card className="card-interactive hover-lift cursor-pointer">
                <CardContent className="pt-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">Alta Prioridade</p>
                      <p className="text-3xl font-bold text-destructive">5</p>
                    </div>
                    <div className="p-3 rounded-xl bg-destructive/10">
                      <AlertTriangle className="h-6 w-6 text-destructive" />
                    </div>
                  </div>
                </CardContent>
              </Card>
            </TooltipTrigger>
            <TooltipContent>Decisões de alta prioridade</TooltipContent>
          </Tooltip>
          
          <Tooltip>
            <TooltipTrigger asChild>
              <Card className="card-interactive hover-lift cursor-pointer">
                <CardContent className="pt-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">Tempo Médio</p>
                      <p className="text-3xl font-bold text-info">3.2d</p>
                    </div>
                    <div className="p-3 rounded-xl bg-info/10">
                      <TrendingUp className="h-6 w-6 text-info" />
                    </div>
                  </div>
                </CardContent>
              </Card>
            </TooltipTrigger>
            <TooltipContent>Tempo médio de resolução</TooltipContent>
          </Tooltip>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Pending Decisions - Expandable */}
          <div className="lg:col-span-2">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between">
                <CardTitle>Decisões Pendentes</CardTitle>
                <Button variant="outline" size="sm">Ver Todas</Button>
              </CardHeader>
              <CardContent className="space-y-3">
                {pendingDecisions.map((decision) => {
                  const isExpanded = expandedDecision === decision.id;
                  
                  return (
                    <div 
                      key={decision.id}
                      className="rounded-lg border border-border/50 overflow-hidden transition-all duration-200"
                    >
                      {/* Header Row - Always visible */}
                      <div 
                        onClick={() => toggleExpand(decision.id)}
                        className="flex items-center justify-between p-3 hover:bg-muted/50 cursor-pointer transition-colors"
                      >
                        <div className="flex items-center gap-3">
                          <div className={`p-2 rounded-md ${
                            decision.type === 'Budget' ? 'bg-success/10' :
                            decision.type === 'Staffing' ? 'bg-info/10' :
                            decision.type === 'Risk' ? 'bg-destructive/10' :
                            'bg-primary/10'
                          }`}>
                            {decision.type === 'Budget' && <DollarSign className="h-4 w-4 text-success" />}
                            {decision.type === 'Staffing' && <Users className="h-4 w-4 text-info" />}
                            {decision.type === 'Risk' && <AlertTriangle className="h-4 w-4 text-destructive" />}
                            {decision.type === 'Objectives' && <Target className="h-4 w-4 text-primary" />}
                          </div>
                          <div>
                            <p className="font-medium text-sm">{decision.title}</p>
                            <p className="text-xs text-muted-foreground">Vence: {decision.dueDate} • {decision.owner}</p>
                          </div>
                        </div>
                        <div className="flex items-center gap-2">
                          <StatusBadge 
                            variant={
                              decision.priority === 'high' ? 'destructive' :
                              decision.priority === 'medium' ? 'warning' : 'default'
                            }
                          >
                            {decision.priority === 'high' ? 'Alta' : decision.priority === 'medium' ? 'Média' : 'Baixa'}
                          </StatusBadge>
                          {isExpanded ? (
                            <ChevronUp className="h-4 w-4 text-muted-foreground" />
                          ) : (
                            <ChevronDown className="h-4 w-4 text-muted-foreground" />
                          )}
                        </div>
                      </div>

                      {/* Expanded Content */}
                      <div className={cn(
                        'overflow-hidden transition-all duration-200',
                        isExpanded ? 'max-h-[400px] opacity-100' : 'max-h-0 opacity-0'
                      )}>
                        <div className="px-4 pb-4 space-y-4 border-t border-border/30 pt-4">
                          {/* Summary */}
                          <div>
                            <p className="text-xs text-muted-foreground mb-1">Resumo</p>
                            <p className="text-sm">{decision.summary}</p>
                          </div>

                          {/* Evidence */}
                          <div>
                            <p className="text-xs text-muted-foreground mb-2">Evidências</p>
                            <div className="flex flex-wrap gap-2">
                              {decision.evidence.map((file, idx) => (
                                <div 
                                  key={idx}
                                  className="flex items-center gap-1.5 px-2 py-1 rounded-md bg-muted/50 text-xs"
                                >
                                  <FileText className="h-3 w-3 text-muted-foreground" />
                                  <span>{file}</span>
                                </div>
                              ))}
                            </div>
                          </div>

                          {/* Timeline */}
                          <div>
                            <p className="text-xs text-muted-foreground mb-2">Histórico</p>
                            <div className="space-y-2">
                              {decision.timeline.map((item, idx) => (
                                <div key={idx} className="flex items-center gap-2 text-xs">
                                  <Calendar className="h-3 w-3 text-muted-foreground" />
                                  <span className="text-muted-foreground">{item.date}</span>
                                  <span>•</span>
                                  <span>{item.action}</span>
                                </div>
                              ))}
                            </div>
                          </div>

                          {/* Actions */}
                          <div className="flex gap-2 pt-2">
                            <Tooltip>
                              <TooltipTrigger asChild>
                                <Button size="sm" className="flex-1" onClick={handleApprove}>
                                  <CheckCircle2 className="h-4 w-4 mr-1" />
                                  Aprovar
                                </Button>
                              </TooltipTrigger>
                              <TooltipContent>Em preparação (UI). Backend será integrado no Cursor.</TooltipContent>
                            </Tooltip>
                            <Tooltip>
                              <TooltipTrigger asChild>
                                <Button size="sm" variant="outline" className="flex-1" onClick={handleReject}>
                                  <XCircle className="h-4 w-4 mr-1" />
                                  Rejeitar
                                </Button>
                              </TooltipTrigger>
                              <TooltipContent>Em preparação (UI). Backend será integrado no Cursor.</TooltipContent>
                            </Tooltip>
                          </div>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </CardContent>
            </Card>
          </div>

          {/* Recent Decisions */}
          <Card>
            <CardHeader>
              <CardTitle>Decisões Recentes</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              {recentDecisions.map((decision) => (
                <div 
                  key={decision.id}
                  className="flex items-start gap-3 p-2 hover:bg-muted/30 rounded-md cursor-pointer transition-colors"
                >
                  {decision.status === 'approved' ? (
                    <CheckCircle2 className="h-5 w-5 text-success mt-0.5" />
                  ) : (
                    <XCircle className="h-5 w-5 text-destructive mt-0.5" />
                  )}
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium truncate">{decision.title}</p>
                    <p className="text-xs text-muted-foreground">
                      {decision.date} • {decision.approver}
                    </p>
                  </div>
                </div>
              ))}
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Coming Soon Modal */}
      <ComingSoonModal
        open={modalState.open}
        onOpenChange={hideComingSoon}
        feature={modalState.feature}
      />
    </AppLayout>
  );
}
