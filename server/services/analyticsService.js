const { query } = require('../config/db')

async function getDashboardStats(teacherId) {
  const [totals] = await query(
    `SELECT
       COUNT(DISTINCT q.id)        AS total_quizzes,
       COUNT(DISTINCT s.id)        AS total_sessions,
       COUNT(DISTINCT a.id)        AS total_attempts,
       ROUND(AVG(a.percentage), 1) AS avg_score,
       MAX(a.percentage)           AS highest_score,
       COUNT(DISTINCT st.id)       AS unique_students
     FROM quizzes q
     LEFT JOIN sessions s  ON s.quiz_id    = q.id
     LEFT JOIN attempts a  ON a.session_id = s.id
     LEFT JOIN students st ON st.id        = a.student_id
     WHERE q.teacher_id = ?`,
    [teacherId]
  )
  return totals
}

async function getMonthlyTrend(teacherId) {
  return query(
    `SELECT
       DATE_FORMAT(a.submitted_at, '%b') AS month,
       YEAR(a.submitted_at)              AS year,
       MONTH(a.submitted_at)             AS month_num,
       ROUND(AVG(a.percentage), 1)       AS avg_score,
       ROUND(MAX(a.percentage), 1)       AS high_score,
       COUNT(a.id)                       AS attempts
     FROM attempts a
     JOIN sessions s ON s.id = a.session_id
     JOIN quizzes  q ON q.id = s.quiz_id
     WHERE q.teacher_id = ?
       AND a.submitted_at >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
       AND a.status IN ('submitted','graded')
     GROUP BY YEAR(a.submitted_at), MONTH(a.submitted_at)
     ORDER BY year, month_num`,
    [teacherId]
  )
}

async function getScoreDistribution(teacherId) {
  const [rows] = await query(
    `SELECT
       SUM(CASE WHEN a.percentage >= 90 THEN 1 ELSE 0 END)
         AS score_90_100,
       SUM(CASE WHEN a.percentage >= 75
                AND a.percentage < 90  THEN 1 ELSE 0 END)
         AS score_75_89,
       SUM(CASE WHEN a.percentage >= 60
                AND a.percentage < 75  THEN 1 ELSE 0 END)
         AS score_60_74,
       SUM(CASE WHEN a.percentage < 60 THEN 1 ELSE 0 END)
         AS score_below_60,
       COUNT(*) AS total
     FROM attempts a
     JOIN sessions s ON s.id = a.session_id
     JOIN quizzes  q ON q.id = s.quiz_id
     WHERE q.teacher_id = ?
       AND a.status IN ('submitted','graded')`,
    [teacherId]
  )
  return rows
}

async function getQuizAnalytics(quizId, teacherId) {
  const [quiz] = await query(
    'SELECT id, title FROM quizzes WHERE id = ? AND teacher_id = ?',
    [quizId, teacherId]
  )
  if (!quiz) throw { status: 404, message: 'Quiz not found' }

  const sessions = await query(
    `SELECT s.id, s.session_code, s.status, s.started_at,
            COUNT(a.id)                 AS attempts,
            ROUND(AVG(a.percentage), 1) AS avg_score,
            ROUND(MAX(a.percentage), 1) AS high_score,
            ROUND(MIN(a.percentage), 1) AS low_score
     FROM sessions s
     LEFT JOIN attempts a ON a.session_id = s.id
     WHERE s.quiz_id = ? AND s.teacher_id = ?
     GROUP BY s.id
     ORDER BY s.started_at DESC`,
    [quizId, teacherId]
  )

  const questionStats = await query(
    `SELECT q.id, q.question_text, q.points,
            COUNT(an.id)                       AS responses,
            SUM(an.is_correct)                 AS correct,
            ROUND(AVG(an.is_correct) * 100, 1) AS correct_pct
     FROM questions q
     LEFT JOIN answers an ON an.question_id = q.id
     WHERE q.quiz_id = ?
     GROUP BY q.id
     ORDER BY q.order_index`,
    [quizId]
  )

  return { quiz, sessions, questionStats }
}

async function getTopStudents(teacherId, limit = 10) {
  return query(
    `SELECT st.student_id, st.name, st.section,
            COUNT(a.id)                 AS attempts,
            ROUND(AVG(a.percentage), 1) AS avg_score,
            ROUND(MAX(a.percentage), 1) AS best_score
     FROM attempts a
     JOIN students st ON st.id = a.student_id
     JOIN sessions s  ON s.id  = a.session_id
     JOIN quizzes  q  ON q.id  = s.quiz_id
     WHERE q.teacher_id = ?
       AND a.status IN ('submitted','graded')
     GROUP BY st.id
     ORDER BY avg_score DESC
     LIMIT ?`,
    [teacherId, limit]
  )
}

module.exports = {
  getDashboardStats, getMonthlyTrend,
  getScoreDistribution, getQuizAnalytics, getTopStudents
}