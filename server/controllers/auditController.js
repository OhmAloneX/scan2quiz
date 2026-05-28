const auditService = require('../services/auditService')
const { query } = require('../config/db')

function parseDate(d) {
  if (!d) return null
  const dt = new Date(d)
  if (Number.isNaN(dt.getTime())) return null
  return dt
}

async function listLogs(req, res) {
  const page  = Math.max(1, parseInt(req.query.page || '1', 10))
  const limit = Math.min(100, Math.max(10, parseInt(req.query.limit || '20', 10)))
  const offset = (page - 1) * limit

  const {
    action_type,
    module,
    severity,
    from,
    to,
    q,
    target_type
  } = req.query

  const where = []
  const params = []

  if (action_type) {
    where.push('action_type = ?')
    params.push(action_type)
  }
  if (module) {
    where.push('module = ?')
    params.push(module)
  }
  if (severity) {
    where.push('severity = ?')
    params.push(severity)
  }
  if (target_type) {
    where.push('target_type = ?')
    params.push(target_type)
  }

  const fromDt = parseDate(from)
  const toDt   = parseDate(to)
  if (fromDt) {
    where.push('created_at >= ?')
    params.push(fromDt)
  }
  if (toDt) {
    // include full day range if date-only is passed
    where.push('created_at <= ?')
    params.push(toDt)
  }

  if (q) {
    where.push('(description LIKE ? OR target_id LIKE ? OR action_type LIKE ? OR module LIKE ?)')
    const like = `%${q}%`
    params.push(like, like, like, like)
  }

  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : ''

  const rows = await query(
    `SELECT id, user_id, role, action_type, module, description,
            target_id, target_type, ip_address, user_agent,
            severity, created_at
     FROM audit_logs
     ${whereSql}
     ORDER BY created_at DESC
     LIMIT ? OFFSET ?`,
    [...params, limit, offset]
  )

  const total = await query(
    `SELECT COUNT(*) AS cnt
     FROM audit_logs
     ${whereSql}`,
    params
  )

  res.json({
    success: true,
    data: {
      logs: rows,
      pagination: {
        page,
        limit,
        total: total[0]?.cnt || 0,
        totalPages: Math.ceil((total[0]?.cnt || 0) / limit)
      }
    }
  })
}

async function summary(req, res) {
  // Simple widgets based on latest audit data (admin+teacher scope is same: view all)
  const recent = await query(
    `SELECT COUNT(*) AS cnt
     FROM audit_logs
     WHERE created_at >= (NOW() - INTERVAL 24 HOUR)`
  )

  const failedLogins = await query(
    `SELECT COUNT(*) AS cnt
     FROM audit_logs
     WHERE action_type IN ('LOGIN_FAILURE','BARCODE_LOGIN_FAILURE')
       AND created_at >= (NOW() - INTERVAL 7 DAY)`
  )

  const securityCritical = await query(
    `SELECT COUNT(*) AS cnt
     FROM audit_logs
     WHERE severity = 'critical'
       AND module = 'security'
       AND created_at >= (NOW() - INTERVAL 7 DAY)`
  )

  // Most active users (by log count in last 7 days)
  const mostActive = await query(
    `SELECT user_id, role, COUNT(*) AS cnt
     FROM audit_logs
     WHERE created_at >= (NOW() - INTERVAL 7 DAY)
       AND user_id IS NOT NULL
     GROUP BY user_id, role
     ORDER BY cnt DESC
     LIMIT 5`
  )

  // Daily activity counts for last 14 days
  const daily = await query(
    `SELECT DATE(created_at) AS day, COUNT(*) AS cnt
     FROM audit_logs
     WHERE created_at >= (NOW() - INTERVAL 14 DAY)
     GROUP BY DATE(created_at)
     ORDER BY day ASC`
  )

  res.json({
    success: true,
    data: {
      recent24h: recent[0]?.cnt || 0,
      failedLogins7d: failedLogins[0]?.cnt || 0,
      securityCritical7d: securityCritical[0]?.cnt || 0,
      mostActive,
      daily
    }
  })
}

async function securityAlerts(req, res) {
  const rows = await query(
    `SELECT id, user_id, role, action_type, module, description,
            target_id, target_type, ip_address, user_agent,
            severity, created_at
     FROM audit_logs
     WHERE module = 'security'
       AND (severity = 'critical' OR severity = 'warning')
     ORDER BY created_at DESC
     LIMIT 50`
  )

  res.json({ success: true, data: rows })
}

module.exports = { listLogs, summary, securityAlerts }

