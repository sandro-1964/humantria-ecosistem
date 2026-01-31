import { Link } from 'react-router-dom'

import { PageLayout, Card, Button } from '../../../../design-system/components'

export function ObjectiveFormPage() {
  return (
    <PageLayout
      title="New Objective"
      actions={
        <Link to="/strategy/objectives">
          <Button variant="secondary">Back to objectives</Button>
        </Link>
      }
    >
      <Card title="Form">
        <p style={{ margin: 0 }}>Form placeholder (MVP mínima)</p>
      </Card>
    </PageLayout>
  )
}
