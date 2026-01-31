import * as React from 'react';
import { cn } from '@/lib/utils';
import { Brain, Sparkles } from 'lucide-react';
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from '@/components/ui/tooltip';

interface AIBadgeProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: 'default' | 'insight' | 'suggestion' | 'generated';
  tooltip?: string;
}

const AIBadge = React.forwardRef<HTMLDivElement, AIBadgeProps>(
  ({ variant = 'default', tooltip, className, children, ...props }, ref) => {
    const variants = {
      default: 'bg-teal/10 text-teal border-teal/20',
      insight: 'bg-ai/10 text-ai border-ai/20',
      suggestion: 'bg-teal/10 text-teal border-teal/20',
      generated: 'bg-indigo/10 text-indigo border-indigo/20',
    };

    const icons = {
      default: Brain,
      insight: Sparkles,
      suggestion: Sparkles,
      generated: Brain,
    };

    const Icon = icons[variant];

    const badge = (
      <div
        ref={ref}
        className={cn(
          'inline-flex items-center gap-1 px-2 py-0.5 text-xs font-medium rounded-full border',
          variants[variant],
          className
        )}
        {...props}
      >
        <Icon className="h-3 w-3" />
        {children || 'AI'}
      </div>
    );

    if (tooltip) {
      return (
        <Tooltip>
          <TooltipTrigger asChild>{badge}</TooltipTrigger>
          <TooltipContent>{tooltip}</TooltipContent>
        </Tooltip>
      );
    }

    return badge;
  }
);

AIBadge.displayName = 'AIBadge';

export { AIBadge };
