/**
 * HUMANTRÍA — Table Component
 */

import { ReactNode } from 'react'
import './Table.css'

interface TableColumn<T = any> {
  key: string
  label: string
  render?: (value: any, row: T) => ReactNode
  width?: string
  align?: 'left' | 'center' | 'right'
}

interface TableProps<T = any> {
  columns: TableColumn<T>[]
  data: T[]
  loading?: boolean
  emptyMessage?: string
  onRowClick?: (row: T) => void
  actions?: (row: T) => ReactNode
  density?: 'compact' | 'comfortable'
  className?: string
}

export function Table<T = any>({
  columns,
  data,
  loading = false,
  emptyMessage = 'Nenhum dado disponível',
  onRowClick,
  actions,
  density = 'comfortable',
  className = ''
}: TableProps<T>) {
  if (loading) {
    return (
      <div className="ds-table-loading">
        <div className="ds-skeleton ds-skeleton--row" />
        <div className="ds-skeleton ds-skeleton--row" />
        <div className="ds-skeleton ds-skeleton--row" />
      </div>
    )
  }

  if (data.length === 0) {
    return (
      <div className="ds-table-empty">
        <p>{emptyMessage}</p>
      </div>
    )
  }

  return (
    <div className={`ds-table-wrapper ${className}`}>
      <table className={`ds-table ds-table--${density}`}>
        <thead>
          <tr>
            {columns.map((column) => (
              <th
                key={column.key}
                style={{ width: column.width, textAlign: column.align || 'left' }}
              >
                {column.label}
              </th>
            ))}
            {actions && <th style={{ width: '100px' }}>Ações</th>}
          </tr>
        </thead>
        <tbody>
          {data.map((row, index) => (
            <tr
              key={index}
              onClick={() => onRowClick?.(row)}
              className={onRowClick ? 'ds-table-row--clickable' : ''}
            >
              {columns.map((column) => {
                const value = (row as any)[column.key]
                return (
                  <td key={column.key} style={{ textAlign: column.align || 'left' }}>
                    {column.render ? column.render(value, row) : String(value ?? '')}
                  </td>
                )
              })}
              {actions && (
                <td onClick={(e) => e.stopPropagation()}>
                  {actions(row)}
                </td>
              )}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
