// services/authService.js
const bcrypt    = require('bcryptjs')
const jwt       = require('jsonwebtoken')
const { query } = require('../config/db')

function signToken(user) {
  return jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  )
}

// ── Standard email + password login ───────────────────
async function loginWithPassword(email, password) {
  const [user] = await query(
    `SELECT id, name, email, password_hash, role, status
     FROM users WHERE email = ?`,
    [email]
  )
  if (!user) throw { status: 401, message: 'Invalid email or password' }

  const valid = await bcrypt.compare(password, user.password_hash)
  if (!valid) throw { status: 401, message: 'Invalid email or password' }

  // Check approval status
  if (user.status === 'pending') {
    throw {
      status:  403,
      message: 'Your account is pending admin approval. ' +
               'Please wait for an administrator to approve your account.'
    }
  }

  if (user.status === 'rejected') {
    throw {
      status:  403,
      message: 'Your account has been rejected. ' +
               'Please contact your administrator.'
    }
  }

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

// ── Barcode login ──────────────────────────────────────
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

// ── Register new teacher ───────────────────────────────
async function register(name, email, password, role = 'teacher') {
  const [existing] = await query(
    'SELECT id FROM users WHERE email = ?', [email]
  )
  if (existing) throw { status: 409, message: 'Email already in use' }

  const hash = await bcrypt.hash(password, 10)

  // New accounts start as 'pending' unless role is admin
  const status = role === 'admin' ? 'active' : 'pending'

  const result = await query(
    `INSERT INTO users (name, email, password_hash, role, status)
     VALUES (?, ?, ?, ?, ?)`,
    [name, email, hash, role, status]
  )
  return {
    id: result.insertId,
    name, email, role, status
  }
}

// ── Get all pending users (admin only) ────────────────
async function getPendingUsers() {
  return query(
    `SELECT id, name, email, role, status, created_at
     FROM users
     WHERE status = 'pending'
     ORDER BY created_at DESC`
  )
}

// ── Get all users (admin only) ─────────────────────────
async function getAllUsers() {
  return query(
    `SELECT id, name, email, role, status,
            created_at, approved_at
     FROM users
     ORDER BY created_at DESC`
  )
}

// ── Approve a user ─────────────────────────────────────
async function approveUser(userId) {
  const result = await query(
    `UPDATE users
     SET status = 'active', approved_at = NOW()
     WHERE id = ? AND status = 'pending'`,
    [userId]
  )
  if (result.affectedRows === 0)
    throw { status: 404, message: 'User not found or already processed' }
  return { message: 'User approved successfully' }
}

// ── Reject a user ──────────────────────────────────────
async function rejectUser(userId) {
  const result = await query(
    `UPDATE users
     SET status = 'rejected'
     WHERE id = ? AND status = 'pending'`,
    [userId]
  )
  if (result.affectedRows === 0)
    throw { status: 404, message: 'User not found or already processed' }
  return { message: 'User rejected' }
}

// ── Delete a user ──────────────────────────────────────
async function deleteUser(userId) {
  const result = await query(
    'DELETE FROM users WHERE id = ? AND role != ?',
    [userId, 'admin']
  )
  if (result.affectedRows === 0)
    throw { status: 404, message: 'User not found or cannot delete admin' }
  return { message: 'User deleted' }
}

module.exports = {
  loginWithPassword,
  loginWithBarcode,
  register,
  getPendingUsers,
  getAllUsers,
  approveUser,
  rejectUser,
  deleteUser,
  signToken
}