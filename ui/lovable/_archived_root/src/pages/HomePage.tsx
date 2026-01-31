import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { KPICard } from '@/components/ui/kpi-card';
import { DataTable, Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { AIActions } from '@/components/ui/ai-actions';
import { StatsCard } from '@/components/ui/stats-card';
import { Timeline } from '@/components/ui/timeline';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import {
  Users,
  Building,
  Target,
  DollarSign,
  TrendingUp,
  Clock,
  CheckCircle,
  AlertTriangle,
  Calendar,
  FileCheck,
  Zap,
} from 'lucide-react';
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
} from 'recharts';

const areaData = [
  { month: 'Jan', value: 4000, budget: 4200 },
  { month: 'Feb', value: 3000, budget: 3500 },
  { month: 'Mar', value: 5000, budget: 4800 },
  { month: 'Apr', value: 4500, budget: 4600 },
  { month: 'May', value: 6000, budget: 5500 },
  { month: 'Jun', value: 5500, budget: 5800 },
];

const barData = [
  { name: 'Sales', completed: 85, target: 100 },
  { name: 'Engineering', completed: 72, target: 100 },
  { name: 'Marketing', completed: 90, target: 100 },
  { name: 'HR', completed: 65, target: 100 },
  { name: 'Finance', completed: 78, target: 100 },
];

const pieData = [
  { name: 'Approved', value: 65, color: 'hsl(var(--success))' },
  { name: 'Pending', value: 25, color: 'hsl(var(--warning))' },
  { name: 'Rejected', value: 10, color: 'hsl(var(--destructive))' },
];

interface Decision {
  id: string;
  title: string;
  department: string;
  status: 'approved' | 'pending' | 'rejected';
  date: string;
  owner: string;
}

const recentDecisions: Decision[] = [
  { id: '1', title: 'Q4 Budget Allocation', department: 'Finance', status: 'approved', date: '2024-01-15', owner: 'Sarah Chen' },
  { id: '2', title: 'New Hire Headcount', department: 'HR', status: 'pending', date: '2024-01-14', owner: 'Mike Johnson' },
  { id: '3', title: 'Product Launch Timeline', department: 'Product', status: 'approved', date: '2024-01-13', owner: 'Emily Davis' },
  { id: '4', title: 'Remote Work Policy Update', department: 'HR', status: 'pending', date: '2024-01-12', owner: 'Alex Rivera' },
  { id: '5', title: 'Vendor Contract Renewal', department: 'Procurement', status: 'rejected', date: '2024-01-11', owner: 'Chris Lee' },
];

const columns: Column<Decision>[] = [
  { key: 'title', header: 'Decision' },
  { key: 'department', header: 'Department' },
  {
    key: 'status',
    header: 'Status',
    cell: (row) => (
      <StatusBadge
        variant={
          row.status === 'approved'
            ? 'success'
            : row.status === 'pending'
            ? 'warning'
            : 'destructive'
        }
      >
        {row.status}
      </StatusBadge>
    ),
  },
  { key: 'owner', header: 'Owner' },
  { key: 'date', header: 'Date' },
];

const timelineItems = [
  {
    id: '1',
    title: 'Q4 Planning Initiated',
    description: 'Strategic planning cycle started for Q4 2024',
    timestamp: '2 hours ago',
    icon: Target,
    status: 'completed' as const,
  },
  {
    id: '2',
    title: 'Budget Review Meeting',
    description: 'Finance team completed quarterly budget review',
    timestamp: '4 hours ago',
    icon: DollarSign,
    status: 'completed' as const,
  },
  {
    id: '3',
    title: 'Headcount Approval',
    description: 'Pending approval for 5 new positions',
    timestamp: '1 day ago',
    icon: Users,
    status: 'current' as const,
  },
  {
    id: '4',
    title: 'Scenario Analysis',
    description: 'Complete scenario modeling for expansion',
    timestamp: 'Scheduled',
    icon: TrendingUp,
    status: 'pending' as const,
  },
];

export default function HomePage() {
  return (
    <AppLayout>
      <PageHeader
        title="Decision Hub"
        description="Enterprise decision governance overview and key metrics"
        actions={
          <AIActions
            onSuggest={() => console.log('AI Suggest')}
            onExplain={() => console.log('AI Explain')}
            onSimulate={() => console.log('AI Simulate')}
          />
        }
      />

      <div className="p-6 space-y-6">
        {/* KPI Row */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <KPICard
            title="Total Employees"
            value="2,847"
            change={3.2}
            changeLabel="vs last month"
            icon={Users}
          />
          <KPICard
            title="Active Decisions"
            value="142"
            change={-5.1}
            changeLabel="vs last month"
            icon={FileCheck}
          />
          <KPICard
            title="Budget Utilization"
            value="78.4%"
            change={2.8}
            changeLabel="vs target"
            icon={DollarSign}
          />
          <KPICard
            title="Objectives On Track"
            value="86%"
            change={4.5}
            changeLabel="vs last quarter"
            icon={Target}
          />
        </div>

        {/* Charts Row */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
          {/* Area Chart */}
          <Card className="lg:col-span-2 shadow-sm">
            <CardHeader className="pb-2">
              <CardTitle className="text-base font-medium">Budget vs Actual Spend</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="h-64">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={areaData}>
                    <defs>
                      <linearGradient id="colorValue" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.3} />
                        <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                    <XAxis
                      dataKey="month"
                      stroke="hsl(var(--muted-foreground))"
                      fontSize={12}
                    />
                    <YAxis stroke="hsl(var(--muted-foreground))" fontSize={12} />
                    <Tooltip
                      contentStyle={{
                        backgroundColor: 'hsl(var(--popover))',
                        border: '1px solid hsl(var(--border))',
                        borderRadius: '8px',
                      }}
                    />
                    <Area
                      type="monotone"
                      dataKey="value"
                      stroke="hsl(var(--primary))"
                      fillOpacity={1}
                      fill="url(#colorValue)"
                    />
                    <Area
                      type="monotone"
                      dataKey="budget"
                      stroke="hsl(var(--muted-foreground))"
                      strokeDasharray="5 5"
                      fill="transparent"
                    />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </CardContent>
          </Card>

          {/* Pie Chart */}
          <Card className="shadow-sm">
            <CardHeader className="pb-2">
              <CardTitle className="text-base font-medium">Decision Status</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="h-64 flex items-center justify-center">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={pieData}
                      cx="50%"
                      cy="50%"
                      innerRadius={50}
                      outerRadius={80}
                      paddingAngle={2}
                      dataKey="value"
                    >
                      {pieData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
              </div>
              <div className="flex justify-center gap-4 mt-2">
                {pieData.map((item) => (
                  <div key={item.name} className="flex items-center gap-1.5 text-xs">
                    <span
                      className="h-2 w-2 rounded-full"
                      style={{ backgroundColor: item.color }}
                    />
                    {item.name}
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Bar Chart & Timeline Row */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
          {/* Bar Chart */}
          <Card className="lg:col-span-2 shadow-sm">
            <CardHeader className="pb-2">
              <CardTitle className="text-base font-medium">Department OKR Progress</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="h-64">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={barData} layout="vertical">
                    <CartesianGrid
                      strokeDasharray="3 3"
                      stroke="hsl(var(--border))"
                      horizontal={false}
                    />
                    <XAxis type="number" stroke="hsl(var(--muted-foreground))" fontSize={12} />
                    <YAxis
                      dataKey="name"
                      type="category"
                      stroke="hsl(var(--muted-foreground))"
                      fontSize={12}
                      width={80}
                    />
                    <Tooltip
                      contentStyle={{
                        backgroundColor: 'hsl(var(--popover))',
                        border: '1px solid hsl(var(--border))',
                        borderRadius: '8px',
                      }}
                    />
                    <Bar dataKey="completed" fill="hsl(var(--primary))" radius={[0, 4, 4, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </CardContent>
          </Card>

          {/* Timeline */}
          <Card className="shadow-sm">
            <CardHeader className="pb-2">
              <CardTitle className="text-base font-medium">Recent Activity</CardTitle>
            </CardHeader>
            <CardContent>
              <Timeline items={timelineItems} />
            </CardContent>
          </Card>
        </div>

        {/* Recent Decisions Table */}
        <Card className="shadow-sm">
          <CardHeader className="pb-2">
            <CardTitle className="text-base font-medium">Recent Decisions</CardTitle>
          </CardHeader>
          <CardContent>
            <DataTable columns={columns} data={recentDecisions} pageSize={5} />
          </CardContent>
        </Card>

        {/* Stats Cards Row */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <StatsCard
            title="Pending Approvals"
            icon={Clock}
            stats={[
              { label: 'Budget', value: '12' },
              { label: 'Headcount', value: '8' },
              { label: 'Policy', value: '5' },
              { label: 'Other', value: '3' },
            ]}
          />
          <StatsCard
            title="Risk Alerts"
            icon={AlertTriangle}
            stats={[
              { label: 'Critical', value: '2' },
              { label: 'High', value: '5' },
              { label: 'Medium', value: '12' },
              { label: 'Low', value: '28' },
            ]}
          />
          <StatsCard
            title="This Week"
            icon={Calendar}
            stats={[
              { label: 'Meetings', value: '14' },
              { label: 'Reviews', value: '6' },
              { label: 'Deadlines', value: '3' },
              { label: 'Milestones', value: '2' },
            ]}
          />
          <StatsCard
            title="AI Insights"
            icon={Zap}
            stats={[
              { label: 'Suggestions', value: '45' },
              { label: 'Applied', value: '32' },
              { label: 'Accuracy', value: '94%' },
              { label: 'Time Saved', value: '18h' },
            ]}
          />
        </div>
      </div>
    </AppLayout>
  );
}
