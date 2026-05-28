const sessionService = require('../services/sessionService')
const gradingService  = require('../services/gradingService')
const { asyncHandler } = require('../middleware/errorHandler')
const auditService = require('../services/auditService')


const create = asyncHandler(async (req, res) => {
  const { quizId } = req.body
  if (!quizId) {
    return res.status(400).json({
      success: false, message: 'quizId is required'
    })
  }
  const session = await sessionService.createSession(
    +quizId, req.user.id)

  auditService.logEvent({
    req,
    actionType: 'SESSION_CREATED',
    module: 'session',
    severity: 'info',
    description: 'Session created',
    targetType: 'session',
    targetId: String(session.id)
  })

  res.status(201).json({ success: true, data: session })
})


const list = asyncHandler(async (req, res) => {
  const sessions = await sessionService.getSessionsByTeacher(req.user.id)
  res.json({ success: true, data: sessions })
})

const close = asyncHandler(async (req, res) => {
  const sessionId = +req.params.id
  const result = await sessionService.closeSession(
    sessionId, req.user.id)

  auditService.logEvent({
    req,
    actionType: 'SESSION_CLOSED',
    module: 'session',
    severity: 'warning',
    description: 'Session closed',
    targetType: 'session',
    targetId: String(sessionId)
  })

  res.json({ success: true, ...result })
})


const handleScan = asyncHandler(async (req, res) => {
const { type, value, sessionCode, sessionId } = req.body
  if (!type || !value) {
    return res.status(400).json({
      success: false, message: 'type and value required'
    })
  }

  try {
    const result = await sessionService.handleScan(type, value, { sessionCode, sessionId })

    if (type === 'QR_CODE') {
      auditService.logEvent({
        req,
        actionType: result?.success ? 'QR_VALID' : 'SECURITY_INVALID_QR',
        module: 'security',
        severity: result?.success ? 'info' : 'warning',
        description: result?.success ? 'Valid QR session found' : 'Invalid QR attempt',
        targetType: 'session'
      })
    }

    if (type === 'barcode') {
      auditService.logEvent({
        req,
        actionType: result?.success ? 'BARCODE_VALID' : 'SECURITY_INVALID_BARCODE',
        module: 'security',
        severity: result?.success ? 'info' : 'warning',
        description: result?.success ? 'Valid student identified by barcode' : 'Invalid barcode attempt',
        targetType: 'student'
      })
    }

    res.json(result)
  } catch (err) {
    // QR parse failures / invalid QR payload
    auditService.logEvent({
      req,
      actionType: 'SECURITY_INVALID_QR',
      module: 'security',
      severity: 'warning',
      description: err?.message || 'Invalid QR attempt',
      targetType: 'session'
    })
    throw err
  }
})


const join = asyncHandler(async (req, res) => {
  const sessionId = +req.params.id
  const attempt = await gradingService.joinSession(
    sessionId, req.user.id)

  // multiple attempt detection: gradingService.joinSession returns existing
  auditService.logEvent({
    req,
    actionType: attempt?.status === 'in_progress' ? 'STUDENT_JOINED_SESSION' : 'STUDENT_JOINED_SESSION',
    module: 'session',
    severity: attempt?.status === 'in_progress' ? 'info' : 'warning',
    description: 'Student joined/started attempt',
    targetType: 'attempt',
    targetId: String(attempt?.id)
  })

  res.json({ success: true, data: attempt })
})


const getQuestions = asyncHandler(async (req, res) => {
  const questions = await gradingService.getAttemptQuestions(
    +req.params.id, req.user.id)
  res.json({ success: true, data: questions })
})

const submit = asyncHandler(async (req, res) => {
  const attemptId = +req.params.id
  const { answers } = req.body
  if (!Array.isArray(answers)) {
    return res.status(400).json({
      success: false, message: 'answers array required'
    })
  }

  const result = await gradingService.submitAttempt(
    attemptId, req.user.id, answers)

  auditService.logEvent({
    req,
    actionType: 'QUIZ_SUBMITTED',
    module: 'student',
    severity: 'info',
    description: `Attempt graded: score=${result?.score}`,
    targetType: 'attempt',
    targetId: String(attemptId)
  })

  res.json({ success: true, data: result })
})


const getResult = asyncHandler(async (req, res) => {
  const result = await gradingService.getAttemptResult(
    +req.params.id, req.user.id)
  res.json({ success: true, data: result })
})

const getStudents = asyncHandler(async (req, res) => {
  const sessionId = +req.params.sessionId
  const students = await sessionService.getSessionParticipants(sessionId)
  res.json({ success: true, students })
})

module.exports = {
  create, list, close, handleScan,
  join, getQuestions, submit, getResult,
  getStudents
}
