const router = require('express').Router()
const ctrl   = require('../controllers/sessionController')
const { authenticate } = require('../middleware/auth')

// Scan endpoint — no auth required
router.post('/scan', ctrl.handleScan)

// Protected routes
router.use(authenticate)
router.post  ('/sessions',                    ctrl.create)
router.get   ('/sessions',                    ctrl.list)
router.patch ('/sessions/:id/close',          ctrl.close)
router.post  ('/sessions/:id/join',           ctrl.join)
router.get   ('/session/:sessionId/students', ctrl.getStudents)
router.get   ('/attempts/:id/questions',      ctrl.getQuestions)
router.post  ('/attempts/:id/submit',         ctrl.submit)
router.get   ('/attempts/:id/result',         ctrl.getResult)


module.exports = router