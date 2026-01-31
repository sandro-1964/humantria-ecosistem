import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { StatusBadge } from '@/components/ui/status-badge';
import { Plus, FileText, Copy, MoreHorizontal } from 'lucide-react';

const templates = [
  { id: '1', name: 'Q4 Planning Template', category: 'Strategy', usage: 24, status: 'active' },
  { id: '2', name: 'Budget Request Form', category: 'Finance', usage: 156, status: 'active' },
  { id: '3', name: 'Headcount Justification', category: 'HR', usage: 89, status: 'active' },
  { id: '4', name: 'Risk Assessment Matrix', category: 'Compliance', usage: 45, status: 'draft' },
];

export default function TemplatesPage() {
  return (
    <AppLayout>
      <PageHeader
        title="Templates"
        description="Reusable templates for decisions, workflows, and documents"
        breadcrumbs={[
          { label: 'Foundation', href: '/foundation' },
          { label: 'Templates' },
        ]}
        actions={
          <div className="flex items-center gap-2">
            <AIActions onSuggest={() => {}} />
            <Button className="gap-2">
              <Plus className="h-4 w-4" />
              Create Template
            </Button>
          </div>
        }
      />
      <div className="p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {templates.map((template) => (
            <Card key={template.id}>
              <CardHeader className="flex flex-row items-start justify-between">
                <div className="flex items-start gap-3">
                  <div className="p-2 rounded-md bg-primary/10">
                    <FileText className="h-5 w-5 text-primary" />
                  </div>
                  <div>
                    <CardTitle className="text-base">{template.name}</CardTitle>
                    <p className="text-sm text-muted-foreground mt-1">{template.category}</p>
                  </div>
                </div>
                <StatusBadge variant={template.status === 'active' ? 'success' : 'default'}>
                  {template.status}
                </StatusBadge>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-muted-foreground">Used {template.usage} times</p>
                <div className="flex gap-2 mt-4">
                  <Button variant="outline" size="sm" className="gap-1">
                    <Copy className="h-3 w-3" />
                    Use
                  </Button>
                  <Button variant="ghost" size="sm">Edit</Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </AppLayout>
  );
}
