function asyncHandler(fn) {
  return (req, res, next) =>
    Promise.resolve(fn(req, res, next)).catch(next)
}

function errorHandler(err, req, res, _next) {
  console.error(`[ERROR] ${req.method} ${req.path} →`, err.message)

  if (err.code === 'ER_DUP_ENTRY') {
    return res.status(409).json({
      success: false,
      message: 'Record already exists'
    })
  }

  if (err.status) {
    return res.status(err.status).json({
      success: false,
      message: err.message
    })
  }

  res.status(500).json({
    success: false,
    message: 'Internal server error'
  })
}

function requestLogger(req, _res, next) {
  const ts = new Date().toISOString().slice(11, 19)
  console.log(`[${ts}] ${req.method.padEnd(6)} ${req.path}`)
  next()
}

module.exports = { asyncHandler, errorHandler, requestLogger }