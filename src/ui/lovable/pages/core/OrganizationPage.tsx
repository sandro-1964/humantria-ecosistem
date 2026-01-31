import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { Building, Users, ChevronRight, Plus } from 'lucide-react';

const orgStructure = [
  {
    id: '1',
    name: 'Acme Corporation',
    type: 'Company',
    children: [
      { id: '2', name: 'Engineering', type: 'Department', employees: 145 },
      { id: '3', name: 'Sales', type: 'Department', employees: 89 },
      { id: '4', name: 'Marketing', type: 'Department', employees: 52 },
      { id: '5', name: 'Human Resources', type: 'Department', employees: 28 },
      { id: '6', name: 'Finance', type: 'Department', employees: 34 },
    ],
  },
];

export default function OrganizationPage() {
  return (
    <AppLayout>
      <PageHeader
        title="Organization"
        description="Manage organizational structure and hierarchy"
        breadcrumbs={[
          { label: 'Core', href: '/core' },
          { label: 'Organization' },
        ]}
        actions={
          <div className="flex items-center gap-2">
            <AIActions onSuggest={() => {}} onSimulate={() => {}} />
            <Button className="gap-2">
              <Plus className="h-4 w-4" />
              Add Unit
            </Button>
          </div>
        }
      />
      <div className="p-6">
        <Card>
          <CardContent className="pt-6">
            {orgStructure.map((org) => (
              <div key={org.id}>
                <div className="flex items-center gap-3 p-3 rounded-md bg-muted mb-4">
                  <Building className="h-5 w-5 text-primary" />
                  <span className="font-semibold">{org.name}</span>
                  <span className="text-sm text-muted-foreground">({org.type})</span>
                </div>
                <div className="ml-6 space-y-2">
                  {org.children.map((child) => (
                    <div
                      key={child.id}
                      className="flex items-center justify-between p-3 rounded-md border hover:bg-muted/50 transition-colors cursor-pointer"
                    >
                      <div className="flex items-center gap-3">
                        <Users className="h-4 w-4 text-muted-foreground" />
                        <span className="font-medium">{child.name}</span>
                        <span className="text-sm text-muted-foreground">({child.type})</span>
                      </div>
                      <div className="flex items-center gap-4">
                        <span className="text-sm text-muted-foreground">{child.employees} employees</span>
                        <ChevronRight className="h-4 w-4 text-muted-foreground" />
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </CardContent>
        </Card>
      </div>
    </AppLayout>
  );
}
