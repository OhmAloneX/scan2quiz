const quizService = require('../services/quizService')
const { asyncHandler } = require('../middleware/errorHandler')

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
  res.status(201).json({ success: true, data: quiz })
})

const update = asyncHandler(async (req, res) => {
  const quiz = await quizService.updateQuiz(
    +req.params.id, req.user.id, req.body)
  res.json({ success: true, data: quiz })
})

const remove = asyncHandler(async (req, res) => {
  await quizService.deleteQuiz(+req.params.id, req.user.id)
  res.json({ success: true, message: 'Quiz deleted' })
})

const addQuestion = asyncHandler(async (req, res) => {
  const q = await quizService.addQuestion(
    +req.params.id, req.user.id, req.body)
  res.status(201).json({ success: true, data: q })
})

const deleteQuestion = asyncHandler(async (req, res) => {
  await quizService.deleteQuestion(
    +req.params.questionId, req.user.id)
  res.json({ success: true, message: 'Question deleted' })
})

module.exports = {
  getAll, getOne, create, update,
  remove, addQuestion, deleteQuestion
}