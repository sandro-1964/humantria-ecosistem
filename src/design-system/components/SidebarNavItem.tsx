import { NavLink } from 'react-router-dom'

type Props = {
  to: string
  label: string
}

export function SidebarNavItem({ to, label }: Props) {
  return (
    <NavLink
      to={to}
      className={({ isActive }) => `ds-sidebar-nav-item ${isActive ? 'ds-sidebar-nav-item--active' : ''}`}
    >
      {label}
    </NavLink>
  )
}
