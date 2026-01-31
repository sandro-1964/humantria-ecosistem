import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { DataTable, Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { Plus, Plug, Settings } from 'lucide-react';

interface Connector {
  id: string;
  name: string;
  type: string;
  status: 'connected' | 'disconnected' | 'error';
  lastSync: string;
  records: number;
}

const connectors: Connector[] = [
  { id: '1', name: 'Salesforce CRM', type: 'CRM', status: 'connected', lastSync: '2024-01-15 09:00', records: 45230 },
  { id: '2', name: 'SAP HR', type: 'HRIS', status: 'connected', lastSync: '2024-01-15 08:30', records: 2847 },
  { id: '3', name: 'Workday', type: 'HRIS', status: 'disconnected', lastSync: '2024-01-14 18:00', records: 0 },
  { id: '4', name: 'QuickBooks', type: 'Finance', status: 'error', lastSync: '2024-01-15 07:00', records: 12500 },
];

const columns: Column<Connector>[] = [
  { key: 'name', header: 'Connector', cell: (row) => <div className="flex items-center gap-2"><Plug className="h-4 w-4 text-muted-foreground" /><span className="font-medium">{row.name}</span></div> },
  { key: 'type', header: 'Type' },
  { key: 'status', header: 'Status', cell: (row) => <StatusBadge variant={row.status === 'connected' ? 'success' : row.status === 'disconnected' ? 'default' : 'destructive'}>{row.status}</StatusBadge> },
  { key: 'lastSync', header: 'Last Sync' },
  { key: 'records', header: 'Records', cell: (row) => row.records.toLocaleString() },
  { key: 'actions', header: '', cell: () => <Button variant="ghost" size="sm"><Settings className="h-4 w-4" /></Button> },
];

export default function ConnectorsPage() {
  return (
    <AppLayout>
      <PageHeader title="Connectors" description="External system integrations" breadcrumbs={[{ label: 'Bridges', href: '/bridges' }, { label: 'Connectors' }]} actions={<div className="flex items-center gap-2"><AIActions onSuggest={() => {}} /><Button className="gap-2"><Plus className="h-4 w-4" />Add Connector</Button></div>} />
      <div className="p-6"><DataTable columns={columns} data={connectors} /></div>
    </AppLayout>
  );
}
