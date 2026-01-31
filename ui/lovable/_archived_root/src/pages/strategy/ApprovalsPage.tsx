import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { DataTable, Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { Check, X } from 'lucide-react';

interface Approval { id: string; title: string; type: string; requestor: string; status: 'pending' | 'approved' | 'rejected'; submitted: string; }
const approvals: Approval[] = [
  { id: '1', title: 'Q2 Budget Increase', type: 'Budget', requestor: 'Sarah Chen', status: 'pending', submitted: '2024-01-14' },
  { id: '2', title: 'New Hire - Engineering', type: 'Headcount', requestor: 'Mike Johnson', status: 'pending', submitted: '2024-01-13' },
  { id: '3', title: 'Marketing Campaign', type: 'Initiative', requestor: 'Emily Davis', status: 'approved', submitted: '2024-01-10' },
];

const columns: Column<Approval>[] = [
  { key: 'title', header: 'Request' },
  { key: 'type', header: 'Type' },
  { key: 'requestor', header: 'Requestor' },
  { key: 'submitted', header: 'Submitted' },
  { key: 'status', header: 'Status', cell: (row) => <StatusBadge variant={row.status === 'approved' ? 'success' : row.status === 'rejected' ? 'destructive' : 'warning'}>{row.status}</StatusBadge> },
  { key: 'actions', header: '', cell: (row) => row.status === 'pending' ? <div className="flex gap-1"><Button variant="ghost" size="sm"><Check className="h-4 w-4 text-success" /></Button><Button variant="ghost" size="sm"><X className="h-4 w-4 text-destructive" /></Button></div> : null },
];

export default function ApprovalsPage() {
  return (
    <AppLayout>
      <PageHeader title="Approvals" description="Pending approval requests" breadcrumbs={[{ label: 'Strategy', href: '/strategy' }, { label: 'Approvals' }]} actions={<AIActions onSuggest={() => {}} />} />
      <div className="p-6"><DataTable columns={columns} data={approvals} /></div>
    </AppLayout>
  );
}
