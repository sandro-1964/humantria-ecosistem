import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { EmptyState } from '@/components/ui/empty-state';
import { AIActions } from '@/components/ui/ai-actions';
import { useApp } from '@/contexts/AppContext';
import { createT } from '@/lib/i18n';
import { UserCheck } from 'lucide-react';

export default function TalentDashboardPage() {
  const { language } = useApp();
  const t = createT(language);

  return (
    <AppLayout>
      <PageHeader
        title={t('talentHeadline')}
        description={t('talentSubheadline')}
        breadcrumbs={[{ label: 'Talent' }, { label: 'Dashboard' }]}
        actions={<AIActions onSuggest={() => {}} onExplain={() => {}} onSimulate={() => {}} />}
      />
      <div className="p-6">
        <EmptyState
          icon={UserCheck}
          title="Talent Dashboard"
          description="Recrutamento e seleção governados. Vagas, candidatos, etapas, ranking e banco de talentos com IA assistiva."
          action={{
            label: t('emptyStateAction'),
            onClick: () => {},
          }}
        />
      </div>
    </AppLayout>
  );
}
