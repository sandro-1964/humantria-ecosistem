import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Book, FileText, Video, ExternalLink, Search, ChevronRight } from 'lucide-react';

const docCategories = [
  { 
    title: 'Getting Started', 
    icon: Book, 
    count: 12,
    items: ['Platform Overview', 'Quick Start Guide', 'First Steps']
  },
  { 
    title: 'User Guides', 
    icon: FileText, 
    count: 45,
    items: ['Navigation', 'Dashboard Customization', 'Reports']
  },
  { 
    title: 'Video Tutorials', 
    icon: Video, 
    count: 18,
    items: ['Introduction', 'Advanced Features', 'Best Practices']
  },
  { 
    title: 'API Reference', 
    icon: ExternalLink, 
    count: 67,
    items: ['Authentication', 'Endpoints', 'Webhooks']
  },
];

export default function DocumentationPage() {
  return (
    <AppLayout>
      <PageHeader 
        title="Documentation" 
        description="Platform guides, tutorials, and API reference"
        breadcrumbs={[{ label: 'Tools', href: '/tools' }, { label: 'Documentation' }]}
      />
      
      <div className="p-6 space-y-6">
        {/* Search */}
        <div className="relative max-w-xl">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input 
            placeholder="Search documentation..." 
            className="pl-10"
          />
        </div>

        {/* Categories */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {docCategories.map((category) => (
            <Card key={category.title} className="cursor-pointer hover:shadow-card-hover transition-shadow">
              <CardHeader className="pb-2">
                <div className="flex items-center justify-between">
                  <div className="p-2 rounded-md bg-primary/10">
                    <category.icon className="h-5 w-5 text-primary" />
                  </div>
                  <span className="text-xs text-muted-foreground">{category.count} articles</span>
                </div>
                <CardTitle className="text-base mt-2">{category.title}</CardTitle>
              </CardHeader>
              <CardContent>
                <ul className="space-y-1">
                  {category.items.map((item) => (
                    <li key={item} className="flex items-center text-sm text-muted-foreground hover:text-foreground cursor-pointer">
                      <ChevronRight className="h-3 w-3 mr-1" />
                      {item}
                    </li>
                  ))}
                </ul>
              </CardContent>
            </Card>
          ))}
        </div>

        {/* Recent Articles */}
        <Card>
          <CardHeader>
            <CardTitle>Popular Articles</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              {['How to configure SSO authentication', 'Understanding RLS policies', 'Setting up webhooks', 'Dashboard widget customization', 'API rate limits explained'].map((article) => (
                <div key={article} className="flex items-center justify-between p-3 hover:bg-muted/50 rounded-lg cursor-pointer transition-colors">
                  <div className="flex items-center gap-3">
                    <FileText className="h-4 w-4 text-muted-foreground" />
                    <span className="text-sm">{article}</span>
                  </div>
                  <ExternalLink className="h-4 w-4 text-muted-foreground" />
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </AppLayout>
  );
}
