const { query } = require('../config/db')

const getAllStudents = async () => {
  const sql = `
    SELECT id, student_id, name, email, section, year_level,
           barcode, is_active, created_at
    FROM students
    ORDER BY created_at DESC
  `
  return await query(sql)
}

const getStudentById = async (id) => {
  const sql = `
    SELECT id, student_id, name, email, section, year_level,
           barcode, is_active, created_at
    FROM students
    WHERE id = ?
  `
  const rows = await query(sql, [id])
  return rows[0] || null
}

const getStudentByBarcode = async (barcode) => {
  const sql = `
    SELECT id, student_id, name, email, section, year_level,
           barcode, is_active, created_at
    FROM students
    WHERE barcode = ?
  `
  const rows = await query(sql, [barcode])
  return rows[0] || null
}

const createStudent = async (studentData) => {
  const { student_id, name, email, section, year_level, barcode } = studentData

  const sql = `
    INSERT INTO students (student_id, name, email, section, year_level, barcode)
    VALUES (?, ?, ?, ?, ?, ?)
  `
  const result = await query(sql, [
    student_id,
    name,
    email || null,
    section || null,
    year_level || null,
    barcode
  ])

  return await getStudentById(result.insertId)
}

const updateStudent = async (id, studentData) => {
  const { student_id, name, email, section, year_level, barcode, is_active } = studentData

  const sql = `
    UPDATE students
    SET student_id = ?, name = ?, email = ?, section = ?,
        year_level = ?, barcode = ?, is_active = ?
    WHERE id = ?
  `
  await query(sql, [
    student_id,
    name,
    email || null,
    section || null,
    year_level || null,
    barcode,
    is_active !== undefined ? (is_active ? 1 : 0) : 1,
    id
  ])

  return await getStudentById(id)
}

const deleteStudent = async (id) => {
  const sql = `DELETE FROM students WHERE id = ?`
  await query(sql, [id])
}

const checkDuplicateBarcode = async (barcode, excludeId = null) => {
  let sql = `SELECT id FROM students WHERE barcode = ?`
  const params = [barcode]

  if (excludeId) {
    sql += ` AND id != ?`
    params.push(excludeId)
  }

  const rows = await query(sql, params)
  return rows.length > 0
}

const checkDuplicateStudentId = async (studentId, excludeId = null) => {
  let sql = `SELECT id FROM students WHERE student_id = ?`
  const params = [studentId]

  if (excludeId) {
    sql += ` AND id != ?`
    params.push(excludeId)
  }

  const rows = await query(sql, params)
  return rows.length > 0
}

module.exports = {
  getAllStudents,
  getStudentById,
  getStudentByBarcode,
  createStudent,
  updateStudent,
  deleteStudent,
  checkDuplicateBarcode,
  checkDuplicateStudentId
}