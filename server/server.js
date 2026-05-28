require('dotenv').config()
const express = require('express')
const cors    = require('cors')
const { testConnection }              = require('./config/db')
const { errorHandler, requestLogger } = require('./middleware/errorHandler')
const { auditContext } = require('./middleware/auditContext')
const { auditAuthFailureLogger } = require('./middleware/auditAuthFailureLogger')


const authRoutes = require('./routes/auth')
const quizRoutes = require('./routes/quizzes')
const sessionRoutes = require('./routes/sessions')
const analyticsRoutes = require('./routes/analytics')
const auditRoutes = require('./routes/audit')


const app  = express()
const PORT = process.env.PORT || 5000

app.use(cors({
  origin: function(origin, callback) {
    // Allow same-network access from any device
    if (
      !origin ||
      origin.includes('localhost') ||
      origin.includes('127.0.0.1') ||
      origin.includes('192.168.') ||
      origin.includes('10.0.')    ||
      origin.includes('172.')
    ) {
      callback(null, true)
    } else {
      callback(new Error('Not allowed by CORS'))
    }
  },
  credentials: true
}))
app.use(express.json())
app.use(requestLogger)
app.use(auditContext)

// Routes
app.use('/api/auth', authRoutes)

app.use('/api/quizzes', quizRoutes)
app.use('/api', sessionRoutes)
app.use('/api/analytics', analyticsRoutes)
app.use('/api/audit', auditRoutes)


// Health check
app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', message: 'Scan2Quiz API is running' })
})

// 404
app.use((_req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' })
})

// Error handler + audit auth failures
app.use(auditAuthFailureLogger)
app.use(errorHandler)

async function start() {
  await testConnection()
  app.listen(PORT, '0.0.0.0', () => {
    const os      = require('os')
    const ifaces  = os.networkInterfaces()
    let localIP   = 'localhost'
    for (const iface of Object.values(ifaces)) {
      for (const alias of iface) {
        if (alias.family === 'IPv4' && !alias.internal) {
          localIP = alias.address
        }
      }
    }
    console.log(` Server → http://localhost:${PORT}`)
    console.log(` Phone  → http://${localIP}:${PORT}`)
  })
}
start()
