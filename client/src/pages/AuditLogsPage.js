import { useEffect, useState } from 'react'
import auditService from '../services/auditService'
import Sidebar from '../components/layout/Sidebar'
import GlassCard from '../components/ui/GlassCard'
import { useAuth } from '../context/AuthContext'
import useResponsive from '../hooks/useResponsive'


function formatDateInput(d) {

  if (!d) return ''
  // Expect YYYY-MM-DD
  return d
}


function SeverityBadge({ severity }) {
  const map = {
    info: 'bg-blue-100 text-blue-800 border-blue-200',
    warning: 'bg-amber-100 text-amber-800 border-amber-200',
    critical: 'bg-red-100 text-red-800 border-red-200'
  }

  return (
    <span
      className={`inline-flex items-center rounded-full border px-2 py-0.5 text-xs font-semibold ${map[severity] || map.info}`}
    >
      {severity?.toUpperCase?.() || severity}
    </span>
  )
}

export default function AuditLogsPage() {
  const { user } = useAuth()
  const { isMobile, isTablet } = useResponsive()

  const isAllowed = user?.role === 'admin' || user?.role === 'teacher'

  const [logs, setLogs] = useState([])

  const [pagination, setPagination] = useState({ page: 1, limit: 20, total: 0, totalPages: 0 })

  const [loading, setLoading] = useState(true)

  const [filters, setFilters] = useState({
    q: '',
    action_type: '',
    module: '',
    severity: '',
    target_type: '',
    from: '',
    to: ''
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
          ...Object.fromEntries(
            Object.entries(filters).filter(([, v]) => v !== '')
          )
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
        ...Object.fromEntries(
          Object.entries(filters).filter(([, v]) => v !== '')
        )
      })

      setLogs(logsRes.data.logs)
      setPagination(logsRes.data.pagination)
    } finally {
      setLoading(false)
    }
  }

  if (!isAllowed) {

    return (
      <div
        style={{
          display: 'flex',
          minHeight: '100vh',
          background: 'linear-gradient(135deg,#060d1f 0%,#0a1628 50%,#0d1f3c 100%)',
          fontFamily: "'Segoe UI', system-ui, sans-serif"
        }}
      >
        <Sidebar />

        <div style={{ flex: 1, overflow: 'auto' }}>
          <div
            style={{
              padding: isMobile ? '12px 14px' : isTablet ? '16px 18px' : '16px 28px',
              background: 'rgba(255,255,255,0.03)',
              backdropFilter: 'blur(16px)',
              borderBottom: '1px solid rgba(103,232,249,0.08)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between'
            }}
          >
            <div>
              <h1 style={{ color: '#e0f7ff', fontSize: 20, fontWeight: 600, margin: 0 }}>
                Audit Logs
              </h1>
              <p style={{ color: 'rgba(186,230,253,0.5)', fontSize: 13, margin: '2px 0 0' }}>
                Access restricted
              </p>
            </div>
          </div>

          <div style={{ padding: isMobile ? '16px 14px' : isTablet ? '20px 18px' : '24px 28px' }}>
            <GlassCard>
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

  return (
    <div
      style={{
        display: 'flex',
        minHeight: '100vh',
        background: 'linear-gradient(135deg,#060d1f 0%,#0a1628 50%,#0d1f3c 100%)',
        fontFamily: "'Segoe UI', system-ui, sans-serif"
      }}
    >
      <Sidebar />

      <div style={{ flex: 1, overflow: 'auto' }}>
        {/* Top bar */}
        <div
          style={{
            padding: isMobile ? '12px 14px' : isTablet ? '16px 18px' : '16px 28px',
            background: 'rgba(255,255,255,0.03)',
            backdropFilter: 'blur(16px)',
            borderBottom: '1px solid rgba(103,232,249,0.08)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between'
          }}
        >
          <div>
            <h1 style={{ color: '#e0f7ff', fontSize: 20, fontWeight: 600, margin: 0 }}>
              Audit Logs
            </h1>
            <p style={{ color: 'rgba(186,230,253,0.5)', fontSize: 13, margin: '2px 0 0' }}>
              Filter and review system activity
            </p>
          </div>
        </div>

        <div style={{ padding: isMobile ? '16px 14px' : isTablet ? '20px 18px' : '24px 28px' }}>
          <GlassCard>
            <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-3">
              <div>
                <div className="font-semibold text-lg">Audit Logs</div>
                <div className="text-sm text-gray-500 mt-1">Filter, search, and review system activity</div>
              </div>

              <div className="flex gap-2 flex-wrap">
                <input
                  className="border rounded-md px-3 py-2 text-sm"
                  placeholder="Search..."
                  value={filters.q}
                  onChange={(e) => setFilters((p) => ({ ...p, q: e.target.value }))}
                  disabled={loading}
                />
                <button
                  className="bg-indigo-600 text-white rounded-md px-3 py-2 text-sm font-semibold"
                  onClick={() => applyFilters({ page: 1 })}
                  disabled={loading}
                >
                  {loading ? 'Loading...' : 'Apply'}
                </button>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-5 gap-3 mt-4">
              <select
                className="border rounded-md px-3 py-2 text-sm bg-white/60"
                value={filters.severity}
                onChange={(e) => setFilters((p) => ({ ...p, severity: e.target.value }))}
                disabled={loading}
              >
                <option value="">All severities</option>
                <option value="info">info</option>
                <option value="warning">warning</option>
                <option value="critical">critical</option>
              </select>

              <input
                className="border rounded-md px-3 py-2 text-sm bg-white/60"
                placeholder="Module"
                value={filters.module}
                onChange={(e) => setFilters((p) => ({ ...p, module: e.target.value }))}
                disabled={loading}
              />

              <input
                className="border rounded-md px-3 py-2 text-sm bg-white/60"
                placeholder="Action type"
                value={filters.action_type}
                onChange={(e) => setFilters((p) => ({ ...p, action_type: e.target.value }))}
                disabled={loading}
              />

              <input
                className="border rounded-md px-3 py-2 text-sm bg-white/60"
                placeholder="Target type"
                value={filters.target_type}
                onChange={(e) => setFilters((p) => ({ ...p, target_type: e.target.value }))}
                disabled={loading}
              />

              <div className="flex gap-2">
                <input
                  className="border rounded-md px-3 py-2 text-sm bg-white/60 w-1/2"
                  type="date"
                  value={formatDateInput(filters.from)}
                  onChange={(e) => setFilters((p) => ({ ...p, from: e.target.value }))}
                  disabled={loading}
                />
                <input
                  className="border rounded-md px-3 py-2 text-sm bg-white/60 w-1/2"
                  type="date"
                  value={formatDateInput(filters.to)}
                  onChange={(e) => setFilters((p) => ({ ...p, to: e.target.value }))}
                  disabled={loading}
                />
              </div>
            </div>

            {/* Table (desktop) */}
            <div className="hidden md:block mt-5">
              <div className="overflow-x-auto">
                <table className="w-full text-sm border-collapse">
                  <thead>
                    <tr className="text-left">
                      <th className="p-2 border-b">Time</th>
                      <th className="p-2 border-b">Severity</th>
                      <th className="p-2 border-b">Action</th>
                      <th className="p-2 border-b">Module</th>
                      <th className="p-2 border-b">Target</th>
                      <th className="p-2 border-b">Description</th>
                    </tr>
                  </thead>
                  <tbody>
                    {logs.map((l) => (
                      <tr key={l.id} className="hover:bg-gray-50">
                        <td className="p-2 border-b">{new Date(l.created_at).toLocaleString()}</td>
                        <td className="p-2 border-b"><SeverityBadge severity={l.severity} /></td>
                        <td className="p-2 border-b font-medium">{l.action_type}</td>
                        <td className="p-2 border-b">{l.module}</td>
                        <td className="p-2 border-b">{l.target_type}:{l.target_id}</td>
                        <td className="p-2 border-b text-gray-600 max-w-[420px] truncate">{l.description}</td>
                      </tr>
                    ))}
                    {logs.length === 0 && (
                      <tr>
                        <td colSpan={6} className="p-5 text-center text-gray-500">No logs match your filters.</td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>

            {/* Cards (mobile) */}
            <div className="md:hidden mt-5 space-y-3">
              {logs.map((l) => (
                <div key={l.id} className="p-3 rounded-lg border bg-white/50">
                  <div className="flex items-center justify-between gap-2">
                    <SeverityBadge severity={l.severity} />
                    <div className="text-[11px] text-gray-500">{new Date(l.created_at).toLocaleString()}</div>
                  </div>
                  <div className="mt-2 font-semibold text-sm">{l.action_type}</div>
                  <div className="text-xs text-gray-500 mt-1">module: {l.module}</div>
                  <div className="text-xs text-gray-700 mt-1">target: {l.target_type}:{l.target_id}</div>
                  <div className="text-sm text-gray-600 mt-2">{l.description}</div>
                </div>
              ))}
              {logs.length === 0 && <div className="text-sm text-gray-500">No logs match your filters.</div>}
            </div>

            {/* Pagination */}
            <div className="flex items-center justify-between mt-5">
              <div className="text-sm text-gray-600">
                Page <span className="font-semibold">{pagination.page}</span> of{' '}
                <span className="font-semibold">{pagination.totalPages}</span>
              </div>

              <div className="flex gap-2">
                <button
                  className="border rounded-md px-3 py-2 text-sm"
                  disabled={pagination.page <= 1 || loading}
                  onClick={() => applyFilters({ page: pagination.page - 1 })}
                >
                  Prev
                </button>
                <button
                  className="border rounded-md px-3 py-2 text-sm"
                  disabled={pagination.page >= pagination.totalPages || loading}
                  onClick={() => applyFilters({ page: pagination.page + 1 })}
                >
                  Next
                </button>
              </div>
            </div>
          </GlassCard>
        </div>
      </div>
    </div>
  )
}

