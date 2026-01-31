import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { DataTable, Column } from '@/components/ui/data-table';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Plus, Briefcase, TrendingUp } from 'lucide-react';

interface Job {
  id: string;
  title: string;
  family: string;
  level: string;
  minSalary: number;
  maxSalary: number;
  headcount: number;
}

const jobs: Job[] = [
  { id: '1', title: 'Software Engineer', family: 'Engineering', level: 'L3', minSalary: 80000, maxSalary: 120000, headcount: 45 },
  { id: '2', title: 'Senior Software Engineer', family: 'Engineering', level: 'L4', minSalary: 120000, maxSalary: 160000, headcount: 28 },
  { id: '3', title: 'Product Manager', family: 'Product', level: 'L4', minSalary: 100000, maxSalary: 140000, headcount: 12 },
  { id: '4', title: 'Sales Representative', family: 'Sales', level: 'L2', minSalary: 60000, maxSalary: 90000, headcount: 35 },
];

const columns: Column<Job>[] = [
  { key: 'title', header: 'Job Title' },
  { key: 'family', header: 'Job Family' },
  { key: 'level', header: 'Level' },
  { key: 'minSalary', header: 'Min Salary', cell: (row) => `$${row.minSalary.toLocaleString()}` },
  { key: 'maxSalary', header: 'Max Salary', cell: (row) => `$${row.maxSalary.toLocaleString()}` },
  { key: 'headcount', header: 'Headcount' },
];

export default function JobsPage() {
  return (
    <AppLayout>
      <PageHeader
        title="Jobs & Levels"
        description="Job architecture and career levels"
        breadcrumbs={[{ label: 'Core', href: '/core' }, { label: 'Jobs & Levels' }]}
        actions={
          <div className="flex items-center gap-2">
            <AIActions onSuggest={() => {}} onExplain={() => {}} />
            <Button className="gap-2"><Plus className="h-4 w-4" />Add Job</Button>
          </div>
        }
      />
      <div className="p-6">
        <Tabs defaultValue="jobs" className="space-y-4">
          <TabsList>
            <TabsTrigger value="jobs" className="gap-2"><Briefcase className="h-4 w-4" />Jobs</TabsTrigger>
            <TabsTrigger value="levels" className="gap-2"><TrendingUp className="h-4 w-4" />Levels</TabsTrigger>
          </TabsList>
          <TabsContent value="jobs">
            <DataTable columns={columns} data={jobs} />
          </TabsContent>
          <TabsContent value="levels">
            <div className="grid grid-cols-6 gap-4">
              {['L1', 'L2', 'L3', 'L4', 'L5', 'L6'].map((level) => (
                <div key={level} className="p-4 rounded-lg border bg-card text-center">
                  <p className="text-2xl font-bold text-primary">{level}</p>
                  <p className="text-sm text-muted-foreground mt-1">{level === 'L1' ? 'Entry' : level === 'L6' ? 'Executive' : 'Professional'}</p>
                </div>
              ))}
            </div>
          </TabsContent>
        </Tabs>
      </div>
    </AppLayout>
  );
}
