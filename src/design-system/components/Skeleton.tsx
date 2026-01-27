/**
 * HUMANTRÍA — Skeleton Component
 */

import './Skeleton.css'

interface SkeletonProps {
  width?: string
  height?: string
  className?: string
}

export function Skeleton({ width, height = '1rem', className = '' }: SkeletonProps) {
  return (
    <div
      className={`ds-skeleton ${className}`}
      style={{ width, height }}
    />
  )
}
