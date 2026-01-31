import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { DataTable, Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { Zap, RefreshCw } from 'lucide-react';

interface Event {
  id: string;
  type: string;
  source: string;
  payload: string;
  timestamp: string;
  status: 'processed' | 'pending' | 'failed';
}

const events: Event[] = [
  { id: '1', type: 'user.created', source: 'iam-service', payload: '{"userId": "123"}', timestamp: '2024-01-15 09:30:45', status: 'processed' },
  { id: '2', type: 'decision.approved', source: 'workflow-engine', payload: '{"decisionId": "456"}', timestamp: '2024-01-15 09:28:12', status: 'processed' },
  { id: '3', type: 'budget.updated', source: 'finance-module', payload: '{"amount": 50000}', timestamp: '2024-01-15 09:15:33', status: 'pending' },
  { id: '4', type: 'sync.failed', source: 'integration-hub', payload: '{"error": "timeout"}', timestamp: '2024-01-15 09:10:01', status: 'failed' },
];

const columns: Column<Event>[] = [
  { key: 'timestamp', header: 'Time' },
  {
    key: 'type',
    header: 'Event Type',
    cell: (row) => (
      <div className="flex items-center gap-2">
        <Zap className="h-4 w-4 text-primary" />
        <span className="font-mono text-sm">{row.type}</span>
      </div>
    ),
  },
  { key: 'source', header: 'Source' },
  {
    key: 'payload',
    header: 'Payload',
    cell: (row) => <span className="font-mono text-xs truncate max-w-[200px] block">{row.payload}</span>,
  },
  {
    key: 'status',
    header: 'Status',
    cell: (row) => (
      <StatusBadge variant={row.status === 'processed' ? 'success' : row.status === 'pending' ? 'warning' : 'destructive'}>
        {row.status}
      </StatusBadge>
    ),
  },
];

export default function EventsPage() {
  return (
    <AppLayout>
      <PageHeader
        title="System Events"
        description="Monitor and manage system-wide events"
        breadcrumbs={[
          { label: 'Foundation', href: '/foundation' },
          { label: 'Events' },
        ]}
        actions={
          <div className="flex items-center gap-2">
            <AIActions onExplain={() => {}} />
            <Button variant="outline" className="gap-2">
              <RefreshCw className="h-4 w-4" />
              Refresh
            </Button>
          </div>
        }
      />
      <div className="p-6">
        <DataTable columns={columns} data={events} />
      </div>
    </AppLayout>
  );
}
