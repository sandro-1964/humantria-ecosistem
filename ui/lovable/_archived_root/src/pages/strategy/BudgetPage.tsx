import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { KPICard } from '@/components/ui/kpi-card';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { AIActions } from '@/components/ui/ai-actions';
import { DollarSign, TrendingUp, PieChart } from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

const budgetData = [
  { dept: 'Engineering', allocated: 2500000, spent: 1800000 },
  { dept: 'Sales', allocated: 1800000, spent: 1650000 },
  { dept: 'Marketing', allocated: 1200000, spent: 950000 },
  { dept: 'HR', allocated: 800000, spent: 720000 },
];

export default function BudgetPage() {
  return (
    <AppLayout>
      <PageHeader title="Budget" description="Budget planning and tracking" breadcrumbs={[{ label: 'Strategy', href: '/strategy' }, { label: 'Budget' }]} actions={<AIActions onSuggest={() => {}} onSimulate={() => {}} />} />
      <div className="p-6 space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <KPICard title="Total Budget" value="$12.5M" icon={DollarSign} />
          <KPICard title="Spent YTD" value="$8.2M" change={-2.3} icon={TrendingUp} />
          <KPICard title="Remaining" value="$4.3M" icon={PieChart} />
        </div>
        <Card><CardHeader><CardTitle>Budget by Department</CardTitle></CardHeader><CardContent><div className="h-80"><ResponsiveContainer width="100%" height="100%"><BarChart data={budgetData}><CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" /><XAxis dataKey="dept" stroke="hsl(var(--muted-foreground))" fontSize={12} /><YAxis stroke="hsl(var(--muted-foreground))" fontSize={12} tickFormatter={(v) => `$${v/1000000}M`} /><Tooltip contentStyle={{ backgroundColor: 'hsl(var(--popover))', border: '1px solid hsl(var(--border))', borderRadius: '8px' }} /><Bar dataKey="allocated" fill="hsl(var(--muted))" /><Bar dataKey="spent" fill="hsl(var(--primary))" /></BarChart></ResponsiveContainer></div></CardContent></Card>
      </div>
    </AppLayout>
  );
}
