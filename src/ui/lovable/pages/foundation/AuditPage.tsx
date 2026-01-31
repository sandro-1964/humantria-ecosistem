import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { DataTable, Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { Input } from '@/components/ui/input';
import { Search, Download, Filter } from 'lucide-react';

interface AuditLog {
  id: string;
  action: string;
  resource: string;
  user: string;
  ip: string;
  timestamp: string;
  status: 'success' | 'failure';
}

const logs: AuditLog[] = [
  { id: '1', action: 'user.login', resource: 'auth', user: 'john@acme.com', ip: '192.168.1.1', timestamp: '2024-01-15 09:30:45', status: 'success' },
  { id: '2', action: 'decision.create', resource: 'decisions', user: 'sarah@acme.com', ip: '192.168.1.2', timestamp: '2024-01-15 09:28:12', status: 'success' },
  { id: '3', action: 'user.update', resource: 'users', user: 'admin@acme.com', ip: '192.168.1.3', timestamp: '2024-01-15 09:15:33', status: 'success' },
  { id: '4', action: 'export.attempt', resource: 'reports', user: 'mike@acme.com', ip: '192.168.1.4', timestamp: '2024-01-15 09:10:01', status: 'failure' },
];

const columns: Column<AuditLog>[] = [
  { key: 'timestamp', header: 'Timestamp' },
  {
    key: 'action',
    header: 'Action',
    cell: (row) => <span className="font-mono text-sm">{row.action}</span>,
  },
  { key: 'resource', header: 'Resource' },
  { key: 'user', header: 'User' },
  { key: 'ip', header: 'IP Address' },
  {
    key: 'status',
    header: 'Status',
    cell: (row) => (
      <StatusBadge variant={row.status === 'success' ? 'success' : 'destructive'}>
        {row.status}
      </StatusBadge>
    ),
  },
];

export default function AuditPage() {
  return (
    <AppLayout>
      <PageHeader
        title="Audit Log"
        description="System-wide activity and security audit trail"
        breadcrumbs={[
          { label: 'Foundation', href: '/foundation' },
          { label: 'Audit' },
        ]}
        actions={
          <div className="flex items-center gap-2">
            <AIActions onExplain={() => {}} />
            <Button variant="outline" className="gap-2">
              <Download className="h-4 w-4" />
              Export
            </Button>
          </div>
        }
      />
      <div className="p-6 space-y-4">
        <div className="flex gap-2">
          <div className="relative flex-1 max-w-sm">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input placeholder="Search logs..." className="pl-9" />
          </div>
          <Button variant="outline" className="gap-2">
            <Filter className="h-4 w-4" />
            Filters
          </Button>
        </div>
        <DataTable columns={columns} data={logs} />
      </div>
    </AppLayout>
  );
}
