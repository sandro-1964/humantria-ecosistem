import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { DataTable, Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Plus, Users, Shield, Key, MoreHorizontal } from 'lucide-react';

interface User {
  id: string;
  name: string;
  email: string;
  role: string;
  status: 'active' | 'inactive' | 'pending';
  lastLogin: string;
}

const users: User[] = [
  { id: '1', name: 'John Doe', email: 'john@acme.com', role: 'Admin', status: 'active', lastLogin: '2024-01-15 09:30' },
  { id: '2', name: 'Sarah Chen', email: 'sarah@acme.com', role: 'Manager', status: 'active', lastLogin: '2024-01-15 08:45' },
  { id: '3', name: 'Mike Johnson', email: 'mike@acme.com', role: 'Analyst', status: 'active', lastLogin: '2024-01-14 16:20' },
  { id: '4', name: 'Emily Davis', email: 'emily@acme.com', role: 'Viewer', status: 'pending', lastLogin: '-' },
];

const userColumns: Column<User>[] = [
  {
    key: 'name',
    header: 'User',
    cell: (row) => (
      <div>
        <p className="font-medium">{row.name}</p>
        <p className="text-xs text-muted-foreground">{row.email}</p>
      </div>
    ),
  },
  { key: 'role', header: 'Role' },
  {
    key: 'status',
    header: 'Status',
    cell: (row) => (
      <StatusBadge variant={row.status === 'active' ? 'success' : row.status === 'pending' ? 'warning' : 'default'}>
        {row.status}
      </StatusBadge>
    ),
  },
  { key: 'lastLogin', header: 'Last Login' },
];

export default function IAMPage() {
  return (
    <AppLayout>
      <PageHeader
        title="Identity & Access Management"
        description="Manage users, roles, and permissions"
        breadcrumbs={[
          { label: 'Foundation', href: '/foundation' },
          { label: 'IAM' },
        ]}
        actions={
          <div className="flex items-center gap-2">
            <AIActions onSuggest={() => {}} onExplain={() => {}} />
            <Button className="gap-2">
              <Plus className="h-4 w-4" />
              Add User
            </Button>
          </div>
        }
      />
      <div className="p-6">
        <Tabs defaultValue="users" className="space-y-4">
          <TabsList>
            <TabsTrigger value="users" className="gap-2">
              <Users className="h-4 w-4" />
              Users
            </TabsTrigger>
            <TabsTrigger value="roles" className="gap-2">
              <Shield className="h-4 w-4" />
              Roles
            </TabsTrigger>
            <TabsTrigger value="permissions" className="gap-2">
              <Key className="h-4 w-4" />
              Permissions
            </TabsTrigger>
          </TabsList>
          <TabsContent value="users">
            <DataTable columns={userColumns} data={users} />
          </TabsContent>
          <TabsContent value="roles">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {['Admin', 'Manager', 'Analyst', 'Viewer'].map((role) => (
                <Card key={role}>
                  <CardHeader>
                    <CardTitle className="text-base">{role}</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-sm text-muted-foreground">
                      {role === 'Admin' && 'Full system access with all permissions'}
                      {role === 'Manager' && 'Team management and approval capabilities'}
                      {role === 'Analyst' && 'Data analysis and reporting access'}
                      {role === 'Viewer' && 'Read-only access to dashboards'}
                    </p>
                  </CardContent>
                </Card>
              ))}
            </div>
          </TabsContent>
          <TabsContent value="permissions">
            <Card>
              <CardContent className="pt-6">
                <p className="text-muted-foreground">Permission matrix configuration coming soon.</p>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </AppLayout>
  );
}
