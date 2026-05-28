const analyticsService = require('../services/analyticsService')
const { asyncHandler } = require('../middleware/errorHandler')

const dashboard = asyncHandler(async (req, res) => {
  try {
    const stats = await analyticsService.getDashboardStats(req.user.id)
    res.json({ success: true, data: stats })
  } catch (err) {
    console.error('[ANALYTICS_DASHBOARD_ERROR]', err)
    res.json({
      success: true,
      data: {
        total_quizzes: 0,
        total_sessions: 0,
        total_attempts: 0,
        avg_score: 0,
        highest_score: 0,
        unique_students: 0
      }
    })
  }
})

const trend = asyncHandler(async (req, res) => {
  try {
    const data = await analyticsService.getMonthlyTrend(req.user.id)
    res.json({ success: true, data })
  } catch (err) {
    console.error('[ANALYTICS_TREND_ERROR]', err)
    res.json({ success: true, data: [] })
  }
})

const distribution = asyncHandler(async (req, res) => {
  try {
    const data = await analyticsService.getScoreDistribution(req.user.id)
    res.json({ success: true, data })
  } catch (err) {
    console.error('[ANALYTICS_DISTRIBUTION_ERROR]', err)
    res.json({
      success: true,
      data: [{
        score_90_100: 0,
        score_75_89: 0,
        score_60_74: 0,
        score_below_60: 0,
        total: 0
      }]
    })
  }
})

const quizStats = asyncHandler(async (req, res) => {
  try {
    const data = await analyticsService.getQuizAnalytics(+req.params.id, req.user.id)
    res.json({ success: true, data })
  } catch (err) {
    console.error('[ANALYTICS_QUIZ_STATS_ERROR]', err)
    res.json({ success: true, data: { quiz: null, sessions: [], questionStats: [] } })
  }
})

const topStudents = asyncHandler(async (req, res) => {
  try {
    const limit = Math.min(+req.query.limit || 10, 50)
    const data = await analyticsService.getTopStudents(req.user.id, limit)
    res.json({ success: true, data })
  } catch (err) {
    console.error('[ANALYTICS_TOP_STUDENTS_ERROR]', err)
    res.json({ success: true, data: [] })
  }
})

module.exports = { dashboard, trend, distribution, quizStats, topStudents }

