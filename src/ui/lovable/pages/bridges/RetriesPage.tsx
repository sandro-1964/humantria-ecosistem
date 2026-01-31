import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { DataTable, Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { AIActions } from '@/components/ui/ai-actions';
import { RefreshCw } from 'lucide-react';

interface Retry {
  id: string;
  eventId: string;
  consumer: string;
  attempt: number;
  maxAttempts: number;
  nextRetry: string;
  status: 'scheduled' | 'in-progress';
}

const retries: Retry[] = [
  { id: '1', eventId: 'evt_abc123', consumer: 'sync-consumer', attempt: 3, maxAttempts: 5, nextRetry: '2024-01-15 09:35:00', status: 'scheduled' },
  { id: '2', eventId: 'evt_def456', consumer: 'reporting-consumer', attempt: 2, maxAttempts: 5, nextRetry: '2024-01-15 09:32:00', status: 'in-progress' },
];

const columns: Column<Retry>[] = [
  { key: 'eventId', header: 'Event ID', cell: (row) => <span className="font-mono text-sm">{row.eventId}</span> },
  { key: 'consumer', header: 'Consumer' },
  { key: 'attempt', header: 'Attempt', cell: (row) => `${row.attempt}/${row.maxAttempts}` },
  { key: 'nextRetry', header: 'Next Retry' },
  { key: 'status', header: 'Status', cell: (row) => <StatusBadge variant={row.status === 'in-progress' ? 'info' : 'default'}>{row.status}</StatusBadge> },
];

export default function RetriesPage() {
  return (
    <AppLayout>
      <PageHeader title="Retries" description="Scheduled retry queue" breadcrumbs={[{ label: 'Bridges', href: '/bridges' }, { label: 'Retries' }]} actions={<AIActions onExplain={() => {}} />} />
      <div className="p-6"><DataTable columns={columns} data={retries} /></div>
    </AppLayout>
  );
}
