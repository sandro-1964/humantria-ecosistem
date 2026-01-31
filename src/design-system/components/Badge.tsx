type Props = {
  children: string
  variant?: 'default' | 'success' | 'warning' | 'info'
}

export function Badge({ children, variant = 'default' }: Props) {
  return <span className={`ds-badge ds-badge--${variant}`}>{children}</span>
}
