import api from './api'

const auditService = {
  async getLogs({
    page = 1,
    limit = 20,
    action_type,
    module,
    severity,
    target_type,
    from,
    to,
    q
  } = {}) {
    const params = new URLSearchParams()

    params.set('page', page)
    params.set('limit', limit)

    if (action_type) params.set('action_type', action_type)
    if (module) params.set('module', module)
    if (severity) params.set('severity', severity)
    if (target_type) params.set('target_type', target_type)
    if (from) params.set('from', from)
    if (to) params.set('to', to)
    if (q) params.set('q', q)

    const res = await api.get(`/audit/logs?${params.toString()}`)
    return res.data
  },

  async getSummary() {
    const res = await api.get('/audit/summary')
    return res.data
  },

  async getSecurityAlerts() {
    const res = await api.get('/audit/security-alerts')
    return res.data
  }
}

export default auditService

