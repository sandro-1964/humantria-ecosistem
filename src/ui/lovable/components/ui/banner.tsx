import * as React from "react";
import { cn } from "@/lib/utils";
import { cva, type VariantProps } from "class-variance-authority";
import { X, AlertCircle, CheckCircle, AlertTriangle, Info } from "lucide-react";
import { Button } from "@/components/ui/button";

const bannerVariants = cva(
  "relative flex items-center gap-3 rounded-lg border px-4 py-3",
  {
    variants: {
      variant: {
        default: "border-border bg-muted text-foreground",
        info: "border-info/30 bg-info/10 text-info",
        success: "border-success/30 bg-success/10 text-success",
        warning: "border-warning/30 bg-warning/10 text-warning",
        destructive: "border-destructive/30 bg-destructive/10 text-destructive",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  }
);

interface BannerProps extends VariantProps<typeof bannerVariants> {
  children: React.ReactNode;
  onClose?: () => void;
  className?: string;
}

const iconMap = {
  default: Info,
  info: Info,
  success: CheckCircle,
  warning: AlertTriangle,
  destructive: AlertCircle,
};

export function Banner({ children, variant = "default", onClose, className }: BannerProps) {
  const Icon = iconMap[variant || "default"];

  return (
    <div className={cn(bannerVariants({ variant }), className)}>
      <Icon className="h-5 w-5 shrink-0" />
      <div className="flex-1 text-sm">{children}</div>
      {onClose && (
        <Button
          variant="ghost"
          size="sm"
          onClick={onClose}
          className="h-6 w-6 p-0 hover:bg-transparent"
        >
          <X className="h-4 w-4" />
        </Button>
      )}
    </div>
  );
}
