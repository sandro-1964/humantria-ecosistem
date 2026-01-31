import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { EmptyState } from '@/components/ui/empty-state';
import { AIActions } from '@/components/ui/ai-actions';
import { useApp } from '@/contexts/AppContext';
import { createT } from '@/lib/i18n';
import { Layers } from 'lucide-react';

export default function SynergyDashboardPage() {
  const { language } = useApp();
  const t = createT(language);

  return (
    <AppLayout>
      <PageHeader
        title={t('synergyHeadline')}
        description={t('synergySubheadline')}
        breadcrumbs={[{ label: 'Synergy' }, { label: 'Dashboard' }]}
        actions={<AIActions onSuggest={() => {}} onExplain={() => {}} onSimulate={() => {}} />}
      />
      <div className="p-6">
        <EmptyState
          icon={Layers}
          title="Synergy Dashboard"
          description="Cargos, carreira e recompensas. Arquitetura de cargos, competências e estrutura de remuneração."
          action={{
            label: t('emptyStateAction'),
            onClick: () => {},
          }}
        />
      </div>
    </AppLayout>
  );
}
