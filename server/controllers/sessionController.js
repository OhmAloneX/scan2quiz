const sessionService = require('../services/sessionService')
const gradingService  = require('../services/gradingService')
const { asyncHandler } = require('../middleware/errorHandler')

const create = asyncHandler(async (req, res) => {
  const { quizId } = req.body
  if (!quizId) return res.status(400).json({
    success: false, message: 'quizId is required'
  })
  const session = await sessionService.createSession(
    +quizId, req.user.id)
  res.status(201).json({ success: true, data: session })
})

const list = asyncHandler(async (req, res) => {
  const sessions = await sessionService.getSessionsByTeacher(req.user.id)
  res.json({ success: true, data: sessions })
})

const close = asyncHandler(async (req, res) => {
  const result = await sessionService.closeSession(
    +req.params.id, req.user.id)
  res.json({ success: true, ...result })
})

const handleScan = asyncHandler(async (req, res) => {
  const { type, value } = req.body
  if (!type || !value) return res.status(400).json({
    success: false, message: 'type and value required'
  })
  const result = await sessionService.handleScan(type, value)
  res.json(result)
})

const join = asyncHandler(async (req, res) => {
  const attempt = await gradingService.joinSession(
    +req.params.id, req.user.id)
  res.json({ success: true, data: attempt })
})

const getQuestions = asyncHandler(async (req, res) => {
  const questions = await gradingService.getAttemptQuestions(
    +req.params.id, req.user.id)
  res.json({ success: true, data: questions })
})

const submit = asyncHandler(async (req, res) => {
  const { answers } = req.body
  if (!Array.isArray(answers)) return res.status(400).json({
    success: false, message: 'answers array required'
  })
  const result = await gradingService.submitAttempt(
    +req.params.id, req.user.id, answers)
  res.json({ success: true, data: result })
})

const getResult = asyncHandler(async (req, res) => {
  const result = await gradingService.getAttemptResult(
    +req.params.id, req.user.id)
  res.json({ success: true, data: result })
})

module.exports = {
  create, list, close, handleScan,
  join, getQuestions, submit, getResult
}