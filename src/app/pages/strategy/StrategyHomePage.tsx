import { Link } from 'react-router-dom'

export function StrategyHomePage() {
  return (
    <div>
      <h1>Strategy</h1>
      <nav>
        <Link to="/strategy/objectives">Objectives</Link>
        {' | '}
        <Link to="/strategy/initiatives">Initiatives</Link>
        {' | '}
        <Link to="/strategy/snapshot">Snapshot</Link>
      </nav>
    </div>
  )
}
