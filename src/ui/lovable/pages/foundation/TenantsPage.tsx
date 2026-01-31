import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { DataTable, Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { Plus, Building, MoreHorizontal } from 'lucide-react';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';

interface Tenant {
  id: string;
  name: string;
  domain: string;
  plan: string;
  status: 'active' | 'suspended' | 'trial';
  users: number;
  created: string;
}

const tenants: Tenant[] = [
  { id: '1', name: 'Acme Corporation', domain: 'acme.humantria.io', plan: 'Enterprise', status: 'active', users: 245, created: '2023-06-15' },
  { id: '2', name: 'TechStart Inc', domain: 'techstart.humantria.io', plan: 'Professional', status: 'active', users: 52, created: '2023-09-22' },
  { id: '3', name: 'Global Finance', domain: 'globalfin.humantria.io', plan: 'Enterprise', status: 'active', users: 1203, created: '2023-03-08' },
  { id: '4', name: 'Startup Labs', domain: 'startuplabs.humantria.io', plan: 'Starter', status: 'trial', users: 12, created: '2024-01-02' },
  { id: '5', name: 'Old Corp', domain: 'oldcorp.humantria.io', plan: 'Professional', status: 'suspended', users: 0, created: '2022-11-30' },
];

const columns: Column<Tenant>[] = [
  {
    key: 'name',
    header: 'Tenant Name',
    cell: (row) => (
      <div className="flex items-center gap-2">
        <div className="h-8 w-8 rounded bg-primary/10 flex items-center justify-center">
          <Building className="h-4 w-4 text-primary" />
        </div>
        <div>
          <p className="font-medium">{row.name}</p>
          <p className="text-xs text-muted-foreground">{row.domain}</p>
        </div>
      </div>
    ),
  },
  { key: 'plan', header: 'Plan' },
  {
    key: 'status',
    header: 'Status',
    cell: (row) => (
      <StatusBadge
        variant={
          row.status === 'active' ? 'success' : row.status === 'trial' ? 'info' : 'destructive'
        }
      >
        {row.status}
      </StatusBadge>
    ),
  },
  { key: 'users', header: 'Users' },
  { key: 'created', header: 'Created' },
  {
    key: 'actions',
    header: '',
    cell: () => (
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="ghost" size="sm">
            <MoreHorizontal className="h-4 w-4" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          <DropdownMenuItem>View Details</DropdownMenuItem>
          <DropdownMenuItem>Edit</DropdownMenuItem>
          <DropdownMenuItem>Manage Users</DropdownMenuItem>
          <DropdownMenuItem className="text-destructive">Suspend</DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    ),
  },
];

export default function TenantsPage() {
  return (
    <AppLayout>
      <PageHeader
        title="Tenants"
        description="Manage multi-tenant organizations and configurations"
        breadcrumbs={[
          { label: 'Foundation', href: '/foundation' },
          { label: 'Tenants' },
        ]}
        actions={
          <div className="flex items-center gap-2">
            <AIActions onSuggest={() => {}} onExplain={() => {}} />
            <Button className="gap-2">
              <Plus className="h-4 w-4" />
              Add Tenant
            </Button>
          </div>
        }
      />
      <div className="p-6">
        <DataTable columns={columns} data={tenants} />
      </div>
    </AppLayout>
  );
}
