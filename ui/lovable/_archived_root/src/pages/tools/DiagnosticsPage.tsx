import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { StatusBadge } from '@/components/ui/status-badge';
import { Activity, Database, Server, Wifi } from 'lucide-react';

const services = [
  { name: 'API Gateway', status: 'healthy', latency: '23ms' },
  { name: 'Database', status: 'healthy', latency: '5ms' },
  { name: 'Cache', status: 'healthy', latency: '2ms' },
  { name: 'Queue', status: 'degraded', latency: '145ms' },
];

export default function ToolsDiagnosticsPage() {
  return (
    <AppLayout>
      <PageHeader title="Diagnostics" description="System health monitoring" breadcrumbs={[{ label: 'Tools', href: '/tools' }, { label: 'Diagnostics' }]} />
      <div className="p-6 grid grid-cols-1 md:grid-cols-2 gap-4">
        {services.map((s) => (
          <Card key={s.name}><CardHeader className="flex flex-row items-center justify-between pb-2"><CardTitle className="text-base">{s.name}</CardTitle><StatusBadge variant={s.status === 'healthy' ? 'success' : 'warning'}>{s.status}</StatusBadge></CardHeader><CardContent><p className="text-sm text-muted-foreground">Latency: {s.latency}</p></CardContent></Card>
        ))}
      </div>
    </AppLayout>
  );
}
