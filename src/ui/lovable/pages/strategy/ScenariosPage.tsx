import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { Plus, GitBranch } from 'lucide-react';

const scenarios = [
  { id: '1', name: 'Base Case', description: 'Current trajectory with no major changes', probability: '60%' },
  { id: '2', name: 'Growth Scenario', description: '20% revenue increase, 15% headcount expansion', probability: '25%' },
  { id: '3', name: 'Conservative', description: 'Reduced spending, hiring freeze', probability: '15%' },
];

export default function ScenariosPage() {
  return (
    <AppLayout>
      <PageHeader title="Scenarios" description="Strategic scenario planning and modeling" breadcrumbs={[{ label: 'Strategy', href: '/strategy' }, { label: 'Scenarios' }]} actions={<div className="flex items-center gap-2"><AIActions onSuggest={() => {}} onSimulate={() => {}} /><Button className="gap-2"><Plus className="h-4 w-4" />New Scenario</Button></div>} />
      <div className="p-6 grid grid-cols-1 md:grid-cols-3 gap-4">
        {scenarios.map((s) => (
          <Card key={s.id} className="cursor-pointer hover:shadow-card-hover transition-shadow">
            <CardHeader><div className="flex items-center gap-2"><GitBranch className="h-5 w-5 text-primary" /><CardTitle className="text-base">{s.name}</CardTitle></div></CardHeader>
            <CardContent><p className="text-sm text-muted-foreground">{s.description}</p><p className="mt-4 text-sm">Probability: <span className="font-medium">{s.probability}</span></p></CardContent>
          </Card>
        ))}
      </div>
    </AppLayout>
  );
}
