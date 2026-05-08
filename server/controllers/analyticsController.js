const analyticsService = require('../services/analyticsService')
const { asyncHandler }  = require('../middleware/errorHandler')

const dashboard = asyncHandler(async (req, res) => {
  const stats = await analyticsService.getDashboardStats(req.user.id)
  res.json({ success: true, data: stats })
})

const trend = asyncHandler(async (req, res) => {
  const data = await analyticsService.getMonthlyTrend(req.user.id)
  res.json({ success: true, data })
})

const distribution = asyncHandler(async (req, res) => {
  const data = await analyticsService.getScoreDistribution(req.user.id)
  res.json({ success: true, data })
})

const quizStats = asyncHandler(async (req, res) => {
  const data = await analyticsService.getQuizAnalytics(
    +req.params.id, req.user.id)
  res.json({ success: true, data })
})

const topStudents = asyncHandler(async (req, res) => {
  const limit = Math.min(+req.query.limit || 10, 50)
  const data  = await analyticsService.getTopStudents(req.user.id, limit)
  res.json({ success: true, data })
})

module.exports = { dashboard, trend, distribution, quizStats, topStudents }