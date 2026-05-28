// controllers/authController.js
const authService  = require('../services/authService')
const { asyncHandler } = require('../middleware/errorHandler')
const auditService = require('../services/auditService')


const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body
  if (!email || !password) {
    auditService.logEvent({
      req,
      actionType: 'LOGIN_FAILURE',
      module: 'auth',
      severity: 'warning',
      description: 'Missing email or password'
    })
    return res.status(400).json({
      success: false,
      message: 'Email and password are required'
    })
  }

  try {
    const data = await authService.loginWithPassword(email, password)

    auditService.logEvent({
      req,
      actionType: 'LOGIN_SUCCESS',
      module: 'auth',
      severity: 'info',
      description: `Login successful for ${email}`
    })

    res.json({ success: true, ...data })
  } catch (err) {
    auditService.logEvent({
      req,
      actionType: 'LOGIN_FAILURE',
      module: 'security',
      severity: 'warning',
      description: err?.message || 'Invalid email or password',
      targetType: 'user'
    })
    throw err
  }
})


const barcodeLogin = asyncHandler(async (req, res) => {
  const { barcode } = req.body
  if (!barcode) {
    auditService.logEvent({
      req,
      actionType: 'BARCODE_LOGIN_FAILURE',
      module: 'security',
      severity: 'warning',
      description: 'Missing barcode'
    })
    return res.status(400).json({
      success: false,
      message: 'Barcode value is required'
    })
  }

  try {
    const data = await authService.loginWithBarcode(barcode)
    auditService.logEvent({
      req,
      actionType: 'BARCODE_LOGIN_SUCCESS',
      module: 'auth',
      severity: 'info',
      description: `Barcode login success`
    })
    res.json({ success: true, ...data })
  } catch (err) {
    auditService.logEvent({
      req,
      actionType: 'BARCODE_LOGIN_FAILURE',
      module: 'security',
      severity: 'warning',
      description: err?.message || 'Student not found',
      targetType: 'student'
    })
    throw err
  }
})


const register = asyncHandler(async (req, res) => {
  const { name, email, password, role } = req.body
  if (!name || !email || !password) {
    auditService.logEvent({
      req,
      actionType: 'REGISTRATION_FAILURE',
      module: 'auth',
      severity: 'warning',
      description: 'Missing name/email/password'
    })
    return res.status(400).json({
      success: false,
      message: 'Name, email and password are required'
    })
  }

  try {
    const user = await authService.register(name, email, password, role)

    auditService.logEvent({
      req,
      actionType: 'REGISTRATION',
      module: 'auth',
      severity: 'info',
      description: `Registration created for ${email}`,
      targetType: 'user'
    })

    res.status(201).json({
      success: true,
      message: user.status === 'pending'
        ? 'Registration successful! Your account is pending admin approval.'
        : 'Account created successfully.',
      user
    })
  } catch (err) {
    auditService.logEvent({
      req,
      actionType: 'REGISTRATION_FAILURE',
      module: 'security',
      severity: 'warning',
      description: err?.message || 'Registration failed',
      targetType: 'user'
    })
    throw err
  }
})


const me = asyncHandler(async (req, res) => {
  res.json({ success: true, user: req.user })
})

// Admin only controllers
const getPending = asyncHandler(async (req, res) => {
  const users = await authService.getPendingUsers()
  res.json({ success: true, data: users })
})

const getAllUsers = asyncHandler(async (req, res) => {
  const users = await authService.getAllUsers()
  res.json({ success: true, data: users })
})

const approveUser = asyncHandler(async (req, res) => {
  const userId = +req.params.id
  const result = await authService.approveUser(userId)

  auditService.logEvent({
    req,
    actionType: 'USER_APPROVED',
    module: 'admin',
    severity: 'info',
    description: `User approved`,
    targetType: 'user',
    targetId: String(userId)
  })

  res.json({ success: true, ...result })
})


const rejectUser = asyncHandler(async (req, res) => {
  const userId = +req.params.id
  const result = await authService.rejectUser(userId)

  auditService.logEvent({
    req,
    actionType: 'USER_REJECTED',
    module: 'admin',
    severity: 'warning',
    description: `User rejected`,
    targetType: 'user',
    targetId: String(userId)
  })

  res.json({ success: true, ...result })
})


const deleteUser = asyncHandler(async (req, res) => {
  const userId = +req.params.id
  const result = await authService.deleteUser(userId)

  auditService.logEvent({
    req,
    actionType: 'USER_DELETED',
    module: 'admin',
    severity: 'critical',
    description: `User deleted`,
    targetType: 'user',
    targetId: String(userId)
  })

  res.json({ success: true, ...result })
})


module.exports = {
  login, barcodeLogin, register, me,
  getPending, getAllUsers, approveUser,
  rejectUser, deleteUser
}