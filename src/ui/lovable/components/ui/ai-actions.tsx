import * as React from "react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Sparkles, MessageSquare, Play, Lightbulb, Brain } from "lucide-react";
import { useApp } from "@/contexts/AppContext";
import { createT } from "@/lib/i18n";
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from "@/components/ui/tooltip";

interface AIActionsProps extends React.HTMLAttributes<HTMLDivElement> {
  onSuggest?: () => void;
  onExplain?: () => void;
  onSimulate?: () => void;
  onAnalyze?: () => void;
  disabled?: boolean;
  compact?: boolean;
}

const AIActions = React.forwardRef<HTMLDivElement, AIActionsProps>(
  ({ onSuggest, onExplain, onSimulate, onAnalyze, disabled = false, compact = false, className, ...props }, ref) => {
    const { language } = useApp();
    const t = createT(language);

    const buttonClass = "gap-1.5 border-teal/30 text-teal hover:bg-teal/10 hover:text-teal hover:border-teal/50";
    const iconClass = "text-teal";

    if (compact) {
      return (
        <div ref={ref} className={cn("flex items-center gap-1", className)} {...props}>
          {onSuggest && (
            <Tooltip>
              <TooltipTrigger asChild>
                <Button
                  variant="outline"
                  size="icon"
                  onClick={onSuggest}
                  disabled={disabled}
                  className={cn("h-8 w-8", buttonClass)}
                >
                  <Sparkles className={cn("h-4 w-4", iconClass)} />
                </Button>
              </TooltipTrigger>
              <TooltipContent>{t('aiSuggest')}</TooltipContent>
            </Tooltip>
          )}
          {onAnalyze && (
            <Tooltip>
              <TooltipTrigger asChild>
                <Button
                  variant="outline"
                  size="icon"
                  onClick={onAnalyze}
                  disabled={disabled}
                  className={cn("h-8 w-8", buttonClass)}
                >
                  <Lightbulb className={cn("h-4 w-4", iconClass)} />
                </Button>
              </TooltipTrigger>
              <TooltipContent>{t('aiAnalyze')}</TooltipContent>
            </Tooltip>
          )}
          {onExplain && (
            <Tooltip>
              <TooltipTrigger asChild>
                <Button
                  variant="outline"
                  size="icon"
                  onClick={onExplain}
                  disabled={disabled}
                  className={cn("h-8 w-8", buttonClass)}
                >
                  <MessageSquare className={cn("h-4 w-4", iconClass)} />
                </Button>
              </TooltipTrigger>
              <TooltipContent>{t('aiExplain')}</TooltipContent>
            </Tooltip>
          )}
          {onSimulate && (
            <Tooltip>
              <TooltipTrigger asChild>
                <Button
                  variant="outline"
                  size="icon"
                  onClick={onSimulate}
                  disabled={disabled}
                  className={cn("h-8 w-8", buttonClass)}
                >
                  <Play className={cn("h-4 w-4", iconClass)} />
                </Button>
              </TooltipTrigger>
              <TooltipContent>{t('aiSimulate')}</TooltipContent>
            </Tooltip>
          )}
        </div>
      );
    }

    return (
      <div ref={ref} className={cn("flex items-center gap-2", className)} {...props}>
        <div className="flex items-center gap-1 px-2 py-1 rounded-md bg-teal/10 border border-teal/20 mr-1">
          <Brain className="h-3.5 w-3.5 text-teal" />
          <span className="text-xs font-medium text-teal">AI</span>
        </div>
        {onSuggest && (
          <Button
            variant="outline"
            size="sm"
            onClick={onSuggest}
            disabled={disabled}
            className={cn("gap-1.5", buttonClass)}
          >
            <Sparkles className={cn("h-3.5 w-3.5", iconClass)} />
            {t('aiSuggest')}
          </Button>
        )}
        {onAnalyze && (
          <Button
            variant="outline"
            size="sm"
            onClick={onAnalyze}
            disabled={disabled}
            className={cn("gap-1.5", buttonClass)}
          >
            <Lightbulb className={cn("h-3.5 w-3.5", iconClass)} />
            {t('aiAnalyze')}
          </Button>
        )}
        {onExplain && (
          <Button
            variant="outline"
            size="sm"
            onClick={onExplain}
            disabled={disabled}
            className={cn("gap-1.5", buttonClass)}
          >
            <MessageSquare className={cn("h-3.5 w-3.5", iconClass)} />
            {t('aiExplain')}
          </Button>
        )}
        {onSimulate && (
          <Button
            variant="outline"
            size="sm"
            onClick={onSimulate}
            disabled={disabled}
            className={cn("gap-1.5", buttonClass)}
          >
            <Play className={cn("h-3.5 w-3.5", iconClass)} />
            {t('aiSimulate')}
          </Button>
        )}
      </div>
    );
  }
);

AIActions.displayName = "AIActions";

export { AIActions };
