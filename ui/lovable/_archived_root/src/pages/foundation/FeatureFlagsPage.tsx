import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { DataTable, Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { Switch } from '@/components/ui/switch';
import { Plus, Flag } from 'lucide-react';

interface FeatureFlag {
  id: string;
  name: string;
  key: string;
  enabled: boolean;
  environment: 'production' | 'staging' | 'development';
  rollout: number;
  updated: string;
}

const flags: FeatureFlag[] = [
  { id: '1', name: 'New Dashboard', key: 'feature.new_dashboard', enabled: true, environment: 'production', rollout: 100, updated: '2024-01-10' },
  { id: '2', name: 'AI Suggestions', key: 'feature.ai_suggestions', enabled: true, environment: 'production', rollout: 50, updated: '2024-01-12' },
  { id: '3', name: 'Dark Mode V2', key: 'feature.dark_mode_v2', enabled: false, environment: 'staging', rollout: 0, updated: '2024-01-08' },
  { id: '4', name: 'Export PDF', key: 'feature.export_pdf', enabled: true, environment: 'development', rollout: 25, updated: '2024-01-14' },
];

const columns: Column<FeatureFlag>[] = [
  {
    key: 'name',
    header: 'Feature',
    cell: (row) => (
      <div className="flex items-center gap-2">
        <Flag className="h-4 w-4 text-muted-foreground" />
        <div>
          <p className="font-medium">{row.name}</p>
          <p className="text-xs text-muted-foreground font-mono">{row.key}</p>
        </div>
      </div>
    ),
  },
  {
    key: 'enabled',
    header: 'Status',
    cell: (row) => <Switch checked={row.enabled} />,
  },
  {
    key: 'environment',
    header: 'Environment',
    cell: (row) => (
      <StatusBadge
        variant={
          row.environment === 'production' ? 'success' : row.environment === 'staging' ? 'warning' : 'info'
        }
      >
        {row.environment}
      </StatusBadge>
    ),
  },
  {
    key: 'rollout',
    header: 'Rollout',
    cell: (row) => <span>{row.rollout}%</span>,
  },
  { key: 'updated', header: 'Last Updated' },
];

export default function FeatureFlagsPage() {
  return (
    <AppLayout>
      <PageHeader
        title="Feature Flags"
        description="Control feature rollouts and experiments"
        breadcrumbs={[
          { label: 'Foundation', href: '/foundation' },
          { label: 'Feature Flags' },
        ]}
        actions={
          <div className="flex items-center gap-2">
            <AIActions onSuggest={() => {}} />
            <Button className="gap-2">
              <Plus className="h-4 w-4" />
              Create Flag
            </Button>
          </div>
        }
      />
      <div className="p-6">
        <DataTable columns={columns} data={flags} />
      </div>
    </AppLayout>
  );
}
