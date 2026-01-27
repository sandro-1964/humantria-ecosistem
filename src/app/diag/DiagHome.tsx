import { Link } from 'react-router-dom'
import { useTranslation } from 'react-i18next'

import { toText } from '../../lib/to-text'

export function DiagHome() {
  const { t } = useTranslation()
  return (
    <div style={{ padding: 24 }}>
      <h1>{toText(t('diag.title'))}</h1>
      <ul>
        <li>
          <Link to="/__diag/meta">{toText(t('diag.openMeta'))}</Link>
        </li>
        <li>
          <Link to="/foundation">{toText(t('nav.foundation'))}</Link>
        </li>
      </ul>
    </div>
  )
}

