const router = require('express').Router()
const ctrl = require('../controllers/studentController')
const { authenticate } = require('../middleware/auth')

router.use(authenticate)

router.get   ('/',              ctrl.getAll)
router.post  ('/',              ctrl.create)
router.get   ('/:id',           ctrl.getOne)
router.put   ('/:id',           ctrl.update)
router.delete('/:id',           ctrl.remove)

module.exports = router