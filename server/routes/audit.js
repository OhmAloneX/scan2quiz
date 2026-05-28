const router = require('express').Router()
const { authenticate, requireRole } = require('../middleware/auth')
const ctrl = require('../controllers/auditController')

router.use(authenticate)

// Admin + teacher only
router.get('/logs', requireRole('admin', 'teacher'), ctrl.listLogs)
router.get('/summary', requireRole('admin', 'teacher'), ctrl.summary)
router.get('/security-alerts', requireRole('admin', 'teacher'), ctrl.securityAlerts)

module.exports = router

