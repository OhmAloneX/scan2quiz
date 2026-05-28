function getClientIp(req) {
  // If behind a proxy/load balancer
  const xff = req.headers['x-forwarded-for']
  if (typeof xff === 'string' && xff.length > 0) {
    // XFF can contain a list: client, proxy1, proxy2
    return xff.split(',')[0].trim()
  }

  // Express populates req.ip
  return req.ip || ''
}

module.exports = { getClientIp }

