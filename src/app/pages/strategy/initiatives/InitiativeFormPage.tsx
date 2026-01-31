import { Link } from 'react-router-dom'

import { PageLayout, Card, Button } from '../../../../design-system/components'

export function InitiativeFormPage() {
  return (
    <PageLayout
      title="New Initiative"
      actions={
        <Link to="/strategy/initiatives">
          <Button variant="secondary">Back to initiatives</Button>
        </Link>
      }
    >
      <Card title="Form">
        <p style={{ margin: 0 }}>Form placeholder (MVP mínima)</p>
      </Card>
    </PageLayout>
  )
}
