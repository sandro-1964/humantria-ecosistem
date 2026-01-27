/**
 * HUMANTRÍA — Tooltip Component
 */

import { ReactNode, useState } from 'react'
import './Tooltip.css'

interface TooltipProps {
  children: ReactNode
  content: ReactNode
  placement?: 'top' | 'bottom' | 'left' | 'right'
}

export function Tooltip({ children, content, placement = 'top' }: TooltipProps) {
  const [isVisible, setIsVisible] = useState(false)

  return (
    <div
      className="ds-tooltip-wrapper"
      onMouseEnter={() => setIsVisible(true)}
      onMouseLeave={() => setIsVisible(false)}
    >
      {children}
      {isVisible && (
        <div className={`ds-tooltip ds-tooltip--${placement}`} role="tooltip">
          {content}
        </div>
      )}
    </div>
  )
}
