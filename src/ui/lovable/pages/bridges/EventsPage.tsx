import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { DataTable, Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { RefreshCw, Zap, Pause, Play } from 'lucide-react';

interface BridgeEvent {
  id: string;
  type: string;
  source: string;
  destination: string;
  status: 'delivered' | 'pending' | 'failed';
  latency: string;
  timestamp: string;
}

const events: BridgeEvent[] = [
  { id: '1', type: 'user.created', source: 'core-service', destination: 'analytics', status: 'delivered', latency: '45ms', timestamp: '2024-01-15 09:30:45' },
  { id: '2', type: 'decision.approved', source: 'workflow-engine', destination: 'notification-service', status: 'delivered', latency: '23ms', timestamp: '2024-01-15 09:28:12' },
  { id: '3', type: 'budget.updated', source: 'finance-module', destination: 'reporting', status: 'pending', latency: '-', timestamp: '2024-01-15 09:15:33' },
  { id: '4', type: 'sync.request', source: 'integration-hub', destination: 'external-api', status: 'failed', latency: '5000ms', timestamp: '2024-01-15 09:10:01' },
];

const columns: Column<BridgeEvent>[] = [
  { key: 'timestamp', header: 'Time' },
  { key: 'type', header: 'Event Type', cell: (row) => <span className="font-mono text-sm">{row.type}</span> },
  { key: 'source', header: 'Source' },
  { key: 'destination', header: 'Destination' },
  { key: 'latency', header: 'Latency' },
  { key: 'status', header: 'Status', cell: (row) => <StatusBadge variant={row.status === 'delivered' ? 'success' : row.status === 'pending' ? 'warning' : 'destructive'}>{row.status}</StatusBadge> },
];

export default function BridgesEventsPage() {
  return (
    <AppLayout>
      <PageHeader
        title="Event Monitor"
        description="Real-time event streaming and monitoring"
        breadcrumbs={[{ label: 'Bridges', href: '/bridges' }, { label: 'Events' }]}
        actions={
          <div className="flex items-center gap-2">
            <AIActions onExplain={() => {}} />
            <Button variant="outline" className="gap-2"><Pause className="h-4 w-4" />Pause</Button>
            <Button variant="outline" className="gap-2"><RefreshCw className="h-4 w-4" />Refresh</Button>
          </div>
        }
      />
      <div className="p-6">
        <DataTable columns={columns} data={events} />
      </div>
    </AppLayout>
  );
}
