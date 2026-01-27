/**
 * HUMANTRÍA — StatsCard Component
 */

import { ReactNode } from 'react'
import './StatsCard.css'

interface StatsCardProps {
  label: string
  value: string | number
  trend?: {
    value: number
    isPositive: boolean
  }
  icon?: ReactNode
  className?: string
}

export function StatsCard({ label, value, trend, icon, className = '' }: StatsCardProps) {
  return (
    <div className={`ds-stats-card ${className}`}>
      {icon && <div className="ds-stats-card-icon">{icon}</div>}
      <div className="ds-stats-card-content">
        <div className="ds-stats-card-label">{label}</div>
        <div className="ds-stats-card-value">{value}</div>
        {trend && (
          <div className={`ds-stats-card-trend ds-stats-card-trend--${trend.isPositive ? 'positive' : 'negative'}`}>
            {trend.isPositive ? '↑' : '↓'} {Math.abs(trend.value)}%
          </div>
        )}
      </div>
    </div>
  )
}
