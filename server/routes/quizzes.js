const router = require('express').Router()
const ctrl   = require('../controllers/quizController')
const { authenticate } = require('../middleware/auth')

router.use(authenticate)

router.get   ('/',                        ctrl.getAll)
router.post  ('/',                        ctrl.create)
router.get   ('/:id',                     ctrl.getOne)
router.put   ('/:id',                     ctrl.update)
router.delete('/:id',                     ctrl.remove)
router.post  ('/:id/questions',           ctrl.addQuestion)
router.delete('/:id/questions/:questionId', ctrl.deleteQuestion)
router.put   ('/:id/questions/:questionId', ctrl.updateQuestion)

module.exports = router
