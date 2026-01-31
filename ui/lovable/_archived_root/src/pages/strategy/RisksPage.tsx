import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { DataTable, Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { AIActions } from '@/components/ui/ai-actions';
import { AlertTriangle } from 'lucide-react';

interface Risk { id: string; title: string; category: string; level: 'critical' | 'high' | 'medium' | 'low'; owner: string; status: 'open' | 'mitigated'; }
const risks: Risk[] = [
  { id: '1', title: 'Budget overrun Q2', category: 'Financial', level: 'high', owner: 'Sarah Chen', status: 'open' },
  { id: '2', title: 'Key talent attrition', category: 'HR', level: 'critical', owner: 'Mike Johnson', status: 'open' },
  { id: '3', title: 'Delayed product launch', category: 'Operations', level: 'medium', owner: 'Emily Davis', status: 'mitigated' },
];

const columns: Column<Risk>[] = [
  { key: 'title', header: 'Risk', cell: (row) => <div className="flex items-center gap-2"><AlertTriangle className="h-4 w-4 text-warning" /><span>{row.title}</span></div> },
  { key: 'category', header: 'Category' },
  { key: 'level', header: 'Level', cell: (row) => <StatusBadge variant={row.level === 'critical' ? 'destructive' : row.level === 'high' ? 'warning' : row.level === 'medium' ? 'info' : 'default'}>{row.level}</StatusBadge> },
  { key: 'owner', header: 'Owner' },
  { key: 'status', header: 'Status', cell: (row) => <StatusBadge variant={row.status === 'mitigated' ? 'success' : 'default'}>{row.status}</StatusBadge> },
];

export default function RisksPage() {
  return (
    <AppLayout>
      <PageHeader title="Risk Alerts" description="Risk monitoring and mitigation" breadcrumbs={[{ label: 'Strategy', href: '/strategy' }, { label: 'Risks' }]} actions={<AIActions onSuggest={() => {}} onExplain={() => {}} />} />
      <div className="p-6"><DataTable columns={columns} data={risks} /></div>
    </AppLayout>
  );
}
