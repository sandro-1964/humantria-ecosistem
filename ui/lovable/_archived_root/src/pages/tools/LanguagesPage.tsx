import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { StatusBadge } from '@/components/ui/status-badge';
import { useApp } from '@/contexts/AppContext';
import { useToast } from '@/hooks/use-toast';
import { Globe, Check } from 'lucide-react';

const languages = [
  { code: 'pt', name: 'Português', region: 'Brasil', coverage: 100, status: 'complete' },
  { code: 'en', name: 'English', region: 'US', coverage: 100, status: 'complete' },
  { code: 'es', name: 'Español', region: 'España', coverage: 95, status: 'partial' },
];

export default function LanguagesPage() {
  const { language, setLanguage } = useApp();
  const { toast } = useToast();

  const handleLanguageChange = (code: 'pt' | 'en' | 'es') => {
    setLanguage(code);
    toast({
      title: "Language Changed",
      description: `Interface language set to ${languages.find(l => l.code === code)?.name}`,
    });
  };

  return (
    <AppLayout>
      <PageHeader 
        title="Languages (i18n)" 
        description="Manage interface language and translations"
        breadcrumbs={[{ label: 'Tools', href: '/tools' }, { label: 'Languages' }]}
      />
      
      <div className="p-6 space-y-6">
        <Card>
          <CardHeader>
            <CardTitle>Available Languages</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {languages.map((lang) => (
                <div 
                  key={lang.code}
                  className={`flex items-center justify-between p-4 border rounded-lg transition-colors ${
                    language === lang.code ? 'border-primary bg-primary/5' : 'hover:bg-muted/30'
                  }`}
                >
                  <div className="flex items-center gap-4">
                    <div className="p-2 rounded-md bg-muted">
                      <Globe className="h-5 w-5" />
                    </div>
                    <div>
                      <p className="font-medium">{lang.name}</p>
                      <p className="text-sm text-muted-foreground">{lang.region}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-4">
                    <div className="text-right">
                      <p className="text-sm font-medium">{lang.coverage}%</p>
                      <p className="text-xs text-muted-foreground">coverage</p>
                    </div>
                    <StatusBadge variant={lang.status === 'complete' ? 'success' : 'warning'}>
                      {lang.status}
                    </StatusBadge>
                    {language === lang.code ? (
                      <div className="w-20 flex justify-center">
                        <Check className="h-5 w-5 text-primary" />
                      </div>
                    ) : (
                      <Button 
                        variant="outline" 
                        size="sm"
                        onClick={() => handleLanguageChange(lang.code as 'pt' | 'en' | 'es')}
                      >
                        Select
                      </Button>
                    )}
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
