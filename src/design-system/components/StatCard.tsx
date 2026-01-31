type Props = {
  label: string
  value: string | number
}

export function StatCard({ label, value }: Props) {
  return (
    <div className="ds-stat-card">
      <span className="ds-stat-card__label">{label}</span>
      <span className="ds-stat-card__value">{value}</span>
    </div>
  )
}
