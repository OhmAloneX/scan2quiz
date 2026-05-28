const { query } = require('../config/db')

// Non-blocking + error-safe audit logger.
// IMPORTANT: This must never break business logic.
async function insertAuditLog(row) {
  const {
    userId,
    role,
    actionType,
    module,
    description,
    targetId,
    targetType,
    ipAddress,
    userAgent,
    severity
  } = row

  return query(
    `INSERT INTO audit_logs
      (user_id, role, action_type, module, description,
       target_id, target_type, ip_address, user_agent, severity)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      userId || null,
      role || null,
      actionType,
      module,
      description || null,
      targetId || null,
      targetType || null,
      ipAddress || null,
      userAgent || null,
      severity || 'info'
    ]
  )
}

function buildFromReq({ req, actionType, module, description, targetId, targetType, severity }) {
  const user = req?.user
  return {
    userId: user?.id,
    role: user?.role,
    actionType,
    module,
    description,
    targetId,
    targetType,
    ipAddress: req?.auditContext?.ipAddress,
    userAgent: req?.auditContext?.userAgent,
    severity
  }
}

function logEvent({ req, actionType, module, description, targetId, targetType, severity }) {
  const row = buildFromReq({ req, actionType, module, description, targetId, targetType, severity })

  // Fire-and-forget. Never await.
  insertAuditLog(row)
    .catch((err) => {
      // Never throw; just surface for dev visibility.
      console.error('[AUDIT_LOG_ERROR]', err?.message || err)
    })
}

module.exports = {
  logEvent
}

