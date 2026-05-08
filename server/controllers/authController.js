const authService = require('../services/authService')
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
  res.status(201).json({ success: true, user })
})

const me = asyncHandler(async (req, res) => {
  res.json({ success: true, user: req.user })
})

module.exports = { login, barcodeLogin, register, me }