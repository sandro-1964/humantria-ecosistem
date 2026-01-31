import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { AIActions } from '@/components/ui/ai-actions';
import { Brain, Sparkles, TrendingUp, Target } from 'lucide-react';

const insights = [
  { id: '1', title: 'Budget Optimization', description: 'AI suggests reallocating 12% of marketing budget to sales for higher ROI', icon: TrendingUp, confidence: 87 },
  { id: '2', title: 'Headcount Prediction', description: 'Based on growth trajectory, recommend 15 additional engineers by Q3', icon: Target, confidence: 92 },
  { id: '3', title: 'Risk Detection', description: 'Identified potential supply chain disruption risk in 3 vendors', icon: Sparkles, confidence: 78 },
];

export default function AIInsightsPage() {
  return (
    <AppLayout>
      <PageHeader title="AI Insights" description="AI-powered suggestions and simulations" breadcrumbs={[{ label: 'Strategy', href: '/strategy' }, { label: 'AI Insights' }]} actions={<AIActions onSuggest={() => {}} onExplain={() => {}} onSimulate={() => {}} />} />
      <div className="p-6 space-y-4">
        {insights.map((i) => (
          <Card key={i.id}>
            <CardContent className="flex items-start gap-4 pt-6">
              <div className="p-3 rounded-lg bg-primary/10"><i.icon className="h-6 w-6 text-primary" /></div>
              <div className="flex-1"><h3 className="font-semibold">{i.title}</h3><p className="text-sm text-muted-foreground mt-1">{i.description}</p></div>
              <div className="text-right"><p className="text-sm text-muted-foreground">Confidence</p><p className="text-lg font-semibold text-primary">{i.confidence}%</p></div>
            </CardContent>
          </Card>
        ))}
      </div>
    </AppLayout>
  );
}
