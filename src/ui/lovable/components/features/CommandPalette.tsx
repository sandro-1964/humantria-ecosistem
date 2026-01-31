import React from 'react';
import { useApp } from '@/contexts/AppContext';
import { useNavigate } from 'react-router-dom';
import {
  CommandDialog,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
  CommandSeparator,
} from '@/components/ui/command';
import {
  Home,
  LineChart,
  Users,
  Database,
  GitBranch,
  Settings,
  Search,
  FileText,
  Compass,
  HelpCircle,
  Bell,
  Moon,
  Sun,
  Languages,
} from 'lucide-react';

export function CommandPalette() {
  const { commandPaletteOpen, setCommandPaletteOpen, theme, setTheme } = useApp();
  const navigate = useNavigate();

  const handleSelect = (value: string) => {
    setCommandPaletteOpen(false);
    
    if (value.startsWith('/')) {
      navigate(value);
    } else if (value === 'toggle-theme') {
      setTheme(theme === 'light' ? 'dark' : 'light');
    }
  };

  return (
    <CommandDialog open={commandPaletteOpen} onOpenChange={setCommandPaletteOpen}>
      <CommandInput placeholder="Type a command or search..." />
      <CommandList>
        <CommandEmpty>No results found.</CommandEmpty>

        <CommandGroup heading="Navigation">
          <CommandItem value="/" onSelect={handleSelect}>
            <Home className="mr-2 h-4 w-4" />
            Home
          </CommandItem>
          <CommandItem value="/decision-hub" onSelect={handleSelect}>
            <Compass className="mr-2 h-4 w-4" />
            Decision Hub
          </CommandItem>
          <CommandItem value="/strategy/dashboard" onSelect={handleSelect}>
            <LineChart className="mr-2 h-4 w-4" />
            Strategy Dashboard
          </CommandItem>
          <CommandItem value="/core/people" onSelect={handleSelect}>
            <Users className="mr-2 h-4 w-4" />
            People
          </CommandItem>
          <CommandItem value="/core/organization" onSelect={handleSelect}>
            <Database className="mr-2 h-4 w-4" />
            Organization
          </CommandItem>
          <CommandItem value="/bridges/events" onSelect={handleSelect}>
            <GitBranch className="mr-2 h-4 w-4" />
            Event Monitor
          </CommandItem>
        </CommandGroup>

        <CommandSeparator />

        <CommandGroup heading="Tools">
          <CommandItem value="/tools/sandbox" onSelect={handleSelect}>
            <Search className="mr-2 h-4 w-4" />
            Sandbox
          </CommandItem>
          <CommandItem value="/tools/import" onSelect={handleSelect}>
            <FileText className="mr-2 h-4 w-4" />
            Import Center
          </CommandItem>
          <CommandItem value="/tools/export" onSelect={handleSelect}>
            <FileText className="mr-2 h-4 w-4" />
            Export Center
          </CommandItem>
          <CommandItem value="/tools/notifications" onSelect={handleSelect}>
            <Bell className="mr-2 h-4 w-4" />
            Notifications
          </CommandItem>
          <CommandItem value="/tools/help" onSelect={handleSelect}>
            <HelpCircle className="mr-2 h-4 w-4" />
            Help Center
          </CommandItem>
        </CommandGroup>

        <CommandSeparator />

        <CommandGroup heading="Actions">
          <CommandItem value="toggle-theme" onSelect={handleSelect}>
            {theme === 'light' ? (
              <Moon className="mr-2 h-4 w-4" />
            ) : (
              <Sun className="mr-2 h-4 w-4" />
            )}
            Toggle theme
          </CommandItem>
          <CommandItem value="/settings" onSelect={handleSelect}>
            <Settings className="mr-2 h-4 w-4" />
            Settings
          </CommandItem>
        </CommandGroup>
      </CommandList>
    </CommandDialog>
  );
}
