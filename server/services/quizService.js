const { query } = require('../config/db')

async function getAllQuizzes(teacherId) {
  return query(
    `SELECT q.id, q.title, q.description, q.subject,
            q.time_limit, q.passing_score, q.is_active, q.created_at,
            COUNT(DISTINCT qu.id) AS question_count,
            COUNT(DISTINCT s.id)  AS session_count
     FROM quizzes q
     LEFT JOIN questions qu ON qu.quiz_id = q.id
     LEFT JOIN sessions  s  ON s.quiz_id  = q.id
     WHERE q.teacher_id = ?
     GROUP BY q.id
     ORDER BY q.created_at DESC`,
    [teacherId]
  )
}

async function getQuizById(quizId, teacherId) {
  const [quiz] = await query(
    'SELECT * FROM quizzes WHERE id = ? AND teacher_id = ?',
    [quizId, teacherId]
  )
  if (!quiz) throw { status: 404, message: 'Quiz not found' }

  const questions = await query(
    `SELECT q.id, q.question_text, q.type, q.points, q.order_index
     FROM questions q
     WHERE q.quiz_id = ?
     ORDER BY q.order_index`,
    [quizId]
  )

  for (let q of questions) {
    q.choices = await query(
      `SELECT id, choice_text, is_correct, order_index
       FROM choices WHERE question_id = ?
       ORDER BY order_index`,
      [q.id]
    )
  }

  quiz.questions = questions
  return quiz
}

async function createQuiz(teacherId, { title, description,
  subject, time_limit, passing_score }) {
  if (!title?.trim()) throw { status: 400, message: 'Title is required' }

  const result = await query(
    `INSERT INTO quizzes
     (teacher_id, title, description, subject, time_limit, passing_score)
     VALUES (?, ?, ?, ?, ?, ?)`,
    [teacherId, title.trim(), description || '',
     subject || '', time_limit || 30, passing_score || 75]
  )
  return { id: result.insertId, title, description,
           subject, time_limit, passing_score }
}

async function updateQuiz(quizId, teacherId, fields) {
  const { title, description, subject,
          time_limit, passing_score, is_active } = fields
  await query(
    `UPDATE quizzes SET
       title         = COALESCE(?, title),
       description   = COALESCE(?, description),
       subject       = COALESCE(?, subject),
       time_limit    = COALESCE(?, time_limit),
       passing_score = COALESCE(?, passing_score),
       is_active     = COALESCE(?, is_active)
     WHERE id = ? AND teacher_id = ?`,
    [title, description, subject,
     time_limit, passing_score, is_active, quizId, teacherId]
  )
  return getQuizById(quizId, teacherId)
}

async function deleteQuiz(quizId, teacherId) {
  const result = await query(
    'DELETE FROM quizzes WHERE id = ? AND teacher_id = ?',
    [quizId, teacherId]
  )
  if (result.affectedRows === 0)
    throw { status: 404, message: 'Quiz not found' }
}

async function addQuestion(quizId, teacherId,
  { question_text, type, points, choices, order_index }) {
  const [quiz] = await query(
    'SELECT id FROM quizzes WHERE id = ? AND teacher_id = ?',
    [quizId, teacherId]
  )
  if (!quiz) throw { status: 404, message: 'Quiz not found' }
  if (!question_text?.trim())
    throw { status: 400, message: 'Question text is required' }

  const result = await query(
    `INSERT INTO questions
     (quiz_id, question_text, type, points, order_index)
     VALUES (?, ?, ?, ?, ?)`,
    [quizId, question_text.trim(),
     type || 'multiple_choice', points || 1, order_index || 0]
  )
  const questionId = result.insertId

  if (Array.isArray(choices) && choices.length) {
    for (const c of choices) {
      await query(
        `INSERT INTO choices (question_id, choice_text, is_correct)
         VALUES (?, ?, ?)`,
        [questionId, c.text, c.isCorrect ? 1 : 0]
      )
    }
  }

  return { id: questionId, quizId, question_text, type, points, choices }
}

async function deleteQuestion(questionId, teacherId) {
  const [q] = await query(
    `SELECT qu.id FROM questions qu
     JOIN quizzes qz ON qz.id = qu.quiz_id
     WHERE qu.id = ? AND qz.teacher_id = ?`,
    [questionId, teacherId]
  )
  if (!q) throw { status: 404, message: 'Question not found' }
  await query('DELETE FROM questions WHERE id = ?', [questionId])
}

module.exports = {
  getAllQuizzes, getQuizById, createQuiz,
  updateQuiz, deleteQuiz, addQuestion, deleteQuestion
}