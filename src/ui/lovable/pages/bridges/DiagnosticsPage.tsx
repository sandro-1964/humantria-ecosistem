import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { StatusBadge } from '@/components/ui/status-badge';
import { AIActions } from '@/components/ui/ai-actions';
import { Activity, CheckCircle, AlertTriangle, XCircle } from 'lucide-react';

const services = [
  { name: 'Event Bus', status: 'healthy', latency: '12ms', uptime: '99.99%' },
  { name: 'Message Queue', status: 'healthy', latency: '8ms', uptime: '99.98%' },
  { name: 'API Gateway', status: 'degraded', latency: '145ms', uptime: '99.85%' },
  { name: 'Database', status: 'healthy', latency: '3ms', uptime: '99.99%' },
];

export default function DiagnosticsPage() {
  return (
    <AppLayout>
      <PageHeader title="Diagnostics" description="System health and diagnostics" breadcrumbs={[{ label: 'Bridges', href: '/bridges' }, { label: 'Diagnostics' }]} actions={<AIActions onExplain={() => {}} />} />
      <div className="p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {services.map((service) => (
            <Card key={service.name}>
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-base">{service.name}</CardTitle>
                <StatusBadge variant={service.status === 'healthy' ? 'success' : service.status === 'degraded' ? 'warning' : 'destructive'}>{service.status}</StatusBadge>
              </CardHeader>
              <CardContent>
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">Latency: {service.latency}</span>
                  <span className="text-muted-foreground">Uptime: {service.uptime}</span>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </AppLayout>
  );
}
