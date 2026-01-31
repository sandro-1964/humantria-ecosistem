import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { DataTable, Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { DollarSign, CreditCard, FileText, Download } from 'lucide-react';

interface Invoice {
  id: string;
  number: string;
  amount: number;
  status: 'paid' | 'pending' | 'overdue';
  date: string;
  dueDate: string;
}

const invoices: Invoice[] = [
  { id: '1', number: 'INV-2024-001', amount: 12500, status: 'paid', date: '2024-01-01', dueDate: '2024-01-15' },
  { id: '2', number: 'INV-2024-002', amount: 12500, status: 'pending', date: '2024-02-01', dueDate: '2024-02-15' },
  { id: '3', number: 'INV-2023-012', amount: 11800, status: 'paid', date: '2023-12-01', dueDate: '2023-12-15' },
];

const columns: Column<Invoice>[] = [
  { key: 'number', header: 'Invoice #' },
  {
    key: 'amount',
    header: 'Amount',
    cell: (row) => <span className="font-medium">${row.amount.toLocaleString()}</span>,
  },
  {
    key: 'status',
    header: 'Status',
    cell: (row) => (
      <StatusBadge variant={row.status === 'paid' ? 'success' : row.status === 'pending' ? 'warning' : 'destructive'}>
        {row.status}
      </StatusBadge>
    ),
  },
  { key: 'date', header: 'Date' },
  { key: 'dueDate', header: 'Due Date' },
  {
    key: 'actions',
    header: '',
    cell: () => (
      <Button variant="ghost" size="sm">
        <Download className="h-4 w-4" />
      </Button>
    ),
  },
];

export default function BillingPage() {
  return (
    <AppLayout>
      <PageHeader
        title="Billing"
        description="Manage subscriptions, invoices, and payment methods"
        breadcrumbs={[
          { label: 'Foundation', href: '/foundation' },
          { label: 'Billing' },
        ]}
        actions={<AIActions onExplain={() => {}} />}
      />
      <div className="p-6 space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Current Plan</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">Enterprise</div>
              <p className="text-xs text-muted-foreground">$12,500/month</p>
              <Button variant="outline" size="sm" className="mt-4">Manage Plan</Button>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Next Payment</CardTitle>
              <DollarSign className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">$12,500</div>
              <p className="text-xs text-muted-foreground">Due Feb 15, 2024</p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Payment Method</CardTitle>
              <CreditCard className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-lg font-medium">•••• 4242</div>
              <p className="text-xs text-muted-foreground">Expires 12/25</p>
              <Button variant="outline" size="sm" className="mt-4">Update</Button>
            </CardContent>
          </Card>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Invoice History</CardTitle>
          </CardHeader>
          <CardContent>
            <DataTable columns={columns} data={invoices} />
          </CardContent>
        </Card>
      </div>
    </AppLayout>
  );
}
