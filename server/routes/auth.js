// routes/auth.js
const router = require('express').Router()
const ctrl   = require('../controllers/authController')
const { authenticate, requireRole } = require('../middleware/auth')

// Public routes
router.post('/login',         ctrl.login)
router.post('/barcode-login', ctrl.barcodeLogin)
router.post('/register',      ctrl.register)

// Protected — any logged in user
router.get('/me', authenticate, ctrl.me)

// Admin only routes
router.get(
  '/users',
  authenticate,
  requireRole('admin'),
  ctrl.getAllUsers
)
router.get(
  '/users/pending',
  authenticate,
  requireRole('admin'),
  ctrl.getPending
)
router.patch(
  '/users/:id/approve',
  authenticate,
  requireRole('admin'),
  ctrl.approveUser
)
router.patch(
  '/users/:id/reject',
  authenticate,
  requireRole('admin'),
  ctrl.rejectUser
)
router.delete(
  '/users/:id',
  authenticate,
  requireRole('admin'),
  ctrl.deleteUser
)

module.exports = router