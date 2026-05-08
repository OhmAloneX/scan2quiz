const router = require('express').Router()
const ctrl   = require('../controllers/analyticsController')
const { authenticate } = require('../middleware/auth')

router.use(authenticate)

router.get('/dashboard',      ctrl.dashboard)
router.get('/trend',          ctrl.trend)
router.get('/distribution',   ctrl.distribution)
router.get('/quiz/:id',       ctrl.quizStats)
router.get('/top-students',   ctrl.topStudents)

module.exports = router