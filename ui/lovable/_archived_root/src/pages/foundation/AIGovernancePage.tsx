import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { StatusBadge } from '@/components/ui/status-badge';
import { DataTable, Column } from '@/components/ui/data-table';
import { Brain, Shield, AlertTriangle, CheckCircle, Activity } from 'lucide-react';

interface AIModel {
  id: string;
  name: string;
  type: string;
  status: 'approved' | 'pending' | 'restricted';
  lastAudit: string;
  riskLevel: 'low' | 'medium' | 'high';
}

const models: AIModel[] = [
  { id: '1', name: 'Decision Predictor', type: 'Classification', status: 'approved', lastAudit: '2024-01-10', riskLevel: 'low' },
  { id: '2', name: 'Budget Optimizer', type: 'Optimization', status: 'approved', lastAudit: '2024-01-08', riskLevel: 'medium' },
  { id: '3', name: 'Sentiment Analyzer', type: 'NLP', status: 'pending', lastAudit: '2024-01-05', riskLevel: 'low' },
  { id: '4', name: 'Staffing Predictor', type: 'Regression', status: 'restricted', lastAudit: '2024-01-02', riskLevel: 'high' },
];

const columns: Column<AIModel>[] = [
  {
    key: 'name',
    header: 'Model',
    cell: (row) => (
      <div className="flex items-center gap-2">
        <Brain className="h-4 w-4 text-primary" />
        <span className="font-medium">{row.name}</span>
      </div>
    ),
  },
  { key: 'type', header: 'Type' },
  {
    key: 'status',
    header: 'Status',
    cell: (row) => (
      <StatusBadge variant={row.status === 'approved' ? 'success' : row.status === 'pending' ? 'warning' : 'destructive'}>
        {row.status}
      </StatusBadge>
    ),
  },
  {
    key: 'riskLevel',
    header: 'Risk Level',
    cell: (row) => (
      <StatusBadge variant={row.riskLevel === 'low' ? 'success' : row.riskLevel === 'medium' ? 'warning' : 'destructive'}>
        {row.riskLevel}
      </StatusBadge>
    ),
  },
  { key: 'lastAudit', header: 'Last Audit' },
];

export default function AIGovernancePage() {
  return (
    <AppLayout>
      <PageHeader
        title="AI Governance"
        description="Monitor and control AI model usage and compliance"
        breadcrumbs={[
          { label: 'Foundation', href: '/foundation' },
          { label: 'AI Governance' },
        ]}
        actions={<AIActions onSuggest={() => {}} onExplain={() => {}} onSimulate={() => {}} />}
      />
      <div className="p-6 space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Active Models</CardTitle>
              <Brain className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">12</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Compliant</CardTitle>
              <CheckCircle className="h-4 w-4 text-success" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">9</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Pending Review</CardTitle>
              <Shield className="h-4 w-4 text-warning" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">2</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">High Risk</CardTitle>
              <AlertTriangle className="h-4 w-4 text-destructive" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">1</div>
            </CardContent>
          </Card>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>AI Models Registry</CardTitle>
          </CardHeader>
          <CardContent>
            <DataTable columns={columns} data={models} />
          </CardContent>
        </Card>
      </div>
    </AppLayout>
  );
}
