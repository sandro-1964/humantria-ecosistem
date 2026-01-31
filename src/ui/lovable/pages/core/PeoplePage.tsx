import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { DataTable, Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { Input } from '@/components/ui/input';
import { Plus, Search, Filter, User, MoreHorizontal } from 'lucide-react';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from '@/components/ui/dropdown-menu';

interface Person {
  id: string;
  name: string;
  email: string;
  department: string;
  jobTitle: string;
  level: string;
  status: 'active' | 'inactive' | 'onboarding';
  startDate: string;
}

const people: Person[] = [
  { id: '1', name: 'John Doe', email: 'john@acme.com', department: 'Engineering', jobTitle: 'Senior Engineer', level: 'L4', status: 'active', startDate: '2022-03-15' },
  { id: '2', name: 'Sarah Chen', email: 'sarah@acme.com', department: 'Product', jobTitle: 'Product Manager', level: 'L5', status: 'active', startDate: '2021-08-01' },
  { id: '3', name: 'Mike Johnson', email: 'mike@acme.com', department: 'Sales', jobTitle: 'Account Executive', level: 'L3', status: 'active', startDate: '2023-01-10' },
  { id: '4', name: 'Emily Davis', email: 'emily@acme.com', department: 'HR', jobTitle: 'HR Specialist', level: 'L2', status: 'onboarding', startDate: '2024-01-08' },
  { id: '5', name: 'Alex Rivera', email: 'alex@acme.com', department: 'Finance', jobTitle: 'Financial Analyst', level: 'L3', status: 'active', startDate: '2022-11-20' },
];

const columns: Column<Person>[] = [
  {
    key: 'name',
    header: 'Employee',
    cell: (row) => (
      <div className="flex items-center gap-3">
        <Avatar className="h-8 w-8">
          <AvatarFallback className="text-xs">{row.name.split(' ').map(n => n[0]).join('')}</AvatarFallback>
        </Avatar>
        <div>
          <p className="font-medium">{row.name}</p>
          <p className="text-xs text-muted-foreground">{row.email}</p>
        </div>
      </div>
    ),
  },
  { key: 'department', header: 'Department' },
  { key: 'jobTitle', header: 'Job Title' },
  { key: 'level', header: 'Level' },
  {
    key: 'status',
    header: 'Status',
    cell: (row) => (
      <StatusBadge variant={row.status === 'active' ? 'success' : row.status === 'onboarding' ? 'info' : 'default'}>
        {row.status}
      </StatusBadge>
    ),
  },
  { key: 'startDate', header: 'Start Date' },
  {
    key: 'actions',
    header: '',
    cell: () => (
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="ghost" size="sm"><MoreHorizontal className="h-4 w-4" /></Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          <DropdownMenuItem>View Profile</DropdownMenuItem>
          <DropdownMenuItem>Edit</DropdownMenuItem>
          <DropdownMenuItem>Assignments</DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    ),
  },
];

export default function PeoplePage() {
  return (
    <AppLayout>
      <PageHeader
        title="People"
        description="Manage employees and personnel records"
        breadcrumbs={[
          { label: 'Core', href: '/core' },
          { label: 'People' },
        ]}
        actions={
          <div className="flex items-center gap-2">
            <AIActions onSuggest={() => {}} onExplain={() => {}} />
            <Button className="gap-2">
              <Plus className="h-4 w-4" />
              Add Person
            </Button>
          </div>
        }
      />
      <div className="p-6 space-y-4">
        <div className="flex gap-2">
          <div className="relative flex-1 max-w-sm">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input placeholder="Search people..." className="pl-9" />
          </div>
          <Button variant="outline" className="gap-2">
            <Filter className="h-4 w-4" />
            Filters
          </Button>
        </div>
        <DataTable columns={columns} data={people} />
      </div>
    </AppLayout>
  );
}
