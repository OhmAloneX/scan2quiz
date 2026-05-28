const { logEvent } = require('../services/auditService')

function auditAuthFailureLogger(err, req, res, next) {
  // We only care about auth errors produced by jwt verify / missing token.
  // This middleware must be placed AFTER routes so it sees them.

  try {
    const actionType =
      err?.message === 'Token expired'
        ? 'TOKEN_EXPIRED'
        : 'AUTH_INVALID_TOKEN'

    logEvent({
      req,
      actionType,
      module: 'security',
      severity: err?.status === 401 ? 'warning' : 'critical',
      description: err?.message || 'Authentication error',
      targetType: 'auth'
    })
  } catch {
    // never break request
  }

  next(err)
}

module.exports = { auditAuthFailureLogger }

