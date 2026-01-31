import * as React from "react";
import { cn } from "@/lib/utils";
import { LucideIcon, Circle } from "lucide-react";

interface TimelineItem {
  id: string;
  title: string;
  description?: string;
  timestamp: string;
  icon?: LucideIcon;
  status?: "completed" | "current" | "pending";
}

interface TimelineProps {
  items: TimelineItem[];
  className?: string;
}

export function Timeline({ items, className }: TimelineProps) {
  return (
    <div className={cn("relative", className)}>
      {items.map((item, index) => {
        const Icon = item.icon || Circle;
        const isLast = index === items.length - 1;

        return (
          <div key={item.id} className="relative flex gap-4 pb-6">
            {/* Line */}
            {!isLast && (
              <div
                className={cn(
                  "absolute left-[15px] top-8 h-full w-px",
                  item.status === "completed" ? "bg-primary" : "bg-border"
                )}
              />
            )}

            {/* Icon */}
            <div
              className={cn(
                "relative z-10 flex h-8 w-8 shrink-0 items-center justify-center rounded-full border-2",
                {
                  "border-primary bg-primary text-primary-foreground":
                    item.status === "completed" || item.status === "current",
                  "border-border bg-card text-muted-foreground": item.status === "pending",
                }
              )}
            >
              <Icon className="h-4 w-4" />
            </div>

            {/* Content */}
            <div className="flex-1 pt-1">
              <p className="font-medium text-foreground">{item.title}</p>
              {item.description && (
                <p className="mt-1 text-sm text-muted-foreground">{item.description}</p>
              )}
              <p className="mt-1 text-xs text-muted-foreground">{item.timestamp}</p>
            </div>
          </div>
        );
      })}
    </div>
  );
}
