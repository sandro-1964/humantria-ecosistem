import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Bell, Check } from 'lucide-react';

const notifications = [
  { id: '1', title: 'Budget approved', description: 'Q2 budget request has been approved', time: '2 hours ago', read: false },
  { id: '2', title: 'New comment', description: 'Sarah commented on your decision', time: '4 hours ago', read: false },
  { id: '3', title: 'Task assigned', description: 'You have been assigned a new review task', time: '1 day ago', read: true },
];

export default function NotificationsPage() {
  return (
    <AppLayout>
      <PageHeader title="Notifications" description="System notifications and alerts" breadcrumbs={[{ label: 'Tools', href: '/tools' }, { label: 'Notifications' }]} actions={<Button variant="outline">Mark all as read</Button>} />
      <div className="p-6 space-y-2">
        {notifications.map((n) => (
          <Card key={n.id} className={n.read ? 'opacity-60' : ''}><CardContent className="flex items-center gap-4 py-4"><Bell className="h-5 w-5 text-primary" /><div className="flex-1"><p className="font-medium">{n.title}</p><p className="text-sm text-muted-foreground">{n.description}</p></div><span className="text-xs text-muted-foreground">{n.time}</span>{!n.read && <Button variant="ghost" size="sm"><Check className="h-4 w-4" /></Button>}</CardContent></Card>
        ))}
      </div>
    </AppLayout>
  );
}
