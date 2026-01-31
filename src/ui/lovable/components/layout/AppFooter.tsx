import React from 'react';
import { cn } from '@/lib/utils';
import { CheckCircle, AlertCircle, Clock } from 'lucide-react';

export function AppFooter() {
  const fingerprint = React.useMemo(() => {
    return Math.random().toString(36).substring(2, 10).toUpperCase();
  }, []);

  return (
    <footer className="h-8 border-t bg-card px-4 flex items-center justify-between text-xs text-muted-foreground shrink-0">
      <div className="flex items-center gap-4">
        <div className="flex items-center gap-1.5">
          <span className="text-muted-foreground/70">Environment:</span>
          <span className="font-medium px-1.5 py-0.5 rounded bg-info/10 text-info">Production</span>
        </div>
        <div className="flex items-center gap-1.5">
          <span className="text-muted-foreground/70">Version:</span>
          <span className="font-mono">v2.4.1</span>
        </div>
      </div>

      <div className="flex items-center gap-4">
        <div className="flex items-center gap-1.5">
          <span className="text-muted-foreground/70">Fingerprint:</span>
          <span className="font-mono">{fingerprint}</span>
        </div>
        <div className="flex items-center gap-1.5">
          <CheckCircle className="h-3 w-3 text-success" />
          <span>All systems operational</span>
        </div>
      </div>
    </footer>
  );
}
