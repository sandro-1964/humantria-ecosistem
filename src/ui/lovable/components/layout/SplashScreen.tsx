import React, { useEffect, useState } from 'react';
import { useApp } from '@/contexts/AppContext';
import logoSvg from '@/assets/logo-humantria.svg';
import { cn } from '@/lib/utils';

interface SplashScreenProps {
  onComplete?: () => void;
  minDuration?: number;
}

export function SplashScreen({ onComplete, minDuration = 1500 }: SplashScreenProps) {
  const { theme } = useApp();
  const [isExiting, setIsExiting] = useState(false);
  const [isVisible, setIsVisible] = useState(true);

  useEffect(() => {
    const timer = setTimeout(() => {
      setIsExiting(true);
      setTimeout(() => {
        setIsVisible(false);
        onComplete?.();
      }, 400);
    }, minDuration);

    return () => clearTimeout(timer);
  }, [minDuration, onComplete]);

  if (!isVisible) return null;

  return (
    <div 
      className={cn(
        "fixed inset-0 z-50 flex items-center justify-center bg-background transition-all duration-400",
        isExiting && "opacity-0 scale-105"
      )}
    >
      <div className="flex flex-col items-center gap-8">
        {/* Logo with scale + fade animation */}
        <div className={cn(
          "transform transition-all duration-700 ease-out",
          !isExiting ? "animate-splash-logo" : ""
        )}>
          <img 
            src={logoSvg} 
            alt="HUMANTRÍA" 
            className="h-[58px] md:h-[72px] w-auto"
            style={{ 
              filter: theme === 'dark' ? 'brightness(0) invert(1)' : 'none'
            }}
          />
        </div>
        
        {/* Animated loading bar */}
        <div className="w-48 h-1 rounded-full bg-muted overflow-hidden">
          <div className="h-full bg-primary rounded-full animate-splash-progress" />
        </div>
        
        {/* Loading text with fade */}
        <p className="text-sm text-muted-foreground animate-pulse">
          Carregando plataforma...
        </p>
      </div>
    </div>
  );
}

// Hook para gerenciar splash screen no app
export function useSplashScreen() {
  const [showSplash, setShowSplash] = useState(true);
  
  const handleSplashComplete = () => {
    setShowSplash(false);
  };

  return { showSplash, handleSplashComplete };
}
