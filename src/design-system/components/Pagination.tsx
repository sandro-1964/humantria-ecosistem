/**
 * HUMANTRÍA — Pagination Component
 */

import './Pagination.css'

interface PaginationProps {
  currentPage: number
  totalPages: number
  onPageChange: (page: number) => void
  className?: string
}

export function Pagination({ currentPage, totalPages, onPageChange, className = '' }: PaginationProps) {
  const pages = Array.from({ length: totalPages }, (_, i) => i + 1)
  const visiblePages = pages.filter(
    (page) =>
      page === 1 ||
      page === totalPages ||
      (page >= currentPage - 1 && page <= currentPage + 1)
  )

  return (
    <nav className={`ds-pagination ${className}`} aria-label="Paginação">
      <button
        className="ds-pagination-button"
        onClick={() => onPageChange(currentPage - 1)}
        disabled={currentPage === 1}
        aria-label="Página anterior"
      >
        ←
      </button>
      {visiblePages.map((page, index) => {
        const showEllipsis = index > 0 && page - visiblePages[index - 1] > 1
        return (
          <span key={page}>
            {showEllipsis && <span className="ds-pagination-ellipsis">...</span>}
            <button
              className={`ds-pagination-button ${currentPage === page ? 'ds-pagination-button--active' : ''}`}
              onClick={() => onPageChange(page)}
              aria-label={`Página ${page}`}
              aria-current={currentPage === page ? 'page' : undefined}
            >
              {page}
            </button>
          </span>
        )
      })}
      <button
        className="ds-pagination-button"
        onClick={() => onPageChange(currentPage + 1)}
        disabled={currentPage === totalPages}
        aria-label="Próxima página"
      >
        →
      </button>
    </nav>
  )
}
