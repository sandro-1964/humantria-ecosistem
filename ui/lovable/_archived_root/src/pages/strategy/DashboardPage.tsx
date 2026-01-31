import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { KPICard } from '@/components/ui/kpi-card';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { AIActions } from '@/components/ui/ai-actions';
import { Target, TrendingUp, Users, DollarSign } from 'lucide-react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

const chartData = [
  { month: 'Jan', objectives: 85, budget: 78 },
  { month: 'Feb', objectives: 88, budget: 82 },
  { month: 'Mar', objectives: 82, budget: 85 },
  { month: 'Apr', objectives: 90, budget: 88 },
  { month: 'May', objectives: 92, budget: 90 },
  { month: 'Jun', objectives: 95, budget: 92 },
];

export default function DashboardPage() {
  return (
    <AppLayout>
      <PageHeader title="Strategy Dashboard" description="Strategic planning overview and key metrics" breadcrumbs={[{ label: 'Strategy', href: '/strategy' }, { label: 'Dashboard' }]} actions={<AIActions onSuggest={() => {}} onExplain={() => {}} onSimulate={() => {}} />} />
      <div className="p-6 space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <KPICard title="Objectives On Track" value="92%" change={4.2} icon={Target} />
          <KPICard title="Budget Utilization" value="78%" change={2.1} icon={DollarSign} />
          <KPICard title="Headcount Plan" value="847/900" change={-1.5} icon={Users} />
          <KPICard title="Initiative Progress" value="68%" change={5.8} icon={TrendingUp} />
        </div>
        <Card>
          <CardHeader><CardTitle>Performance Trend</CardTitle></CardHeader>
          <CardContent>
            <div className="h-80">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={chartData}>
                  <defs>
                    <linearGradient id="colorObj" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.3} />
                      <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                  <XAxis dataKey="month" stroke="hsl(var(--muted-foreground))" fontSize={12} />
                  <YAxis stroke="hsl(var(--muted-foreground))" fontSize={12} />
                  <Tooltip contentStyle={{ backgroundColor: 'hsl(var(--popover))', border: '1px solid hsl(var(--border))', borderRadius: '8px' }} />
                  <Area type="monotone" dataKey="objectives" stroke="hsl(var(--primary))" fillOpacity={1} fill="url(#colorObj)" />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>
      </div>
    </AppLayout>
  );
}
