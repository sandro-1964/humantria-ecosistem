import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { DataTable, Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { RefreshCw, AlertTriangle } from 'lucide-react';

interface Failure {
  id: string;
  eventType: string;
  consumer: string;
  error: string;
  attempts: number;
  lastAttempt: string;
  status: 'pending' | 'retrying' | 'dead';
}

const failures: Failure[] = [
  { id: '1', eventType: 'sync.request', consumer: 'sync-consumer', error: 'Connection timeout', attempts: 3, lastAttempt: '2024-01-15 09:10:01', status: 'retrying' },
  { id: '2', eventType: 'notification.send', consumer: 'notification-consumer', error: 'Invalid payload', attempts: 5, lastAttempt: '2024-01-15 08:45:33', status: 'dead' },
  { id: '3', eventType: 'report.generate', consumer: 'reporting-consumer', error: 'Service unavailable', attempts: 2, lastAttempt: '2024-01-15 08:30:12', status: 'pending' },
];

const columns: Column<Failure>[] = [
  { key: 'lastAttempt', header: 'Last Attempt' },
  { key: 'eventType', header: 'Event Type', cell: (row) => <span className="font-mono text-sm">{row.eventType}</span> },
  { key: 'consumer', header: 'Consumer' },
  { key: 'error', header: 'Error' },
  { key: 'attempts', header: 'Attempts' },
  { key: 'status', header: 'Status', cell: (row) => <StatusBadge variant={row.status === 'dead' ? 'destructive' : row.status === 'retrying' ? 'warning' : 'default'}>{row.status}</StatusBadge> },
  { key: 'actions', header: '', cell: () => <Button variant="ghost" size="sm"><RefreshCw className="h-4 w-4" /></Button> },
];

export default function FailuresPage() {
  return (
    <AppLayout>
      <PageHeader
        title="Failures"
        description="Failed events and dead letter queue"
        breadcrumbs={[{ label: 'Bridges', href: '/bridges' }, { label: 'Failures' }]}
        actions={<div className="flex items-center gap-2"><AIActions onExplain={() => {}} /><Button variant="outline" className="gap-2"><RefreshCw className="h-4 w-4" />Retry All</Button></div>}
      />
      <div className="p-6"><DataTable columns={columns} data={failures} /></div>
    </AppLayout>
  );
}
