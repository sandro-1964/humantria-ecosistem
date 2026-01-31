import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { DataTable, Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { Plus, UserCheck } from 'lucide-react';

interface Assignment {
  id: string;
  employee: string;
  role: string;
  project: string;
  allocation: number;
  startDate: string;
  endDate: string;
  status: 'active' | 'upcoming' | 'ended';
}

const assignments: Assignment[] = [
  { id: '1', employee: 'John Doe', role: 'Tech Lead', project: 'Platform Redesign', allocation: 100, startDate: '2024-01-01', endDate: '2024-06-30', status: 'active' },
  { id: '2', employee: 'Sarah Chen', role: 'Product Owner', project: 'Mobile App', allocation: 80, startDate: '2024-01-15', endDate: '2024-12-31', status: 'active' },
  { id: '3', employee: 'Mike Johnson', role: 'Account Manager', project: 'Enterprise Sales', allocation: 100, startDate: '2024-02-01', endDate: '2024-12-31', status: 'upcoming' },
];

const columns: Column<Assignment>[] = [
  { key: 'employee', header: 'Employee' },
  { key: 'role', header: 'Role' },
  { key: 'project', header: 'Project' },
  { key: 'allocation', header: 'Allocation', cell: (row) => <span>{row.allocation}%</span> },
  { key: 'startDate', header: 'Start' },
  { key: 'endDate', header: 'End' },
  {
    key: 'status',
    header: 'Status',
    cell: (row) => (
      <StatusBadge variant={row.status === 'active' ? 'success' : row.status === 'upcoming' ? 'info' : 'default'}>
        {row.status}
      </StatusBadge>
    ),
  },
];

export default function AssignmentsPage() {
  return (
    <AppLayout>
      <PageHeader
        title="Assignments"
        description="Manage role and project assignments"
        breadcrumbs={[{ label: 'Core', href: '/core' }, { label: 'Assignments' }]}
        actions={
          <div className="flex items-center gap-2">
            <AIActions onSuggest={() => {}} onSimulate={() => {}} />
            <Button className="gap-2"><Plus className="h-4 w-4" />New Assignment</Button>
          </div>
        }
      />
      <div className="p-6">
        <DataTable columns={columns} data={assignments} />
      </div>
    </AppLayout>
  );
}
