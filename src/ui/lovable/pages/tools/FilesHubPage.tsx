import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { DataTable, Column } from '@/components/ui/data-table';
import { Button } from '@/components/ui/button';
import { Upload, File, Download, Trash2 } from 'lucide-react';

interface FileItem { id: string; name: string; type: string; size: string; uploaded: string; }
const files: FileItem[] = [
  { id: '1', name: 'Q4_Report.pdf', type: 'PDF', size: '2.4 MB', uploaded: '2024-01-15' },
  { id: '2', name: 'Budget_2024.xlsx', type: 'XLSX', size: '1.8 MB', uploaded: '2024-01-14' },
  { id: '3', name: 'Team_Photo.jpg', type: 'JPG', size: '5.2 MB', uploaded: '2024-01-10' },
];

const columns: Column<FileItem>[] = [
  { key: 'name', header: 'Name', cell: (row) => <div className="flex items-center gap-2"><File className="h-4 w-4 text-muted-foreground" /><span>{row.name}</span></div> },
  { key: 'type', header: 'Type' },
  { key: 'size', header: 'Size' },
  { key: 'uploaded', header: 'Uploaded' },
  { key: 'actions', header: '', cell: () => <div className="flex gap-1"><Button variant="ghost" size="sm"><Download className="h-4 w-4" /></Button><Button variant="ghost" size="sm"><Trash2 className="h-4 w-4 text-destructive" /></Button></div> },
];

export default function FilesHubPage() {
  return (
    <AppLayout>
      <PageHeader title="Files Hub" description="Central file management" breadcrumbs={[{ label: 'Tools', href: '/tools' }, { label: 'Files' }]} actions={<Button className="gap-2"><Upload className="h-4 w-4" />Upload</Button>} />
      <div className="p-6"><DataTable columns={columns} data={files} /></div>
    </AppLayout>
  );
}
