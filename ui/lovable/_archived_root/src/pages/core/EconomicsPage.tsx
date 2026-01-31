import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { KPICard } from '@/components/ui/kpi-card';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { AIActions } from '@/components/ui/ai-actions';
import { DollarSign, TrendingUp, Users, Percent } from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

const salaryData = [
  { department: 'Engineering', avg: 125000 },
  { department: 'Product', avg: 115000 },
  { department: 'Sales', avg: 95000 },
  { department: 'Marketing', avg: 85000 },
  { department: 'HR', avg: 75000 },
];

export default function EconomicsPage() {
  return (
    <AppLayout>
      <PageHeader
        title="Economics"
        description="Compensation and workforce economics analytics"
        breadcrumbs={[{ label: 'Core', href: '/core' }, { label: 'Economics' }]}
        actions={<AIActions onSuggest={() => {}} onExplain={() => {}} onSimulate={() => {}} />}
      />
      <div className="p-6 space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <KPICard title="Total Payroll" value="$4.2M" change={3.2} changeLabel="vs last quarter" icon={DollarSign} />
          <KPICard title="Avg Salary" value="$98,500" change={2.1} changeLabel="YoY" icon={TrendingUp} />
          <KPICard title="Headcount" value="847" change={5.4} changeLabel="vs last quarter" icon={Users} />
          <KPICard title="Benefits Cost" value="22.5%" change={-1.2} changeLabel="of payroll" icon={Percent} />
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Average Salary by Department</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-80">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={salaryData} layout="vertical">
                  <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                  <XAxis type="number" stroke="hsl(var(--muted-foreground))" fontSize={12} tickFormatter={(v) => `$${(v/1000)}k`} />
                  <YAxis dataKey="department" type="category" stroke="hsl(var(--muted-foreground))" fontSize={12} width={100} />
                  <Tooltip contentStyle={{ backgroundColor: 'hsl(var(--popover))', border: '1px solid hsl(var(--border))', borderRadius: '8px' }} formatter={(v: number) => [`$${v.toLocaleString()}`, 'Average Salary']} />
                  <Bar dataKey="avg" fill="hsl(var(--primary))" radius={[0, 4, 4, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>
      </div>
    </AppLayout>
  );
}
