const { query } = require('../config/db')

async function joinSession(sessionId, studentId) {
  const [session] = await query(
    `SELECT id, quiz_id FROM sessions
     WHERE id = ? AND status = 'open'`,
    [sessionId]
  )
  if (!session) throw { status: 410, message: 'Session is not open' }

  const [existing] = await query(
    `SELECT id, status FROM attempts
     WHERE session_id = ? AND student_id = ?`,
    [sessionId, studentId]
  )
  if (existing) return existing

  const result = await query(
    'INSERT INTO attempts (session_id, student_id) VALUES (?, ?)',
    [sessionId, studentId]
  )
  return { id: result.insertId, sessionId, studentId, status: 'in_progress' }
}

async function getAttemptQuestions(attemptId, studentId) {
  const [attempt] = await query(
    `SELECT a.*, s.quiz_id FROM attempts a
     JOIN sessions s ON s.id = a.session_id
     WHERE a.id = ? AND a.student_id = ?`,
    [attemptId, studentId]
  )
  if (!attempt) throw { status: 404, message: 'Attempt not found' }

  const questions = await query(
    `SELECT id, question_text, type, points, order_index
     FROM questions WHERE quiz_id = ?
     ORDER BY order_index`,
    [attempt.quiz_id]
  )

  for (let q of questions) {
    q.choices = await query(
      `SELECT id, choice_text FROM choices
       WHERE question_id = ? ORDER BY order_index`,
      [q.id]
    )
  }

  return questions
}

async function submitAttempt(attemptId, studentId, answers) {
  const [attempt] = await query(
    `SELECT * FROM attempts
     WHERE id = ? AND student_id = ? AND status = 'in_progress'`,
    [attemptId, studentId]
  )
  if (!attempt)
    throw { status: 400, message: 'Attempt not found or already submitted' }

  let totalPoints  = 0
  let earnedPoints = 0

  for (const ans of answers) {
    const [question] = await query(
      'SELECT id, type, points FROM questions WHERE id = ?',
      [ans.questionId]
    )
    if (!question) continue

    totalPoints += question.points
    let isCorrect    = 0
    let pointsEarned = 0
    let choiceId     = null

    if (question.type === 'multiple_choice' ||
        question.type === 'true_false') {
      if (ans.choiceId) {
        const [choice] = await query(
          `SELECT is_correct FROM choices
           WHERE id = ? AND question_id = ?`,
          [ans.choiceId, question.id]
        )
        isCorrect    = choice?.is_correct ? 1 : 0
        pointsEarned = isCorrect ? question.points : 0
        choiceId     = ans.choiceId
      }
    }

    earnedPoints += pointsEarned

    await query(
      `INSERT INTO answers
       (attempt_id, question_id, choice_id,
        answer_text, is_correct, points_earned)
       VALUES (?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
         choice_id     = VALUES(choice_id),
         answer_text   = VALUES(answer_text),
         is_correct    = VALUES(is_correct),
         points_earned = VALUES(points_earned)`,
      [attemptId, question.id, choiceId,
       ans.answerText || null, isCorrect, pointsEarned]
    )
  }

  const percentage = totalPoints > 0
    ? (earnedPoints / totalPoints) * 100 : 0
  const passed = percentage >= 75 ? 1 : 0

  await query(
    `UPDATE attempts SET
       status       = 'graded',
       submitted_at = NOW(),
       score        = ?,
       total_points = ?,
       percentage   = ?,
       passed       = ?
     WHERE id = ?`,
    [earnedPoints, totalPoints,
     percentage.toFixed(2), passed, attemptId]
  )

  return {
    attemptId,
    score:       earnedPoints,
    totalPoints,
    percentage:  +percentage.toFixed(2),
    passed:      passed === 1
  }
}

async function getAttemptResult(attemptId, studentId) {
  const [attempt] = await query(
    `SELECT a.*, st.name AS student_name,
            st.student_id AS student_code,
            q.title AS quiz_title
     FROM attempts a
     JOIN students st ON st.id = a.student_id
     JOIN sessions s  ON s.id  = a.session_id
     JOIN quizzes  q  ON q.id  = s.quiz_id
     WHERE a.id = ? AND a.student_id = ?`,
    [attemptId, studentId]
  )
  if (!attempt) throw { status: 404, message: 'Attempt not found' }

  const answers = await query(
    `SELECT an.question_id, q.question_text, q.points,
            an.is_correct, an.points_earned,
            c.choice_text AS selected_choice
     FROM answers an
     JOIN questions q ON q.id = an.question_id
     LEFT JOIN choices c ON c.id = an.choice_id
     WHERE an.attempt_id = ?`,
    [attemptId]
  )

  return { ...attempt, answers }
}

module.exports = {
  joinSession, getAttemptQuestions,
  submitAttempt, getAttemptResult
}