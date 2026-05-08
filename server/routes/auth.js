const router = require('express').Router()
const ctrl   = require('../controllers/authController')
const { authenticate } = require('../middleware/auth')

router.post('/login',         ctrl.login)
router.post('/barcode-login', ctrl.barcodeLogin)
router.post('/register',      ctrl.register)
router.get ('/me', authenticate, ctrl.me)

module.exports = router