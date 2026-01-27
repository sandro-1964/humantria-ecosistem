/**
 * HUMANTRÍA — Tabs Component
 */

import { ReactNode, useState } from 'react'
import './Tabs.css'

interface Tab {
  id: string
  label: string
  content: ReactNode
}

interface TabsProps {
  tabs: Tab[]
  defaultTab?: string
  className?: string
}

export function Tabs({ tabs, defaultTab, className = '' }: TabsProps) {
  const [activeTab, setActiveTab] = useState(defaultTab || tabs[0]?.id)

  const activeTabContent = tabs.find(tab => tab.id === activeTab)?.content

  return (
    <div className={`ds-tabs ${className}`}>
      <div className="ds-tabs-list" role="tablist">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            role="tab"
            aria-selected={activeTab === tab.id}
            className={`ds-tabs-tab ${activeTab === tab.id ? 'ds-tabs-tab--active' : ''}`}
            onClick={() => setActiveTab(tab.id)}
          >
            {tab.label}
          </button>
        ))}
      </div>
      <div className="ds-tabs-content" role="tabpanel">
        {activeTabContent}
      </div>
    </div>
  )
}
