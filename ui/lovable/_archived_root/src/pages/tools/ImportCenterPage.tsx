import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Upload } from 'lucide-react';

export default function ImportCenterPage() {
  return (
    <AppLayout>
      <PageHeader title="Import Center" description="Import data from external sources" breadcrumbs={[{ label: 'Tools', href: '/tools' }, { label: 'Import' }]} />
      <div className="p-6">
        <Card><CardContent className="pt-6"><div className="border-2 border-dashed rounded-lg p-12 text-center"><Upload className="h-12 w-12 mx-auto text-muted-foreground" /><h3 className="mt-4 text-lg font-medium">Drop files here</h3><p className="mt-2 text-sm text-muted-foreground">CSV, XLSX, JSON supported</p><Button className="mt-4">Browse Files</Button></div></CardContent></Card>
      </div>
    </AppLayout>
  );
}
