import * as React from 'react';
import { cn } from '@/lib/utils';

interface DraggableItem {
  id: string;
  content: React.ReactNode;
  colSpan?: 1 | 2 | 3 | 4;
}

interface DraggableGridProps {
  items: DraggableItem[];
  onReorder: (items: DraggableItem[]) => void;
  columns?: 1 | 2 | 3 | 4;
  className?: string;
  storageKey?: string;
}

export function DraggableGrid({ 
  items, 
  onReorder, 
  columns = 4,
  className,
  storageKey
}: DraggableGridProps) {
  const [draggedId, setDraggedId] = React.useState<string | null>(null);
  const [dragOverId, setDragOverId] = React.useState<string | null>(null);

  // Load saved order from localStorage
  React.useEffect(() => {
    if (storageKey) {
      const savedOrder = localStorage.getItem(`humantria-grid-${storageKey}`);
      if (savedOrder) {
        try {
          const orderIds = JSON.parse(savedOrder) as string[];
          const reorderedItems = orderIds
            .map(id => items.find(item => item.id === id))
            .filter(Boolean) as DraggableItem[];
          
          // Add any new items that weren't in saved order
          const newItems = items.filter(item => !orderIds.includes(item.id));
          onReorder([...reorderedItems, ...newItems]);
        } catch {
          // Invalid saved data, ignore
        }
      }
    }
  }, [storageKey]);

  const handleDragStart = (e: React.DragEvent, id: string) => {
    setDraggedId(id);
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/plain', id);
  };

  const handleDragOver = (e: React.DragEvent, id: string) => {
    e.preventDefault();
    if (id !== draggedId) {
      setDragOverId(id);
    }
  };

  const handleDragLeave = () => {
    setDragOverId(null);
  };

  const handleDrop = (e: React.DragEvent, targetId: string) => {
    e.preventDefault();
    
    if (!draggedId || draggedId === targetId) return;

    const newItems = [...items];
    const draggedIndex = newItems.findIndex(item => item.id === draggedId);
    const targetIndex = newItems.findIndex(item => item.id === targetId);

    const [draggedItem] = newItems.splice(draggedIndex, 1);
    newItems.splice(targetIndex, 0, draggedItem);

    onReorder(newItems);

    // Save order to localStorage
    if (storageKey) {
      localStorage.setItem(
        `humantria-grid-${storageKey}`,
        JSON.stringify(newItems.map(item => item.id))
      );
    }

    setDraggedId(null);
    setDragOverId(null);
  };

  const handleDragEnd = () => {
    setDraggedId(null);
    setDragOverId(null);
  };

  const getColSpanClass = (span?: 1 | 2 | 3 | 4) => {
    switch (span) {
      case 1: return 'col-span-1';
      case 2: return 'md:col-span-2';
      case 3: return 'md:col-span-3';
      case 4: return 'md:col-span-4';
      default: return 'col-span-1';
    }
  };

  const gridColsClass = {
    1: 'grid-cols-1',
    2: 'grid-cols-1 md:grid-cols-2',
    3: 'grid-cols-1 md:grid-cols-2 lg:grid-cols-3',
    4: 'grid-cols-1 md:grid-cols-2 lg:grid-cols-4',
  };

  return (
    <div className={cn('grid gap-4', gridColsClass[columns], className)}>
      {items.map((item) => (
        <div
          key={item.id}
          draggable
          onDragStart={(e) => handleDragStart(e, item.id)}
          onDragOver={(e) => handleDragOver(e, item.id)}
          onDragLeave={handleDragLeave}
          onDrop={(e) => handleDrop(e, item.id)}
          onDragEnd={handleDragEnd}
          className={cn(
            'transition-all duration-200',
            getColSpanClass(item.colSpan),
            draggedId === item.id && 'opacity-50 scale-[0.98]',
            dragOverId === item.id && 'ring-2 ring-primary ring-offset-2 ring-offset-background rounded-lg'
          )}
        >
          {item.content}
        </div>
      ))}
    </div>
  );
}
