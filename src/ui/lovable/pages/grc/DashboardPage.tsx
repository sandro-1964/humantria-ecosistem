import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { EmptyState } from '@/components/ui/empty-state';
import { AIActions } from '@/components/ui/ai-actions';
import { useApp } from '@/contexts/AppContext';
import { createT } from '@/lib/i18n';
import { Shield } from 'lucide-react';

export default function GRCDashboardPage() {
  const { language } = useApp();
  const t = createT(language);

  return (
    <AppLayout>
      <PageHeader
        title={t('grcHeadline')}
        description={t('grcSubheadline')}
        breadcrumbs={[{ label: 'GRC' }, { label: 'Dashboard' }]}
        actions={<AIActions onSuggest={() => {}} onExplain={() => {}} onSimulate={() => {}} />}
      />
      <div className="p-6">
        <EmptyState
          icon={Shield}
          title="GRC Dashboard"
          description="Governança, risco e compliance. Controles, políticas, auditorias e planos de ação."
          action={{
            label: t('emptyStateAction'),
            onClick: () => {},
          }}
        />
      </div>
    </AppLayout>
  );
}
