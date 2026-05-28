const quizService = require('../services/quizService')
const { asyncHandler } = require('../middleware/errorHandler')
const auditService = require('../services/auditService')


const getAll = asyncHandler(async (req, res) => {
  const quizzes = await quizService.getAllQuizzes(req.user.id)
  res.json({ success: true, data: quizzes })
})

const getOne = asyncHandler(async (req, res) => {
  const quiz = await quizService.getQuizById(
    +req.params.id, req.user.id)
  res.json({ success: true, data: quiz })
})

const create = asyncHandler(async (req, res) => {
  const quiz = await quizService.createQuiz(req.user.id, req.body)

  auditService.logEvent({
    req,
    actionType: 'QUIZ_CREATED',
    module: 'quiz',
    severity: 'info',
    description: `Quiz created: ${quiz.title}`,
    targetType: 'quiz',
    targetId: String(quiz.id)
  })

  res.status(201).json({ success: true, data: quiz })
})


const update = asyncHandler(async (req, res) => {
  const quiz = await quizService.updateQuiz(
    +req.params.id, req.user.id, req.body)

  auditService.logEvent({
    req,
    actionType: 'QUIZ_UPDATED',
    module: 'quiz',
    severity: 'info',
    description: `Quiz updated: ${quiz.title}`,
    targetType: 'quiz',
    targetId: String(quiz.id)
  })

  res.json({ success: true, data: quiz })
})


const remove = asyncHandler(async (req, res) => {
  const quizId = +req.params.id
  await quizService.deleteQuiz(quizId, req.user.id)

  auditService.logEvent({
    req,
    actionType: 'QUIZ_DELETED',
    module: 'quiz',
    severity: 'critical',
    description: 'Quiz deleted',
    targetType: 'quiz',
    targetId: String(quizId)
  })

  res.json({ success: true, message: 'Quiz deleted' })
})


const addQuestion = asyncHandler(async (req, res) => {
  const quizId = +req.params.id
  const q = await quizService.addQuestion(
    quizId, req.user.id, req.body)

  auditService.logEvent({
    req,
    actionType: 'QUESTION_ADDED',
    module: 'quiz',
    severity: 'info',
    description: 'Question added',
    targetType: 'question',
    targetId: String(q.id)
  })

  res.status(201).json({ success: true, data: q })
})


const deleteQuestion = asyncHandler(async (req, res) => {
  const questionId = +req.params.questionId
  await quizService.deleteQuestion(questionId, req.user.id)

  auditService.logEvent({
    req,
    actionType: 'QUESTION_REMOVED',
    module: 'quiz',
    severity: 'warning',
    description: 'Question removed',
    targetType: 'question',
    targetId: String(questionId)
  })

  res.json({ success: true, message: 'Question deleted' })
})


module.exports = {
  getAll, getOne, create, update,
  remove, addQuestion, deleteQuestion
}