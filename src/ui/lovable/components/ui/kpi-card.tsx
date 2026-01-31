import * as React from "react";
import { cn } from "@/lib/utils";
import { TrendingUp, TrendingDown, Minus, LucideIcon } from "lucide-react";

interface KPICardProps {
  title: string;
  value: string | number;
  change?: number;
  changeLabel?: string;
  icon?: LucideIcon;
  className?: string;
  loading?: boolean;
}

export function KPICard({
  title,
  value,
  change,
  changeLabel,
  icon: Icon,
  className,
  loading = false,
}: KPICardProps) {
  const getTrendIcon = () => {
    if (change === undefined || change === 0) return <Minus className="h-3 w-3" />;
    return change > 0 ? <TrendingUp className="h-3 w-3" /> : <TrendingDown className="h-3 w-3" />;
  };

  const getTrendColor = () => {
    if (change === undefined || change === 0) return "text-kpi-neutral";
    return change > 0 ? "text-kpi-positive" : "text-kpi-negative";
  };

  if (loading) {
    return (
      <div className={cn("rounded-xl border border-border/50 bg-card p-5 shadow-sm", className)}>
        <div className="flex items-center justify-between">
          <div className="h-4 w-24 animate-pulse rounded bg-muted" />
          <div className="h-10 w-10 animate-pulse rounded-xl bg-muted" />
        </div>
        <div className="mt-4 h-8 w-32 animate-pulse rounded bg-muted" />
        <div className="mt-3 h-4 w-20 animate-pulse rounded bg-muted" />
      </div>
    );
  }

  return (
    <div className={cn(
      "rounded-xl border border-border/50 bg-card p-5 shadow-sm",
      "transition-all duration-200 hover:shadow-md hover:border-border",
      className
    )}>
      <div className="flex items-center justify-between">
        <span className="text-sm font-medium text-muted-foreground">{title}</span>
        {Icon && (
          <div className="rounded-xl bg-primary/10 p-2.5">
            <Icon className="h-5 w-5 text-primary" />
          </div>
        )}
      </div>
      <div className="mt-4">
        <span className="text-3xl font-semibold tracking-tight text-foreground">{value}</span>
      </div>
      {change !== undefined && (
        <div className={cn("mt-3 flex items-center gap-1.5 text-sm", getTrendColor())}>
          {getTrendIcon()}
          <span className="font-medium">{Math.abs(change)}%</span>
          {changeLabel && <span className="text-muted-foreground ml-1">{changeLabel}</span>}
        </div>
      )}
    </div>
  );
}
