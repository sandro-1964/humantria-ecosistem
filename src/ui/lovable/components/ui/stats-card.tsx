import * as React from "react";
import { cn } from "@/lib/utils";
import { LucideIcon } from "lucide-react";

interface Stat {
  label: string;
  value: string | number;
}

interface StatsCardProps {
  title: string;
  icon?: LucideIcon;
  stats: Stat[];
  className?: string;
  loading?: boolean;
}

export function StatsCard({
  title,
  icon: Icon,
  stats,
  className,
  loading = false,
}: StatsCardProps) {
  if (loading) {
    return (
      <div className={cn("rounded-lg border bg-card p-4 shadow-card", className)}>
        <div className="flex items-center gap-2">
          <div className="h-5 w-5 animate-pulse rounded bg-skeleton" />
          <div className="h-4 w-24 animate-pulse rounded bg-skeleton" />
        </div>
        <div className="mt-4 grid grid-cols-2 gap-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i}>
              <div className="h-3 w-16 animate-pulse rounded bg-skeleton" />
              <div className="mt-1 h-6 w-12 animate-pulse rounded bg-skeleton" />
            </div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className={cn("rounded-lg border bg-card p-4 shadow-card", className)}>
      <div className="flex items-center gap-2">
        {Icon && <Icon className="h-5 w-5 text-muted-foreground" />}
        <h3 className="font-medium text-foreground">{title}</h3>
      </div>
      <div className="mt-4 grid grid-cols-2 gap-4">
        {stats.map((stat, index) => (
          <div key={index}>
            <p className="text-xs text-muted-foreground">{stat.label}</p>
            <p className="mt-0.5 text-lg font-semibold text-foreground">{stat.value}</p>
          </div>
        ))}
      </div>
    </div>
  );
}
