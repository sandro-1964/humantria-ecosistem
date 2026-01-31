import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { DataTable, Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { Plus, Server } from 'lucide-react';

interface Consumer {
  id: string;
  name: string;
  topic: string;
  status: 'running' | 'stopped' | 'error';
  processed: number;
  lag: number;
}

const consumers: Consumer[] = [
  { id: '1', name: 'analytics-consumer', topic: 'user-events', status: 'running', processed: 125840, lag: 12 },
  { id: '2', name: 'notification-consumer', topic: 'workflow-events', status: 'running', processed: 45230, lag: 3 },
  { id: '3', name: 'reporting-consumer', topic: 'finance-events', status: 'stopped', processed: 8900, lag: 450 },
  { id: '4', name: 'sync-consumer', topic: 'integration-events', status: 'error', processed: 2340, lag: 1200 },
];

const columns: Column<Consumer>[] = [
  { key: 'name', header: 'Consumer', cell: (row) => <div className="flex items-center gap-2"><Server className="h-4 w-4 text-muted-foreground" /><span className="font-mono">{row.name}</span></div> },
  { key: 'topic', header: 'Topic' },
  { key: 'status', header: 'Status', cell: (row) => <StatusBadge variant={row.status === 'running' ? 'success' : row.status === 'stopped' ? 'default' : 'destructive'}>{row.status}</StatusBadge> },
  { key: 'processed', header: 'Processed', cell: (row) => row.processed.toLocaleString() },
  { key: 'lag', header: 'Lag', cell: (row) => <span className={row.lag > 100 ? 'text-destructive' : ''}>{row.lag}</span> },
];

export default function ConsumersPage() {
  return (
    <AppLayout>
      <PageHeader
        title="Consumers"
        description="Manage event consumers and subscriptions"
        breadcrumbs={[{ label: 'Bridges', href: '/bridges' }, { label: 'Consumers' }]}
        actions={<div className="flex items-center gap-2"><AIActions onExplain={() => {}} /><Button className="gap-2"><Plus className="h-4 w-4" />Add Consumer</Button></div>}
      />
      <div className="p-6"><DataTable columns={columns} data={consumers} /></div>
    </AppLayout>
  );
}
