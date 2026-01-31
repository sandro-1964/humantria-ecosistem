import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { EmptyState } from '@/components/ui/empty-state';
import { AIActions } from '@/components/ui/ai-actions';
import { useApp } from '@/contexts/AppContext';
import { createT } from '@/lib/i18n';
import { Clock } from 'lucide-react';

export default function ChronosDashboardPage() {
  const { language } = useApp();
  const t = createT(language);

  return (
    <AppLayout>
      <PageHeader
        title={t('chronosHeadline')}
        description={t('chronosSubheadline')}
        breadcrumbs={[{ label: 'Chronos' }, { label: 'Dashboard' }]}
        actions={<AIActions onSuggest={() => {}} onExplain={() => {}} onSimulate={() => {}} />}
      />
      <div className="p-6">
        <EmptyState
          icon={Clock}
          title="Chronos Dashboard"
          description="Tempo, capacidade e jornada de trabalho. Planejamento temporal, agendas e alocação."
          action={{
            label: t('emptyStateAction'),
            onClick: () => {},
          }}
        />
      </div>
    </AppLayout>
  );
}
