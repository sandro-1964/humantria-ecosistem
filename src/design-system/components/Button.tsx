import type { ReactNode } from 'react'

type Props = {
  children: ReactNode
  variant?: 'primary' | 'secondary' | 'ghost' | 'destructive'
  asChild?: boolean
  href?: string
  onClick?: () => void
  disabled?: boolean
  type?: 'button' | 'submit'
  'data-testid'?: string
}

export function Button({
  children,
  variant = 'primary',
  asChild,
  href,
  onClick,
  disabled,
  type = 'button',
  'data-testid': testid,
}: Props) {
  const cn = `ds-btn ds-btn--${variant}`
  if (asChild && href) {
    return (
      <a href={href} className={cn} data-testid={testid}>
        {children}
      </a>
    )
  }
  return (
    <button
      type={type}
      className={cn}
      onClick={onClick}
      disabled={disabled}
      data-testid={testid}
    >
      {children}
    </button>
  )
}
