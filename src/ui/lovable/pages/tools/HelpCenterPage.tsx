import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from '@/components/ui/accordion';
import { Search, Book, HelpCircle } from 'lucide-react';

const faqs = [
  { q: 'How do I create a new decision?', a: 'Navigate to Decision Hub and click "New Decision" to start the workflow.' },
  { q: 'How are approvals routed?', a: 'Approvals follow the configured workflow rules based on decision type and amount.' },
  { q: 'Can I export reports?', a: 'Yes, use the Export Center to download data in CSV, XLSX, or JSON formats.' },
];

export default function HelpCenterPage() {
  return (
    <AppLayout>
      <PageHeader title="Help Center" description="Documentation and support" breadcrumbs={[{ label: 'Tools', href: '/tools' }, { label: 'Help' }]} />
      <div className="p-6 space-y-6">
        <div className="relative max-w-md"><Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" /><Input placeholder="Search help articles..." className="pl-9" /></div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Card><CardHeader><CardTitle className="flex items-center gap-2"><Book className="h-5 w-5" />Documentation</CardTitle></CardHeader><CardContent><p className="text-sm text-muted-foreground">Browse comprehensive guides and tutorials.</p></CardContent></Card>
          <Card><CardHeader><CardTitle className="flex items-center gap-2"><HelpCircle className="h-5 w-5" />FAQ</CardTitle></CardHeader><CardContent><Accordion type="single" collapsible>{faqs.map((f, i) => (<AccordionItem key={i} value={`faq-${i}`}><AccordionTrigger className="text-sm">{f.q}</AccordionTrigger><AccordionContent className="text-sm text-muted-foreground">{f.a}</AccordionContent></AccordionItem>))}</Accordion></CardContent></Card>
        </div>
      </div>
    </AppLayout>
  );
}
