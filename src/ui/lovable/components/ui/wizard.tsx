import * as React from "react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Check } from "lucide-react";

interface WizardStep {
  id: string;
  title: string;
  description?: string;
}

interface WizardProps {
  steps: WizardStep[];
  currentStep: number;
  onStepClick?: (index: number) => void;
  className?: string;
}

export function Wizard({ steps, currentStep, onStepClick, className }: WizardProps) {
  return (
    <div className={cn("", className)}>
      <nav aria-label="Progress">
        <ol className="flex items-center">
          {steps.map((step, index) => {
            const isCompleted = index < currentStep;
            const isCurrent = index === currentStep;

            return (
              <li
                key={step.id}
                className={cn("relative flex-1", index !== steps.length - 1 && "pr-8")}
              >
                {index !== steps.length - 1 && (
                  <div
                    className={cn(
                      "absolute right-0 top-4 h-0.5 w-full -translate-y-1/2",
                      isCompleted ? "bg-primary" : "bg-border"
                    )}
                  />
                )}

                <button
                  onClick={() => onStepClick?.(index)}
                  disabled={!onStepClick}
                  className={cn(
                    "group relative flex flex-col items-start",
                    onStepClick && "cursor-pointer"
                  )}
                >
                  <span className="flex h-8 items-center">
                    <span
                      className={cn(
                        "relative z-10 flex h-8 w-8 items-center justify-center rounded-full border-2 text-sm font-medium transition-colors",
                        {
                          "border-primary bg-primary text-primary-foreground": isCompleted,
                          "border-primary bg-card text-primary": isCurrent,
                          "border-border bg-card text-muted-foreground":
                            !isCompleted && !isCurrent,
                        }
                      )}
                    >
                      {isCompleted ? <Check className="h-4 w-4" /> : index + 1}
                    </span>
                  </span>
                  <span className="mt-2 text-sm font-medium text-foreground">{step.title}</span>
                  {step.description && (
                    <span className="mt-0.5 text-xs text-muted-foreground">
                      {step.description}
                    </span>
                  )}
                </button>
              </li>
            );
          })}
        </ol>
      </nav>
    </div>
  );
}

interface WizardActionsProps {
  onPrevious?: () => void;
  onNext?: () => void;
  previousLabel?: string;
  nextLabel?: string;
  previousDisabled?: boolean;
  nextDisabled?: boolean;
  className?: string;
}

export function WizardActions({
  onPrevious,
  onNext,
  previousLabel = "Previous",
  nextLabel = "Next",
  previousDisabled = false,
  nextDisabled = false,
  className,
}: WizardActionsProps) {
  return (
    <div className={cn("flex items-center justify-between", className)}>
      {onPrevious ? (
        <Button variant="outline" onClick={onPrevious} disabled={previousDisabled}>
          {previousLabel}
        </Button>
      ) : (
        <div />
      )}
      {onNext && (
        <Button onClick={onNext} disabled={nextDisabled}>
          {nextLabel}
        </Button>
      )}
    </div>
  );
}
