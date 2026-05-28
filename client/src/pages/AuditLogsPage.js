import { useEffect, useMemo, useState } from 'react'

import auditService from '../services/auditService'
import Sidebar from '../components/layout/Sidebar'
import GlassCard from '../components/ui/GlassCard'
import Pagination from '../components/ui/Pagination'
import { useAuth } from '../context/AuthContext'
import useResponsive from '../hooks/useResponsive'

function formatDateInput(d) {
  if (!d) return ''
  return d
}

function mapSeverityToBadge(severity) {
  const s = (severity || '').toLowerCase()
  if (s === 'critical' || s === 'failed' || s === 'error' || s === 'high') {
    return { label: 'Failed', bg: 'rgba(248,113,113,0.15)', border: 'rgba(248,113,113,0.3)', color: '#f87171' }
  }
  if (s === 'warning' || s === 'warn') {
    return { label: 'Warning', bg: 'rgba(251,191,36,0.15)', border: 'rgba(251,191,36,0.35)', color: '#fbbf24' }
  }
  return { label: 'Success', bg: 'rgba(74,222,128,0.15)', border: 'rgba(74,222,128,0.3)', color: '#4ade80' }
}

function StatusBadge({ severity }) {
  const badge = mapSeverityToBadge(severity)
  return (
    <span
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: 8,
        borderRadius: 999,
        padding: '4px 12px',
        fontSize: 12,
        fontWeight: 600,
        background: badge.bg,
        border: `1px solid ${badge.border}`,
        color: badge.color,
        whiteSpace: 'nowrap',
      }}
    >
      {badge.label}
    </span>
  )
}

function SkeletonRow() {
  return (
    <tr>
      {Array.from({ length: 6 }).map((_, idx) => (
        <td key={idx} style={{ padding: '10px 12px', borderBottom: '1px solid rgba(103,232,249,0.06)' }}>
          <div
            style={{
              height: 12,
              borderRadius: 8,
              background: 'linear-gradient(90deg, rgba(255,255,255,0.05), rgba(255,255,255,0.12), rgba(255,255,255,0.05))',
              animation: 's2q-shimmer 1.2s ease-in-out infinite',
              width: idx === 5 ? 180 : 120,
            }}
          />
        </td>
      ))}
    </tr>
  )
}

export default function AuditLogsPage() {
  const { user } = useAuth()
  const { isMobile, isTablet } = useResponsive()

  const isAllowed = user?.role === 'admin' || user?.role === 'teacher'

  const [logs, setLogs] = useState([])
  const [loading, setLoading] = useState(true)

  const [pagination, setPagination] = useState({ page: 1, limit: 20, total: 0, totalPages: 0 })

  const [filters, setFilters] = useState({
    q: '',
    action_type: '',
    module: '',
    severity: '',
    target_type: '',
    from: '',
    to: '',
  })

  const canFetch = isAllowed

  useEffect(() => {
    if (!canFetch) return

    async function load() {
      setLoading(true)
      try {
        const logsRes = await auditService.getLogs({
          page: 1,
          limit: 20,
          ...Object.fromEntries(Object.entries(filters).filter(([, v]) => v !== '')),
        })

        setLogs(logsRes.data.logs)
        setPagination(logsRes.data.pagination)
      } finally {
        setLoading(false)
      }
    }

    load()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [canFetch])

  async function applyFilters({ page = 1 } = {}) {
    if (!canFetch) return
    setLoading(true)
    try {
      const logsRes = await auditService.getLogs({
        page,
        limit: pagination.limit,
        ...Object.fromEntries(Object.entries(filters).filter(([, v]) => v !== '')),
      })

      setLogs(logsRes.data.logs)
      setPagination(logsRes.data.pagination)
    } finally {
      setLoading(false)
    }
  }

  const pageTitle = 'Audit Logs'
  const subtitle = 'Monitor system activities and user actions'

  const inputStyle = useMemo(
    () => ({
      width: '100%',
      padding: '10px 14px',
      background: 'rgba(255,255,255,0.06)',
      border: '1px solid rgba(103,232,249,0.25)',
      borderRadius: 12,
      color: '#e0f7ff',
      fontSize: 13,
      outline: 'none',
      boxSizing: 'border-box',
    }),
    []
  )

  const labelStyle = useMemo(
    () => ({
      display: 'block',
      fontSize: 12,
      color: 'rgba(186,230,253,0.6)',
      marginBottom: 6,
      fontWeight: 500,
    }),
    []
  )

  const tableHeaderStyle = useMemo(
    () => ({
      textAlign: 'left',
      padding: '10px 12px',
      fontSize: 11,
      color: '#22d3ee',
      fontWeight: 700,
      textTransform: 'uppercase',
      letterSpacing: '0.7px',
      background: 'rgba(34,211,238,0.08)',
      borderBottom: '1px solid rgba(103,232,249,0.12)',
      position: 'sticky',
      top: 0,
      zIndex: 2,
    }),
    []
  )

  const bg = 'linear-gradient(135deg,#060d1f 0%,#0a1628 50%,#0d1f3c 100%)'

  const ambientCyanStyle = {
    position: 'absolute',
    top: isMobile ? '8%' : '10%',
    left: '8%',
    width: isMobile ? 220 : 420,
    height: isMobile ? 220 : 420,
    borderRadius: '50%',
    background: 'radial-gradient(circle, rgba(34,211,238,0.10) 0%, transparent 70%)',
    pointerEvents: 'none',
    filter: 'blur(0px)',
  }

  const ambientIndigoStyle = {
    position: 'absolute',
    bottom: isMobile ? '6%' : '10%',
    right: '10%',
    width: isMobile ? 200 : 360,
    height: isMobile ? 200 : 360,
    borderRadius: '50%',
    background: 'radial-gradient(circle, rgba(99,102,241,0.12) 0%, transparent 70%)',
    pointerEvents: 'none',
  }

  if (!isAllowed) {
    return (
      <div style={{ display: 'flex', minHeight: '100vh', background: bg, fontFamily: "'Segoe UI',system-ui,sans-serif", position: 'relative' }}>
        <Sidebar />
        <div style={{ ...ambientCyanStyle }} />
        <div style={{ ...ambientIndigoStyle }} />

        <div style={{ flex: 1, overflow: 'auto', position: 'relative' }}>
          <div
            style={{
              padding: isMobile ? '12px 14px' : isTablet ? '16px 18px' : '16px 28px',
              background: 'rgba(255,255,255,0.03)',
              backdropFilter: 'blur(16px)',
              borderBottom: '1px solid rgba(103,232,249,0.08)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
            }}
          >
            <div>
              <h1 style={{ color: '#e0f7ff', fontSize: 20, fontWeight: 600, margin: 0 }}>{pageTitle}</h1>
              <p style={{ color: 'rgba(186,230,253,0.5)', fontSize: 13, margin: '2px 0 0' }}>Access restricted</p>
            </div>
          </div>

          <div style={{ padding: isMobile ? '16px 14px' : isTablet ? '20px 18px' : '24px 28px' }}>
            <GlassCard glow>
              <div style={{ fontSize: 18, fontWeight: 700, color: '#e0f7ff' }}>Access denied</div>
              <div style={{ color: 'rgba(186,230,253,0.6)', marginTop: 6, fontSize: 13 }}>
                Audit logs are restricted to admin and teacher roles.
              </div>
            </GlassCard>
          </div>
        </div>
      </div>
    )
  }

  const totalPages = pagination?.totalPages || 0
  const currentPage = pagination?.page || 1
  const totalItems = pagination?.total ?? logs.length

  // Ensure skeleton animation keyframes exist (shimmer is used in SkeletonRow)
  // Note: SkeletonRow is currently not rendered, but keyframes are harmless.
  const _ensureSkeletonKeyframes = true


  return (
    <div style={{ display: 'flex', minHeight: '100vh', background: bg, fontFamily: "'Segoe UI',system-ui,sans-serif", position: 'relative' }}>
      <style>
        {`@keyframes s2q-shimmer{0%{background-position:0% 50%}100%{background-position:100% 50%}}`}
      </style>

      <Sidebar />
      <div style={ambientCyanStyle} />
      <div style={ambientIndigoStyle} />

      <div style={{ flex: 1, overflow: 'auto', position: 'relative' }}>
        {/* Page header */}
        <div
          style={{
            padding: isMobile ? '12px 14px' : isTablet ? '16px 18px' : '16px 28px',
            background: 'rgba(255,255,255,0.03)',
            backdropFilter: 'blur(16px)',
            borderBottom: '1px solid rgba(103,232,249,0.08)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: 12,
          }}
        >
          <div>
            <h1 style={{ color: '#e0f7ff', fontSize: 20, fontWeight: 600, margin: 0 }}>{pageTitle}</h1>
            <p style={{ color: 'rgba(186,230,253,0.5)', fontSize: 13, margin: '2px 0 0' }}>{subtitle}</p>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: 12, flexWrap: 'wrap', justifyContent: 'flex-end' }}>
            <div
              style={{
                background: 'rgba(255,255,255,0.06)',
                border: '1px solid rgba(103,232,249,0.2)',
                borderRadius: 12,
                padding: '8px 12px',
                color: 'rgba(186,230,253,0.65)',
                fontSize: 12,
                display: 'flex',
                alignItems: 'center',
                gap: 8,
              }}
            >
              <span style={{ color: '#22d3ee', fontWeight: 900 }}>●</span>
              <span>{totalItems} total</span>
            </div>
          </div>
        </div>

        <div style={{ padding: isMobile ? '16px 14px' : isTablet ? '20px 18px' : '24px 28px' }}>
          <GlassCard glow>
            {/* Search + Filters toolbar */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
              <div
                style={{
                  display: 'flex',
                  alignItems: isMobile ? 'stretch' : 'flex-end',
                  justifyContent: 'space-between',
                  gap: 12,
                  flexWrap: 'wrap',
                }}
              >
                <div>
                  <div style={{ fontSize: 16, fontWeight: 700, color: '#e0f7ff', marginBottom: 4 }}>{pageTitle}</div>
                  <div style={{ color: 'rgba(186,230,253,0.55)', fontSize: 13 }}>Search, filter, and audit activity in real-time.</div>
                </div>

                <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap', alignItems: 'center' }}>
                  <div style={{ minWidth: isMobile ? '100%' : 320, flex: '1 1 320px' }}>
                    <label style={labelStyle}>Search</label>
                    <input
                      style={inputStyle}
                      placeholder="Search audit logs..."
                      value={filters.q}
                      onChange={(e) => setFilters((p) => ({ ...p, q: e.target.value }))}
                      disabled={loading}
                    />
                  </div>

                  <button
                    onClick={() => applyFilters({ page: 1 })}
                    disabled={loading}
                    style={{
                      height: 44,
                      padding: '0 18px',
                      background: 'linear-gradient(135deg, rgba(34,211,238,0.18), rgba(99,102,241,0.15))',
                      border: '1px solid rgba(34,211,238,0.45)',
                      borderRadius: 12,
                      color: '#22d3ee',
                      fontWeight: 800,
                      fontSize: 13,
                      cursor: loading ? 'not-allowed' : 'pointer',
                      boxShadow: '0 0 18px rgba(34,211,238,0.12)',
                      whiteSpace: 'nowrap',
                    }}
                  >
                    {loading ? 'Refreshing...' : 'Refresh'}
                  </button>
                </div>
              </div>

              <div
                style={{
                  display: 'grid',
                  gridTemplateColumns: isMobile ? '1fr' : isTablet ? 'repeat(3, 1fr)' : 'repeat(5, 1fr)',
                  gap: 12,
                }}
              >
                <div>
                  <label style={labelStyle}>Severity</label>
                  <select
                    style={inputStyle}
                    value={filters.severity}
                    onChange={(e) => setFilters((p) => ({ ...p, severity: e.target.value }))}
                    disabled={loading}
                  >
                    <option value="">All severities</option>
                    <option value="info">info</option>
                    <option value="warning">warning</option>
                    <option value="critical">critical</option>
                  </select>
                </div>

                <div>
                  <label style={labelStyle}>Module</label>
                  <input
                    style={inputStyle}
                    placeholder="Module"
                    value={filters.module}
                    onChange={(e) => setFilters((p) => ({ ...p, module: e.target.value }))}
                    disabled={loading}
                  />
                </div>

                <div>
                  <label style={labelStyle}>Action</label>
                  <input
                    style={inputStyle}
                    placeholder="Action type"
                    value={filters.action_type}
                    onChange={(e) => setFilters((p) => ({ ...p, action_type: e.target.value }))}
                    disabled={loading}
                  />
                </div>

                <div>
                  <label style={labelStyle}>Target type</label>
                  <input
                    style={inputStyle}
                    placeholder="Target type"
                    value={filters.target_type}
                    onChange={(e) => setFilters((p) => ({ ...p, target_type: e.target.value }))}
                    disabled={loading}
                  />
                </div>

                <div style={{ gridColumn: isMobile ? 'auto' : 'span 1' }}>
                  <label style={labelStyle}>Date range</label>
                  <div style={{ display: 'flex', gap: 10 }}>
                    <input
                      style={{ ...inputStyle, padding: '10px 12px' }}
                      type="date"
                      value={formatDateInput(filters.from)}
                      onChange={(e) => setFilters((p) => ({ ...p, from: e.target.value }))}
                      disabled={loading}
                    />
                    <input
                      style={{ ...inputStyle, padding: '10px 12px' }}
                      type="date"
                      value={formatDateInput(filters.to)}
                      onChange={(e) => setFilters((p) => ({ ...p, to: e.target.value }))}
                      disabled={loading}
                    />
                  </div>
                </div>
              </div>
            </div>

            {/* Table */}
            <div style={{ marginTop: 18 }}>
              {loading ? (
                <div style={{ padding: isMobile ? 10 : 16, color: 'rgba(186,230,253,0.5)' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 12, justifyContent: 'center' }}>
                    <div
                      style={{
                        width: 14,
                        height: 14,
                        borderRadius: '50%',
                        border: '2px solid rgba(34,211,238,0.35)',
                        borderTopColor: '#22d3ee',
                        animation: 's2q-spin 0.9s linear infinite',
                      }}
                    />
                    <span style={{ fontSize: 13 }}>Loading audit logs...</span>
                  </div>
                  <style>{`@keyframes s2q-spin{to{transform:rotate(360deg)}}`}</style>
                </div>
              ) : logs.length === 0 ? (
                <div style={{ padding: isMobile ? '28px 10px' : '44px 10px', textAlign: 'center' }}>
                  <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 12 }}>
                    <div
                      style={{
                        width: 52,
                        height: 52,
                        borderRadius: 18,
                        background: 'rgba(34,211,238,0.08)',
                        border: '1px solid rgba(103,232,249,0.18)',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        color: '#22d3ee',
                        fontSize: 22,
                        boxShadow: '0 0 26px rgba(34,211,238,0.12)',
                      }}
                    >
                      🔎
                    </div>
                  </div>
                  <div style={{ color: '#e0f7ff', fontSize: 15, fontWeight: 700, marginBottom: 6 }}>No audit logs found.</div>
                  <div style={{ color: 'rgba(186,230,253,0.45)', fontSize: 13 }}>Try adjusting filters and search.</div>
                </div>
              ) : (
                <>
                  {/* Desktop table */}
                  <div style={{ display: isMobile ? 'none' : 'block' }}>
                    <div style={{ overflowX: 'auto', borderRadius: 18 }}>
                      <table style={{ width: '100%', borderCollapse: 'separate', borderSpacing: 0, minWidth: 860 }}>
                        <thead>
                          <tr>
                            {['User', 'Action', 'Module', 'Timestamp', 'IP Address', 'Status'].map((h) => (
                              <th key={h} style={tableHeaderStyle}>
                                {h}
                              </th>
                            ))}
                          </tr>
                        </thead>
                        <tbody>
                          {logs.map((l) => {
                            const rowHover = {
                              background: 'transparent',
                            }

                            const user = l?.user_name || l?.username || l?.email || l?.user || '—'
                            const action = l?.action_type || l?.action || l?.event || '—'
                            const module = l?.module || l?.module_name || '—'
                            const ts = l?.created_at || l?.timestamp || l?.time || null
                            const ip = l?.ip_address || l?.ip || '—'
                            const severity = l?.severity || l?.status || 'info'

                            return (
                              <tr
                                key={l.id || l.log_id || `${user}-${action}-${ts}`}
                                style={{
                                  transition: 'background 0.2s',
                                  borderBottom: '1px solid rgba(103,232,249,0.06)',
                                }}
                                onMouseEnter={(e) => {
                                  e.currentTarget.style.background = 'rgba(34,211,238,0.05)'
                                }}
                                onMouseLeave={(e) => {
                                  e.currentTarget.style.background = 'transparent'
                                }}
                              >
                                <td style={{ padding: '12px', color: '#e0f7ff', fontWeight: 600, fontSize: 13 }}>{user}</td>
                                <td style={{ padding: '12px', color: '#22d3ee', fontWeight: 700, fontSize: 13 }}>{action}</td>
                                <td style={{ padding: '12px', color: 'rgba(186,230,253,0.75)', fontSize: 13 }}>{module}</td>
                                <td style={{ padding: '12px', color: 'rgba(186,230,253,0.55)', fontSize: 12 }}>
                                  {ts ? new Date(ts).toLocaleString() : '—'}
                                </td>
                                <td style={{ padding: '12px', color: 'rgba(186,230,253,0.55)', fontSize: 12, fontFamily: 'monospace' }}>{ip}</td>
                                <td style={{ padding: '12px' }}>
                                  <StatusBadge severity={severity} />
                                </td>
                              </tr>
                            )
                          })}
                        </tbody>
                      </table>
                    </div>
                  </div>

                  {/* Mobile cards */}
                  <div style={{ display: isMobile ? 'block' : 'none' }}>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
                      {logs.map((l) => {
                        const user = l?.user_name || l?.username || l?.email || l?.user || '—'
                        const action = l?.action_type || l?.action || l?.event || '—'
                        const module = l?.module || l?.module_name || '—'
                        const ts = l?.created_at || l?.timestamp || l?.time || null
                        const ip = l?.ip_address || l?.ip || '—'
                        const severity = l?.severity || l?.status || 'info'

                        return (
                          <div
                            key={l.id || l.log_id || `${user}-${action}-${ts}`}
                            style={{
                              background: 'rgba(255,255,255,0.03)',
                              border: '1px solid rgba(103,232,249,0.10)',
                              borderRadius: 18,
                              padding: 14,
                              boxShadow: '0 8px 30px rgba(0,0,0,0.15)',
                            }}
                          >
                            <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12 }}>
                              <div>
                                <div style={{ color: '#e0f7ff', fontWeight: 800, fontSize: 13 }}>{user}</div>
                                <div style={{ color: 'rgba(186,230,253,0.55)', fontSize: 12, marginTop: 4 }}>{module}</div>
                              </div>
                              <StatusBadge severity={severity} />
                            </div>
                            <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 6 }}>
                              <div style={{ color: '#22d3ee', fontWeight: 800, fontSize: 13 }}>{action}</div>
                              <div style={{ color: 'rgba(186,230,253,0.55)', fontSize: 12 }}>
                                {ts ? new Date(ts).toLocaleString() : '—'}
                              </div>
                              <div style={{ color: 'rgba(186,230,253,0.55)', fontSize: 12, fontFamily: 'monospace' }}>IP: {ip}</div>
                            </div>
                          </div>
                        )
                      })}
                    </div>
                  </div>
                </>
              )}
            </div>

            {/* Pagination */}
            <div style={{ padding: isMobile ? '20px 0 0' : '24px 0 0' }}>
              <Pagination
                currentPage={Math.max(1, currentPage)}
                totalPages={Math.max(1, totalPages)}
                rowsPerPage={pagination.limit}
                setRowsPerPage={(n) => {
                  setPagination((p) => ({ ...p, limit: n }))
                }}
                onPageChange={(p) => applyFilters({ page: p })}
                totalItems={typeof totalItems === 'number' ? totalItems : logs.length}
                isMobile={isMobile}
              />
            </div>
          </GlassCard>
        </div>
      </div>
    </div>
  )
}


