import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { StatusBadge } from '@/components/ui/status-badge';
import { Plus, Database, Server, FileJson, RefreshCw, Settings } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';

const integrations = [
  { id: '1', name: 'SAP ERP', type: 'ERP', status: 'active', lastSync: '2024-02-01 14:30', records: 45230 },
  { id: '2', name: 'Oracle HCM', type: 'HCM', status: 'active', lastSync: '2024-02-01 12:00', records: 12450 },
  { id: '3', name: 'Workday', type: 'HCM', status: 'syncing', lastSync: '2024-02-01 15:45', records: 8320 },
  { id: '4', name: 'Legacy Payroll DB', type: 'Database', status: 'error', lastSync: '2024-01-30 09:00', records: 0 },
  { id: '5', name: 'Custom SOAP API', type: 'API', status: 'inactive', lastSync: '2024-01-15 10:30', records: 3200 },
];

export default function LegacyIntegrationsPage() {
  const { toast } = useToast();

  const handleSync = (integration: typeof integrations[0]) => {
    toast({
      title: "Sync Started",
      description: `Synchronizing data from ${integration.name}...`,
    });
  };

  const handleConfigure = (integration: typeof integrations[0]) => {
    toast({
      title: "Configuration",
      description: `Opening configuration for ${integration.name}...`,
    });
  };

  return (
    <AppLayout>
      <PageHeader 
        title="Legacy Integrations" 
        description="Connect and synchronize with existing enterprise systems"
        breadcrumbs={[{ label: 'Tools', href: '/tools' }, { label: 'Legacy Integrations' }]}
        actions={
          <Button className="gap-2">
            <Plus className="h-4 w-4" />
            Add Integration
          </Button>
        }
      />
      
      <div className="p-6 space-y-6">
        {/* Integration Stats */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <Card>
            <CardContent className="pt-6">
              <p className="text-sm text-muted-foreground">Active Integrations</p>
              <p className="text-3xl font-bold text-success">3</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <p className="text-sm text-muted-foreground">Total Records Synced</p>
              <p className="text-3xl font-bold">66K</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <p className="text-sm text-muted-foreground">Sync Errors</p>
              <p className="text-3xl font-bold text-destructive">1</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <p className="text-sm text-muted-foreground">Last Full Sync</p>
              <p className="text-xl font-bold">2h ago</p>
            </CardContent>
          </Card>
        </div>

        {/* Integrations List */}
        <Card>
          <CardHeader>
            <CardTitle>Connected Systems</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {integrations.map((integration) => (
                <div 
                  key={integration.id}
                  className="flex items-center justify-between p-4 border rounded-lg hover:bg-muted/30 transition-colors"
                >
                  <div className="flex items-center gap-4">
                    <div className={`p-2 rounded-md ${
                      integration.type === 'ERP' ? 'bg-primary/10' :
                      integration.type === 'HCM' ? 'bg-info/10' :
                      integration.type === 'Database' ? 'bg-warning/10' :
                      'bg-muted'
                    }`}>
                      {integration.type === 'Database' ? <Database className="h-5 w-5" /> :
                       integration.type === 'API' ? <FileJson className="h-5 w-5" /> :
                       <Server className="h-5 w-5" />}
                    </div>
                    <div>
                      <p className="font-medium">{integration.name}</p>
                      <p className="text-sm text-muted-foreground">
                        Last sync: {integration.lastSync} • {integration.records.toLocaleString()} records
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <StatusBadge 
                      variant={
                        integration.status === 'active' ? 'success' :
                        integration.status === 'syncing' ? 'info' :
                        integration.status === 'error' ? 'destructive' :
                        'default'
                      }
                    >
                      {integration.status}
                    </StatusBadge>
                    <Button variant="ghost" size="icon" onClick={() => handleSync(integration)}>
                      <RefreshCw className="h-4 w-4" />
                    </Button>
                    <Button variant="ghost" size="icon" onClick={() => handleConfigure(integration)}>
                      <Settings className="h-4 w-4" />
                    </Button>
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
