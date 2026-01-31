import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { StatusBadge } from '@/components/ui/status-badge';
import { Plus, Workflow } from 'lucide-react';

const workflows = [
  { id: '1', name: 'Budget Approval', status: 'active', steps: 5, executions: 234 },
  { id: '2', name: 'Headcount Request', status: 'active', steps: 4, executions: 89 },
  { id: '3', name: 'Initiative Review', status: 'draft', steps: 6, executions: 0 },
];

export default function WorkflowsPage() {
  return (
    <AppLayout>
      <PageHeader title="Workflows" description="Workflow designer and automation" breadcrumbs={[{ label: 'Strategy', href: '/strategy' }, { label: 'Workflows' }]} actions={<div className="flex items-center gap-2"><AIActions onSuggest={() => {}} /><Button className="gap-2"><Plus className="h-4 w-4" />Create Workflow</Button></div>} />
      <div className="p-6 grid grid-cols-1 md:grid-cols-3 gap-4">
        {workflows.map((w) => (
          <Card key={w.id}>
            <CardHeader className="flex flex-row items-center justify-between"><div className="flex items-center gap-2"><Workflow className="h-5 w-5 text-primary" /><CardTitle className="text-base">{w.name}</CardTitle></div><StatusBadge variant={w.status === 'active' ? 'success' : 'default'}>{w.status}</StatusBadge></CardHeader>
            <CardContent><p className="text-sm text-muted-foreground">{w.steps} steps • {w.executions} executions</p><Button variant="outline" size="sm" className="mt-4">Edit</Button></CardContent>
          </Card>
        ))}
      </div>
    </AppLayout>
  );
}
