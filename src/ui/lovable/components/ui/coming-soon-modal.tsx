import React from 'react';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Construction, ArrowRight, Database, Loader2, AlertCircle, CheckCircle } from 'lucide-react';

interface ComingSoonModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  feature: {
    title: string;
    description: string;
    dataSource?: string;
    states?: ('loading' | 'empty' | 'error' | 'success')[];
  };
}

const stateConfig = {
  loading: { icon: Loader2, label: 'Carregando', color: 'bg-info/10 text-info' },
  empty: { icon: Database, label: 'Sem dados', color: 'bg-muted text-muted-foreground' },
  error: { icon: AlertCircle, label: 'Erro', color: 'bg-destructive/10 text-destructive' },
  success: { icon: CheckCircle, label: 'Sucesso', color: 'bg-success/10 text-success' },
};

export function ComingSoonModal({ open, onOpenChange, feature }: ComingSoonModalProps) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader className="text-left">
          <div className="flex items-center gap-3 mb-2">
            <div className="h-10 w-10 rounded-xl bg-warning/10 flex items-center justify-center">
              <Construction className="h-5 w-5 text-warning" />
            </div>
            <Badge variant="outline" className="text-xs">
              Em preparação
            </Badge>
          </div>
          <DialogTitle className="text-xl">{feature.title}</DialogTitle>
          <DialogDescription className="text-muted-foreground">
            {feature.description}
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4 py-4">
          {/* Data Source */}
          {feature.dataSource && (
            <div className="p-3 rounded-lg bg-muted/50 border border-border/50">
              <div className="text-xs text-muted-foreground mb-1">Fonte de dados</div>
              <div className="text-sm font-medium flex items-center gap-2">
                <Database className="h-4 w-4 text-primary" />
                {feature.dataSource}
              </div>
            </div>
          )}

          {/* States Preview */}
          {feature.states && feature.states.length > 0 && (
            <div>
              <div className="text-xs text-muted-foreground mb-2">Estados demonstráveis</div>
              <div className="flex flex-wrap gap-2">
                {feature.states.map((state) => {
                  const config = stateConfig[state];
                  const Icon = config.icon;
                  return (
                    <Badge 
                      key={state} 
                      variant="secondary" 
                      className={`${config.color} gap-1.5`}
                    >
                      <Icon className={`h-3 w-3 ${state === 'loading' ? 'animate-spin' : ''}`} />
                      {config.label}
                    </Badge>
                  );
                })}
              </div>
            </div>
          )}

          {/* Integration Notice */}
          <div className="p-3 rounded-lg bg-indigo/5 border border-indigo/20">
            <div className="flex items-start gap-2">
              <ArrowRight className="h-4 w-4 text-indigo mt-0.5 shrink-0" />
              <div className="text-sm text-muted-foreground">
                <span className="font-medium text-foreground">Backend será integrado no Cursor.</span>
                <br />
                Esta funcionalidade está em desenvolvimento e será conectada aos dados reais em breve.
              </div>
            </div>
          </div>
        </div>

        <div className="flex justify-end">
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            Entendi
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}

// Hook for easy usage
export function useComingSoon() {
  const [modalState, setModalState] = React.useState<{
    open: boolean;
    feature: ComingSoonModalProps['feature'];
  }>({
    open: false,
    feature: { title: '', description: '' },
  });

  const showComingSoon = (feature: ComingSoonModalProps['feature']) => {
    setModalState({ open: true, feature });
  };

  const hideComingSoon = () => {
    setModalState(prev => ({ ...prev, open: false }));
  };

  return {
    modalState,
    showComingSoon,
    hideComingSoon,
    ComingSoonModal: () => (
      <ComingSoonModal
        open={modalState.open}
        onOpenChange={hideComingSoon}
        feature={modalState.feature}
      />
    ),
  };
}
