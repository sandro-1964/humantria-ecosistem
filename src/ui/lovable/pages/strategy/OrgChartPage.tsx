import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent } from '@/components/ui/card';
import { AIActions } from '@/components/ui/ai-actions';
import { User } from 'lucide-react';

const orgData = { name: 'CEO', title: 'Chief Executive Officer', children: [
  { name: 'CTO', title: 'Chief Technology Officer', children: [{ name: 'VP Engineering', title: 'VP Engineering' }] },
  { name: 'CFO', title: 'Chief Financial Officer', children: [{ name: 'Controller', title: 'Controller' }] },
  { name: 'COO', title: 'Chief Operating Officer', children: [{ name: 'VP Operations', title: 'VP Operations' }] },
]};

const OrgNode = ({ node, level = 0 }: { node: any; level?: number }) => (
  <div className="flex flex-col items-center">
    <div className="p-4 rounded-lg border bg-card shadow-card min-w-[160px] text-center">
      <div className="h-10 w-10 rounded-full bg-primary/10 flex items-center justify-center mx-auto"><User className="h-5 w-5 text-primary" /></div>
      <p className="font-medium mt-2">{node.name}</p>
      <p className="text-xs text-muted-foreground">{node.title}</p>
    </div>
    {node.children && <div className="flex gap-8 mt-6 pt-6 border-t relative">{node.children.map((child: any, i: number) => <OrgNode key={i} node={child} level={level + 1} />)}</div>}
  </div>
);

export default function OrgChartPage() {
  return (
    <AppLayout>
      <PageHeader title="Organization Chart" description="Visual organization structure" breadcrumbs={[{ label: 'Strategy', href: '/strategy' }, { label: 'Org Chart' }]} actions={<AIActions onSuggest={() => {}} onSimulate={() => {}} />} />
      <div className="p-6 overflow-auto"><div className="flex justify-center"><OrgNode node={orgData} /></div></div>
    </AppLayout>
  );
}
