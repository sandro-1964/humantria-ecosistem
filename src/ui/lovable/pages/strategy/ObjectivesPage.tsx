import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { DataTable, Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { Plus, Target } from 'lucide-react';
import { Progress } from '@/components/ui/progress';

interface Objective {
  id: string;
  title: string;
  type: 'OKR' | 'BSC';
  owner: string;
  progress: number;
  status: 'on-track' | 'at-risk' | 'behind';
  dueDate: string;
}

const objectives: Objective[] = [
  { id: '1', title: 'Increase revenue by 25%', type: 'OKR', owner: 'Sarah Chen', progress: 78, status: 'on-track', dueDate: '2024-12-31' },
  { id: '2', title: 'Improve customer satisfaction', type: 'BSC', owner: 'Mike Johnson', progress: 65, status: 'at-risk', dueDate: '2024-06-30' },
  { id: '3', title: 'Launch new product line', type: 'OKR', owner: 'Emily Davis', progress: 42, status: 'behind', dueDate: '2024-09-30' },
];

const columns: Column<Objective>[] = [
  { key: 'title', header: 'Objective', cell: (row) => <div className="flex items-center gap-2"><Target className="h-4 w-4 text-primary" /><span className="font-medium">{row.title}</span></div> },
  { key: 'type', header: 'Type' },
  { key: 'owner', header: 'Owner' },
  { key: 'progress', header: 'Progress', cell: (row) => <div className="flex items-center gap-2 w-32"><Progress value={row.progress} className="h-2" /><span className="text-sm">{row.progress}%</span></div> },
  { key: 'status', header: 'Status', cell: (row) => <StatusBadge variant={row.status === 'on-track' ? 'success' : row.status === 'at-risk' ? 'warning' : 'destructive'}>{row.status}</StatusBadge> },
  { key: 'dueDate', header: 'Due Date' },
];

export default function ObjectivesPage() {
  return (
    <AppLayout>
      <PageHeader title="Objectives" description="OKR and BSC objectives management" breadcrumbs={[{ label: 'Strategy', href: '/strategy' }, { label: 'Objectives' }]} actions={<div className="flex items-center gap-2"><AIActions onSuggest={() => {}} onSimulate={() => {}} /><Button className="gap-2"><Plus className="h-4 w-4" />New Objective</Button></div>} />
      <div className="p-6"><DataTable columns={columns} data={objectives} /></div>
    </AppLayout>
  );
}
