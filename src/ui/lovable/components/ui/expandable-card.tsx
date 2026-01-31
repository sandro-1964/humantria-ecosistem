import * as React from 'react';
import { cn } from '@/lib/utils';
import { ChevronDown, GripVertical } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from './card';

interface ExpandableCardProps extends React.HTMLAttributes<HTMLDivElement> {
  title: string;
  subtitle?: string;
  icon?: React.ReactNode;
  defaultExpanded?: boolean;
  draggable?: boolean;
  onDragStart?: (e: React.DragEvent) => void;
  onDragEnd?: (e: React.DragEvent) => void;
  actions?: React.ReactNode;
}

const ExpandableCard = React.forwardRef<HTMLDivElement, ExpandableCardProps>(
  ({ 
    className, 
    title, 
    subtitle,
    icon,
    defaultExpanded = true, 
    draggable = false,
    onDragStart,
    onDragEnd,
    actions,
    children, 
    ...props 
  }, ref) => {
    const [isExpanded, setIsExpanded] = React.useState(defaultExpanded);

    return (
      <Card
        ref={ref}
        className={cn(
          'transition-all duration-200',
          draggable && 'cursor-move',
          className
        )}
        draggable={draggable}
        onDragStart={onDragStart}
        onDragEnd={onDragEnd}
        {...props}
      >
        <CardHeader 
          className="flex flex-row items-center justify-between space-y-0 pb-2 cursor-pointer select-none"
          onClick={() => setIsExpanded(!isExpanded)}
        >
          <div className="flex items-center gap-3">
            {draggable && (
              <GripVertical 
                className="h-4 w-4 text-muted-foreground opacity-50 hover:opacity-100 transition-opacity" 
                onClick={(e) => e.stopPropagation()}
              />
            )}
            {icon && (
              <div className="flex h-8 w-8 items-center justify-center rounded-md bg-primary/10 text-primary">
                {icon}
              </div>
            )}
            <div>
              <CardTitle className="text-base font-medium">{title}</CardTitle>
              {subtitle && (
                <p className="text-xs text-muted-foreground mt-0.5">{subtitle}</p>
              )}
            </div>
          </div>
          <div className="flex items-center gap-2">
            {actions && (
              <div onClick={(e) => e.stopPropagation()}>
                {actions}
              </div>
            )}
            <ChevronDown 
              className={cn(
                'h-4 w-4 text-muted-foreground transition-transform duration-200',
                isExpanded && 'rotate-180'
              )}
            />
          </div>
        </CardHeader>
        <div
          className={cn(
            'overflow-hidden transition-all duration-200',
            isExpanded ? 'max-h-[2000px] opacity-100' : 'max-h-0 opacity-0'
          )}
        >
          <CardContent>{children}</CardContent>
        </div>
      </Card>
    );
  }
);

ExpandableCard.displayName = 'ExpandableCard';

export { ExpandableCard };
