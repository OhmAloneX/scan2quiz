const jwt = require('jsonwebtoken')

function authenticate(req, res, next) {
  const authHeader = req.headers.authorization

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      message: 'No token provided'
    })
  }

  const token = authHeader.split(' ')[1]

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET)
    req.user = decoded
    next()
  } catch (err) {
    const msg = err.name === 'TokenExpiredError'
      ? 'Token expired'
      : 'Invalid token'
    return res.status(401).json({ success: false, message: msg })
  }
}

function requireRole(...roles) {
  return (req, res, next) => {
    if (!roles.includes(req.user?.role)) {
      return res.status(403).json({
        success: false,
        message: 'Access forbidden'
      })
    }
    next()
  }
}

module.exports = { authenticate, requireRole }