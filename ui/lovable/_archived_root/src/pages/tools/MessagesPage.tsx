import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import { Send } from 'lucide-react';

const conversations = [
  { id: '1', name: 'Sarah Chen', lastMessage: 'Can you review the budget?', time: '10:30 AM' },
  { id: '2', name: 'Mike Johnson', lastMessage: 'Approved!', time: 'Yesterday' },
];

export default function MessagesPage() {
  return (
    <AppLayout>
      <PageHeader title="Messages" description="Internal messaging" breadcrumbs={[{ label: 'Tools', href: '/tools' }, { label: 'Messages' }]} />
      <div className="p-6 grid grid-cols-3 gap-4 h-[calc(100vh-200px)]">
        <Card className="col-span-1"><CardContent className="p-0">{conversations.map((c) => (<div key={c.id} className="flex items-center gap-3 p-4 border-b hover:bg-muted/50 cursor-pointer"><Avatar><AvatarFallback>{c.name[0]}</AvatarFallback></Avatar><div className="flex-1 min-w-0"><p className="font-medium truncate">{c.name}</p><p className="text-sm text-muted-foreground truncate">{c.lastMessage}</p></div><span className="text-xs text-muted-foreground">{c.time}</span></div>))}</CardContent></Card>
        <Card className="col-span-2 flex flex-col"><CardContent className="flex-1 p-4"><p className="text-center text-muted-foreground">Select a conversation</p></CardContent><div className="p-4 border-t flex gap-2"><Input placeholder="Type a message..." className="flex-1" /><Button><Send className="h-4 w-4" /></Button></div></Card>
      </div>
    </AppLayout>
  );
}
