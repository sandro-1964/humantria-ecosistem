import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Download, FileSpreadsheet, FileText } from 'lucide-react';

const exports = [
  { id: '1', name: 'People Directory', format: 'CSV', size: '2.4 MB' },
  { id: '2', name: 'Budget Report', format: 'XLSX', size: '1.8 MB' },
  { id: '3', name: 'Audit Log', format: 'JSON', size: '5.2 MB' },
];

export default function ExportCenterPage() {
  return (
    <AppLayout>
      <PageHeader title="Export Center" description="Export data and reports" breadcrumbs={[{ label: 'Tools', href: '/tools' }, { label: 'Export' }]} />
      <div className="p-6 grid grid-cols-1 md:grid-cols-3 gap-4">
        {exports.map((e) => (
          <Card key={e.id}><CardHeader><div className="flex items-center gap-2"><FileSpreadsheet className="h-5 w-5 text-primary" /><CardTitle className="text-base">{e.name}</CardTitle></div></CardHeader><CardContent><p className="text-sm text-muted-foreground">{e.format} • {e.size}</p><Button variant="outline" size="sm" className="mt-4 gap-2"><Download className="h-4 w-4" />Download</Button></CardContent></Card>
        ))}
      </div>
    </AppLayout>
  );
}
