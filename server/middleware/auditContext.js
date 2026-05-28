const { getClientIp } = require('../utils/ipUtils')

function auditContext(req, _res, next) {
  const userAgent = req.headers['user-agent'] || ''
  const ipAddress  = getClientIp(req)

  req.auditContext = {
    ipAddress,
    userAgent
  }

  next()
}

module.exports = { auditContext }


