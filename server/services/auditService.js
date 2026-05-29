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

  // FK safety: audit_logs.user_id references users(id)
  // The app sometimes has a user-like id from other tables (e.g. students).
  // We validate existence; if missing, we insert NULL to avoid FK crash.
  if (!userId) {
    return query(
      `INSERT INTO audit_logs
        (user_id, role, action_type, module, description,
         target_id, target_type, ip_address, user_agent, severity)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        null,
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

  const [{ exists } = {}] = await (async () => {
    const rows = await query('SELECT 1 AS exists FROM users WHERE id = ? LIMIT 1', [userId])
    return rows
  })()

  const safeUserId = exists ? userId : null

  return query(
    `INSERT INTO audit_logs
      (user_id, role, action_type, module, description,
       target_id, target_type, ip_address, user_agent, severity)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      safeUserId,
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
  insertAuditLog(row).catch((err) => {
    // Never throw; just surface for dev visibility.
    // Also ensure FK/user_id mismatch never breaks the request.
    console.error('[AUDIT_LOG_ERROR]', {
      message: err?.message || String(err),
      code: err?.code,
      errno: err?.errno,
      userId: row?.userId ?? null,
      actionType: row?.actionType,
      module: row?.module,
    })
  })
}

module.exports = {
  logEvent
}

