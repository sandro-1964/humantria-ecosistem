import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { StatusBadge } from '@/components/ui/status-badge';
import { Switch } from '@/components/ui/switch';
import { Shield, Eye, Trash2, Download, FileText } from 'lucide-react';

export default function PrivacyPage() {
  return (
    <AppLayout>
      <PageHeader
        title="Privacy & LGPD"
        description="Data protection and privacy compliance management"
        breadcrumbs={[
          { label: 'Foundation', href: '/foundation' },
          { label: 'Privacy' },
        ]}
        actions={<AIActions onSuggest={() => {}} onExplain={() => {}} />}
      />
      <div className="p-6 space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Consent Rate</CardTitle>
              <Shield className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">94.2%</div>
              <p className="text-xs text-muted-foreground">Active consents</p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Data Requests</CardTitle>
              <Eye className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">12</div>
              <p className="text-xs text-muted-foreground">Pending this month</p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Deletion Requests</CardTitle>
              <Trash2 className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">3</div>
              <p className="text-xs text-muted-foreground">In processing</p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Export Requests</CardTitle>
              <Download className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">8</div>
              <p className="text-xs text-muted-foreground">Completed this month</p>
            </CardContent>
          </Card>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Privacy Settings</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {[
              { label: 'Enable Cookie Consent Banner', enabled: true },
              { label: 'Automatic Data Retention Policy', enabled: true },
              { label: 'Anonymous Analytics Collection', enabled: false },
              { label: 'Third-party Data Sharing', enabled: false },
            ].map((setting) => (
              <div key={setting.label} className="flex items-center justify-between py-2 border-b last:border-0">
                <span className="text-sm">{setting.label}</span>
                <Switch checked={setting.enabled} />
              </div>
            ))}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Compliance Documents</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              {['Privacy Policy', 'Terms of Service', 'Cookie Policy', 'Data Processing Agreement'].map((doc) => (
                <div key={doc} className="flex items-center justify-between py-2 border-b last:border-0">
                  <div className="flex items-center gap-2">
                    <FileText className="h-4 w-4 text-muted-foreground" />
                    <span className="text-sm">{doc}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <StatusBadge variant="success">Published</StatusBadge>
                    <Button variant="ghost" size="sm">Edit</Button>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </AppLayout>
  );
}
