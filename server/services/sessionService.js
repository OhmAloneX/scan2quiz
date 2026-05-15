// services/sessionService.js
const QRCode         = require('qrcode')
const { v4: uuidv4 } = require('uuid')
const os             = require('os')
const { query }      = require('../config/db')

// ── Get local network IP ───────────────────────────────
function getLocalIP() {
  const interfaces = os.networkInterfaces()
  for (const iface of Object.values(interfaces)) {
    for (const alias of iface) {
      if (alias.family === 'IPv4' && !alias.internal) {
        return alias.address
      }
    }
  }
  return 'localhost'
}

// ── Generate short session code ────────────────────────
function makeSessionCode() {
  return Math.random().toString(36).toUpperCase().slice(2, 8)
}

// ── Create a new session + QR ──────────────────────────
async function createSession(quizId, teacherId) {
  const [quiz] = await query(
    `SELECT id, title FROM quizzes
     WHERE id = ? AND teacher_id = ? AND is_active = 1`,
    [quizId, teacherId]
  )
  if (!quiz) throw { status: 404, message: 'Quiz not found or inactive' }

  const qrToken     = uuidv4()
  const sessionCode = makeSessionCode()
  const localIP     = getLocalIP()

  // QR payload — opens join page on student phone
  const joinUrl =
    `http://${localIP}:3000/join` +
    `?token=${qrToken}` +
    `&code=${sessionCode}` +
    `&quiz=${encodeURIComponent(quiz.title)}`

  const qrImage = await QRCode.toDataURL(joinUrl, {
    width:                300,
    margin:               2,
    errorCorrectionLevel: 'H'
  })

  const result = await query(
    `INSERT INTO sessions
     (quiz_id, teacher_id, session_code, qr_token, qr_image)
     VALUES (?, ?, ?, ?, ?)`,
    [quizId, teacherId, sessionCode, qrToken, qrImage]
  )

  return {
    id:          result.insertId,
    quizId,
    quizTitle:   quiz.title,
    sessionCode,
    qrToken,
    qrImage,
    joinUrl,
    status:      'open'
  }
}

// ── Get session by QR token ────────────────────────────
async function getSessionByToken(qrToken) {
  const [session] = await query(
    `SELECT s.*, q.title AS quiz_title, q.time_limit
     FROM sessions s
     JOIN quizzes q ON q.id = s.quiz_id
     WHERE s.qr_token = ?`,
    [qrToken]
  )
  if (!session)
    throw { status: 404, message: 'Session not found' }
  if (session.status !== 'open')
    throw { status: 410, message: 'Session is closed' }
  return session
}

// ── List sessions by teacher ───────────────────────────
async function getSessionsByTeacher(teacherId) {
  return query(
    `SELECT s.id, s.session_code, s.status,
            s.started_at, s.closed_at,
            q.title AS quiz_title,
            COUNT(a.id) AS attempt_count
     FROM sessions s
     JOIN quizzes q ON q.id = s.quiz_id
     LEFT JOIN attempts a ON a.session_id = s.id
     WHERE s.teacher_id = ?
     GROUP BY s.id
     ORDER BY s.started_at DESC`,
    [teacherId]
  )
}

// ── Close a session ────────────────────────────────────
async function closeSession(sessionId, teacherId) {
  const result = await query(
    `UPDATE sessions
     SET status = 'closed', closed_at = NOW()
     WHERE id = ? AND teacher_id = ? AND status = 'open'`,
    [sessionId, teacherId]
  )
  if (result.affectedRows === 0)
    throw { status: 404, message: 'Session not found or already closed' }
  return { message: 'Session closed' }
}

// ── Handle QR or barcode scan ──────────────────────────
async function handleScan(type, value) {
  if (type === 'QR_CODE') {
    let token

    // Handle both formats:
    // Format A: full join URL (new format)
    // Format B: JSON string (old format)
    if (value.startsWith('http')) {
      // Extract token from URL
      try {
        const url    = new URL(value)
        token        = url.searchParams.get('token')
      } catch {
        throw { status: 400, message: 'Invalid QR URL' }
      }
    } else {
      // Try JSON parse (old format)
      try {
        const parsed = JSON.parse(value)
        token        = parsed.token
      } catch {
        throw { status: 400, message: 'Invalid QR data' }
      }
    }

    if (!token) throw { status: 400, message: 'No token in QR code' }

    const session = await getSessionByToken(token)
    return { success: true, message: 'QR session found', session }
  }

  if (type === 'barcode') {
    const [student] = await query(
      'SELECT * FROM students WHERE barcode = ?', [value]
    )
    if (!student)
      return { success: false, message: 'Student not found' }
    return { success: true, message: 'Student identified', student }
  }

  throw { status: 400, message: 'Unknown scan type' }
}

module.exports = {
  createSession,
  getSessionByToken,
  getSessionsByTeacher,
  closeSession,
  handleScan
}