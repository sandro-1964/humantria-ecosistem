import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Plus, FileText, Copy } from 'lucide-react';
import { StatusBadge } from '@/components/ui/status-badge';

const templates = [
  { id: '1', name: 'Annual Planning Template', category: 'Strategy', usage: 45 },
  { id: '2', name: 'OKR Template', category: 'Objectives', usage: 128 },
  { id: '3', name: 'Budget Request', category: 'Finance', usage: 89 },
];

export default function TemplatesPage() {
  return (
    <AppLayout>
      <PageHeader title="Strategy Templates" description="Reusable planning templates" breadcrumbs={[{ label: 'Strategy', href: '/strategy' }, { label: 'Templates' }]} actions={<Button className="gap-2"><Plus className="h-4 w-4" />Create Template</Button>} />
      <div className="p-6 grid grid-cols-1 md:grid-cols-3 gap-4">
        {templates.map((t) => (
          <Card key={t.id}>
            <CardHeader className="flex flex-row items-start gap-3">
              <div className="p-2 rounded-md bg-primary/10"><FileText className="h-5 w-5 text-primary" /></div>
              <div><CardTitle className="text-base">{t.name}</CardTitle><p className="text-sm text-muted-foreground">{t.category}</p></div>
            </CardHeader>
            <CardContent><p className="text-sm text-muted-foreground">Used {t.usage} times</p><Button variant="outline" size="sm" className="mt-4 gap-1"><Copy className="h-3 w-3" />Use</Button></CardContent>
          </Card>
        ))}
      </div>
    </AppLayout>
  );
}
