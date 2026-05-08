const bcrypt  = require('bcryptjs')
const jwt     = require('jsonwebtoken')
const { query } = require('../config/db')

function signToken(user) {
  return jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  )
}

async function loginWithPassword(email, password) {
  const [user] = await query(
    `SELECT id, name, email, password_hash, role
     FROM users WHERE email = ?`,
    [email]
  )
  if (!user) throw { status: 401, message: 'Invalid email or password' }

  const valid = await bcrypt.compare(password, user.password_hash)
  if (!valid) throw { status: 401, message: 'Invalid email or password' }

  const token = signToken(user)
  return {
    token,
    user: {
      id:    user.id,
      name:  user.name,
      email: user.email,
      role:  user.role
    }
  }
}

async function loginWithBarcode(barcodeValue) {
  const [student] = await query(
    `SELECT id, student_id, name, section, barcode
     FROM students WHERE barcode = ?`,
    [barcodeValue]
  )
  if (!student) throw { status: 404, message: 'Student not found' }

  const token = jwt.sign(
    { id: student.id, studentId: student.student_id, role: 'student' },
    process.env.JWT_SECRET,
    { expiresIn: '1d' }
  )

  return { token, student }
}

async function register(name, email, password, role = 'teacher') {
  const [existing] = await query(
    'SELECT id FROM users WHERE email = ?', [email]
  )
  if (existing) throw { status: 409, message: 'Email already in use' }

  const hash = await bcrypt.hash(password, 10)
  const result = await query(
    'INSERT INTO users (name, email, password_hash, role) VALUES (?,?,?,?)',
    [name, email, hash, role]
  )
  return { id: result.insertId, name, email, role }
}

module.exports = { loginWithPassword, loginWithBarcode, register }