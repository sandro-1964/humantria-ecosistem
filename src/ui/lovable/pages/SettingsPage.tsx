import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Switch } from '@/components/ui/switch';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { useApp } from '@/contexts/AppContext';
import { User, Bell, Shield, Palette } from 'lucide-react';

export default function SettingsPage() {
  const { theme, setTheme, density, setDensity } = useApp();

  return (
    <AppLayout>
      <PageHeader title="Settings" description="System and user preferences" />
      <div className="p-6">
        <Tabs defaultValue="profile" className="space-y-4">
          <TabsList>
            <TabsTrigger value="profile" className="gap-2"><User className="h-4 w-4" />Profile</TabsTrigger>
            <TabsTrigger value="notifications" className="gap-2"><Bell className="h-4 w-4" />Notifications</TabsTrigger>
            <TabsTrigger value="appearance" className="gap-2"><Palette className="h-4 w-4" />Appearance</TabsTrigger>
            <TabsTrigger value="security" className="gap-2"><Shield className="h-4 w-4" />Security</TabsTrigger>
          </TabsList>
          <TabsContent value="profile">
            <Card><CardHeader><CardTitle>Profile Information</CardTitle></CardHeader><CardContent className="space-y-4"><div className="grid grid-cols-2 gap-4"><div><Label>First Name</Label><Input defaultValue="John" /></div><div><Label>Last Name</Label><Input defaultValue="Doe" /></div></div><div><Label>Email</Label><Input defaultValue="john.doe@acme.com" /></div><Button>Save Changes</Button></CardContent></Card>
          </TabsContent>
          <TabsContent value="notifications">
            <Card><CardHeader><CardTitle>Notification Preferences</CardTitle></CardHeader><CardContent className="space-y-4">{['Email notifications', 'Push notifications', 'Weekly digest'].map((n) => (<div key={n} className="flex items-center justify-between py-2"><span>{n}</span><Switch /></div>))}</CardContent></Card>
          </TabsContent>
          <TabsContent value="appearance">
            <Card><CardHeader><CardTitle>Appearance</CardTitle></CardHeader><CardContent className="space-y-4"><div className="flex items-center justify-between py-2"><span>Dark Mode</span><Switch checked={theme === 'dark'} onCheckedChange={(c) => setTheme(c ? 'dark' : 'light')} /></div><div><Label>Density</Label><div className="flex gap-2 mt-2">{(['compact', 'comfortable', 'spacious'] as const).map((d) => (<Button key={d} variant={density === d ? 'default' : 'outline'} size="sm" onClick={() => setDensity(d)}>{d}</Button>))}</div></div></CardContent></Card>
          </TabsContent>
          <TabsContent value="security">
            <Card><CardHeader><CardTitle>Security Settings</CardTitle></CardHeader><CardContent className="space-y-4"><div className="flex items-center justify-between py-2"><span>Two-factor authentication</span><Switch /></div><Button variant="outline">Change Password</Button></CardContent></Card>
          </TabsContent>
        </Tabs>
      </div>
    </AppLayout>
  );
}
