import React from 'react'

export default function Pagination({
  currentPage,
  totalPages,
  rowsPerPage,
  setRowsPerPage,
  onPageChange,
  totalItems,
  isMobile
}) {
  if (!totalPages || totalPages <= 1) {
    return null
  }

  const btnBase = {
    padding: isMobile ? '7px 10px' : '8px 12px',
    background: 'transparent',
    border: '1px solid rgba(103,232,249,0.2)',
    borderRadius: 12,
    color: 'rgba(186,230,253,0.6)',
    cursor: 'pointer',
    fontSize: isMobile ? 12 : 13,
    fontWeight: 600,
    fontFamily: 'inherit'
  }

  const btnActive = {
    background: 'rgba(34,211,238,0.12)',
    border: '1px solid rgba(34,211,238,0.45)',
    color: '#22d3ee'
  }

  const btnDisabled = {
    opacity: 0.45,
    cursor: 'not-allowed'
  }

  const pageBtnStyle = (page) =>
    page === currentPage ? { ...btnBase, ...btnActive } : btnBase

  const showWindow = 5
  const half = Math.floor(showWindow / 2)

  let start = Math.max(1, currentPage - half)
  let end = Math.min(totalPages, start + showWindow - 1)

  start = Math.max(1, end - showWindow + 1)

  const pages = []
  for (let p = start; p <= end; p++) pages.push(p)

  return (
    <div
      style={{
        marginTop: 16,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        gap: 12,
        flexWrap: 'wrap'
      }}
    >
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: 10,
          flexWrap: 'wrap'
        }}
      >
        <div style={{ fontSize: 12, color: 'rgba(186,230,253,0.5)' }}>
          Page <span style={{ color: '#e0f7ff', fontWeight: 700 }}>{currentPage}</span> of{' '}
          <span style={{ color: '#e0f7ff', fontWeight: 700 }}>{totalPages}</span>
          {typeof totalItems === 'number' ? (
            <span style={{ marginLeft: 8 }}>
              ({totalItems} total)
            </span>
          ) : null}
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <span style={{ fontSize: 12, color: 'rgba(186,230,253,0.5)' }}>Rows</span>
          <select
            value={rowsPerPage}
            onChange={(e) => setRowsPerPage(+e.target.value)}
            style={{
              padding: isMobile ? '8px 10px' : '9px 12px',
              borderRadius: 12,
              background: 'rgba(255,255,255,0.06)',
              border: '1px solid rgba(103,232,249,0.25)',
              color: '#e0f7ff',
              fontSize: isMobile ? 12 : 13,
              outline: 'none',
              fontFamily: 'inherit'
            }}
          >
            {[5, 10, 20].map((n) => (
              <option key={n} value={n} style={{ background: '#0a1628' }}>
                {n}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: 8,
          flexWrap: 'wrap'
        }}
      >
        <button
          onClick={() => onPageChange(currentPage - 1)}
          disabled={currentPage === 1}
          style={{
            ...btnBase,
            ...(currentPage === 1 ? btnDisabled : null)
          }}
        >
          Previous
        </button>

        {start > 1 && (
          <>
            <button
              onClick={() => onPageChange(1)}
              style={pageBtnStyle(1)}
            >
              1
            </button>
            {start > 2 && (
              <span style={{ color: 'rgba(186,230,253,0.5)', fontWeight: 700 }}>…</span>
            )}
          </>
        )}

        {pages.map((p) => (
          <button key={p} onClick={() => onPageChange(p)} style={pageBtnStyle(p)}>
            {p}
          </button>
        ))}

        {end < totalPages && (
          <>
            {end < totalPages - 1 && (
              <span style={{ color: 'rgba(186,230,253,0.5)', fontWeight: 700 }}>…</span>
            )}
            <button onClick={() => onPageChange(totalPages)} style={pageBtnStyle(totalPages)}>
              {totalPages}
            </button>
          </>
        )}

        <button
          onClick={() => onPageChange(currentPage + 1)}
          disabled={currentPage === totalPages}
          style={{
            ...btnBase,
            ...(currentPage === totalPages ? btnDisabled : null)
          }}
        >
          Next
        </button>
      </div>
    </div>
  )
}

