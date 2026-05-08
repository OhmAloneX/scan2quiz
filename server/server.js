require('dotenv').config()
const express = require('express')
const cors    = require('cors')
const { testConnection }              = require('./config/db')
const { errorHandler, requestLogger } = require('./middleware/errorHandler')

const authRoutes = require('./routes/auth')
const quizRoutes = require('./routes/quizzes')
const sessionRoutes = require('./routes/sessions')
const analyticsRoutes = require('./routes/analytics')

const app  = express()
const PORT = process.env.PORT || 5000

app.use(cors({ origin: process.env.CLIENT_URL || 'http://localhost:3000' }))
app.use(express.json())
app.use(requestLogger)

// Routes
app.use('/api/auth', authRoutes)
app.use('/api/quizzes', quizRoutes)
app.use('/api', sessionRoutes)
app.use('/api/analytics', analyticsRoutes)

// Health check
app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', message: 'Scan2Quiz API is running' })
})

// 404
app.use((_req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' })
})

// Error handler
app.use(errorHandler)

async function start() {
  await testConnection()
  app.listen(PORT, () => {
    console.log(`Server running → http://localhost:${PORT}`)
  })
}

start()