// controllers/authController.js
const authService  = require('../services/authService')
const { asyncHandler } = require('../middleware/errorHandler')

const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body
  if (!email || !password) {
    return res.status(400).json({
      success: false,
      message: 'Email and password are required'
    })
  }
  const data = await authService.loginWithPassword(email, password)
  res.json({ success: true, ...data })
})

const barcodeLogin = asyncHandler(async (req, res) => {
  const { barcode } = req.body
  if (!barcode) {
    return res.status(400).json({
      success: false,
      message: 'Barcode value is required'
    })
  }
  const data = await authService.loginWithBarcode(barcode)
  res.json({ success: true, ...data })
})

const register = asyncHandler(async (req, res) => {
  const { name, email, password, role } = req.body
  if (!name || !email || !password) {
    return res.status(400).json({
      success: false,
      message: 'Name, email and password are required'
    })
  }
  const user = await authService.register(name, email, password, role)
  res.status(201).json({
    success: true,
    message: user.status === 'pending'
      ? 'Registration successful! Your account is pending admin approval.'
      : 'Account created successfully.',
    user
  })
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
  const result = await authService.approveUser(+req.params.id)
  res.json({ success: true, ...result })
})

const rejectUser = asyncHandler(async (req, res) => {
  const result = await authService.rejectUser(+req.params.id)
  res.json({ success: true, ...result })
})

const deleteUser = asyncHandler(async (req, res) => {
  const result = await authService.deleteUser(+req.params.id)
  res.json({ success: true, ...result })
})

module.exports = {
  login, barcodeLogin, register, me,
  getPending, getAllUsers, approveUser,
  rejectUser, deleteUser
}