import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { AIActions } from '@/components/ui/ai-actions';
import { Play } from 'lucide-react';

export default function SandboxPage() {
  return (
    <AppLayout>
      <PageHeader title="Sandbox" description="Test and experiment with data and configurations" breadcrumbs={[{ label: 'Tools', href: '/tools' }, { label: 'Sandbox' }]} actions={<AIActions onSuggest={() => {}} onSimulate={() => {}} />} />
      <div className="p-6 space-y-4">
        <Card><CardContent className="pt-6"><Textarea placeholder="Enter your query or script..." className="min-h-[200px] font-mono" /><Button className="mt-4 gap-2"><Play className="h-4 w-4" />Execute</Button></CardContent></Card>
        <Card><CardContent className="pt-6"><p className="text-sm text-muted-foreground">Results will appear here...</p></CardContent></Card>
      </div>
    </AppLayout>
  );
}
