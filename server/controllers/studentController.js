const studentService = require('../services/studentService')
const { asyncHandler } = require('../middleware/errorHandler')

const getAll = asyncHandler(async (req, res) => {
  const students = await studentService.getAllStudents()
  res.json({ success: true, data: students })
})

const getOne = asyncHandler(async (req, res) => {
  const student = await studentService.getStudentById(+req.params.id)
  if (!student) {
    const err = new Error('Student not found')
    err.status = 404
    throw err
  }
  res.json({ success: true, data: student })
})

const create = asyncHandler(async (req, res) => {
  const { student_id, name, barcode } = req.body

  if (!student_id || !name || !barcode) {
    const err = new Error('student_id, name, and barcode are required')
    err.status = 400
    throw err
  }

  const duplicateBarcode = await studentService.checkDuplicateBarcode(barcode)
  if (duplicateBarcode) {
    const err = new Error('Barcode already exists')
    err.status = 409
    throw err
  }

  const duplicateSid = await studentService.checkDuplicateStudentId(student_id)
  if (duplicateSid) {
    const err = new Error('Student ID already exists')
    err.status = 409
    throw err
  }

  const student = await studentService.createStudent(req.body)
  res.status(201).json({ success: true, data: student })
})

const update = asyncHandler(async (req, res) => {
  const student = await studentService.getStudentById(+req.params.id)
  if (!student) {
    const err = new Error('Student not found')
    err.status = 404
    throw err
  }

  const { barcode, student_id } = req.body

  if (barcode) {
    const duplicateBarcode = await studentService.checkDuplicateBarcode(barcode, req.params.id)
    if (duplicateBarcode) {
      const err = new Error('Barcode already exists')
      err.status = 409
      throw err
    }
  }

  if (student_id) {
    const duplicateSid = await studentService.checkDuplicateStudentId(student_id, req.params.id)
    if (duplicateSid) {
      const err = new Error('Student ID already exists')
      err.status = 409
      throw err
    }
  }

  const updated = await studentService.updateStudent(+req.params.id, req.body)
  res.json({ success: true, data: updated })
})

const remove = asyncHandler(async (req, res) => {
  const student = await studentService.getStudentById(+req.params.id)
  if (!student) {
    const err = new Error('Student not found')
    err.status = 404
    throw err
  }

  await studentService.deleteStudent(+req.params.id)
  res.json({ success: true, message: 'Student deleted' })
})

module.exports = { getAll, getOne, create, update, remove }