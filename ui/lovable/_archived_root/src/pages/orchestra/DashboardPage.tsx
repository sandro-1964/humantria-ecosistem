import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { EmptyState } from '@/components/ui/empty-state';
import { AIActions } from '@/components/ui/ai-actions';
import { useApp } from '@/contexts/AppContext';
import { createT } from '@/lib/i18n';
import { Music2 } from 'lucide-react';

export default function OrchestraDashboardPage() {
  const { language } = useApp();
  const t = createT(language);

  return (
    <AppLayout>
      <PageHeader
        title={t('orchestraHeadline')}
        description={t('orchestraSubheadline')}
        breadcrumbs={[{ label: 'Orchestra' }, { label: 'Dashboard' }]}
        actions={<AIActions onSuggest={() => {}} onExplain={() => {}} onSimulate={() => {}} />}
      />
      <div className="p-6">
        <EmptyState
          icon={Music2}
          title="Orchestra Dashboard"
          description="Orquestração do modelo de RH. HRBP, SSC, CoEs, comunicação e mudanças."
          action={{
            label: t('emptyStateAction'),
            onClick: () => {},
          }}
        />
      </div>
    </AppLayout>
  );
}
