import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { DataTable, Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { Plus, Users } from 'lucide-react';

interface StaffingPlan { id: string; department: string; current: number; planned: number; variance: number; status: 'on-track' | 'over' | 'under'; }
const plans: StaffingPlan[] = [
  { id: '1', department: 'Engineering', current: 145, planned: 160, variance: -15, status: 'under' },
  { id: '2', department: 'Sales', current: 89, planned: 85, variance: 4, status: 'over' },
  { id: '3', department: 'Marketing', current: 52, planned: 55, variance: -3, status: 'on-track' },
];

const columns: Column<StaffingPlan>[] = [
  { key: 'department', header: 'Department' },
  { key: 'current', header: 'Current' },
  { key: 'planned', header: 'Planned' },
  { key: 'variance', header: 'Variance', cell: (row) => <span className={row.variance < 0 ? 'text-destructive' : row.variance > 0 ? 'text-success' : ''}>{row.variance > 0 ? '+' : ''}{row.variance}</span> },
  { key: 'status', header: 'Status', cell: (row) => <StatusBadge variant={row.status === 'on-track' ? 'success' : row.status === 'over' ? 'warning' : 'destructive'}>{row.status}</StatusBadge> },
];

export default function StaffingPage() {
  return (
    <AppLayout>
      <PageHeader title="Staffing Plans" description="Workforce planning and headcount" breadcrumbs={[{ label: 'Strategy', href: '/strategy' }, { label: 'Staffing' }]} actions={<div className="flex items-center gap-2"><AIActions onSuggest={() => {}} onSimulate={() => {}} /><Button className="gap-2"><Plus className="h-4 w-4" />New Plan</Button></div>} />
      <div className="p-6"><DataTable columns={columns} data={plans} /></div>
    </AppLayout>
  );
}
