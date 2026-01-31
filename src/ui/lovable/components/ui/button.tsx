import type { ButtonHTMLAttributes, ReactNode } from 'react'

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  children?: ReactNode
  variant?: 'primary' | 'secondary' | 'ghost'
}

export function Button({ children, variant = 'primary', className = '', ...props }: ButtonProps) {
  const base = 'lovable-btn'
  const v = variant === 'primary' ? 'lovable-btn-primary' : variant === 'secondary' ? 'lovable-btn-secondary' : 'lovable-btn-ghost'
  return (
    <button type="button" className={`${base} ${v} ${className}`.trim()} {...props}>
      {children}
    </button>
  )
}
