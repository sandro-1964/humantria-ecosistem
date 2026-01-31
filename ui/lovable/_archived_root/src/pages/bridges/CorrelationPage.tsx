import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { Search, GitBranch, ArrowRight } from 'lucide-react';

export default function CorrelationPage() {
  return (
    <AppLayout>
      <PageHeader title="Correlation Viewer" description="Trace event flows across services" breadcrumbs={[{ label: 'Bridges', href: '/bridges' }, { label: 'Correlation' }]} actions={<AIActions onExplain={() => {}} />} />
      <div className="p-6 space-y-6">
        <div className="flex gap-2 max-w-md">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input placeholder="Enter correlation ID..." className="pl-9" />
          </div>
          <Button>Search</Button>
        </div>
        <Card>
          <CardHeader><CardTitle>Event Flow</CardTitle></CardHeader>
          <CardContent>
            <div className="flex items-center justify-between p-4">
              {['user-service', 'workflow-engine', 'notification-service', 'analytics'].map((service, i, arr) => (
                <React.Fragment key={service}>
                  <div className="flex flex-col items-center">
                    <div className="p-3 rounded-lg bg-primary/10"><GitBranch className="h-6 w-6 text-primary" /></div>
                    <span className="mt-2 text-sm font-medium">{service}</span>
                  </div>
                  {i < arr.length - 1 && <ArrowRight className="h-5 w-5 text-muted-foreground" />}
                </React.Fragment>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </AppLayout>
  );
}
