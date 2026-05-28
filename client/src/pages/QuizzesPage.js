import { useEffect, useState } from 'react'

import Sidebar from '../components/layout/Sidebar'
import GlassCard from '../components/ui/GlassCard'
import Pagination from '../components/ui/Pagination'

import useResponsive from '../hooks/useResponsive'

import {
  getQuizzes,
  getQuiz,
  createQuiz,
  deleteQuiz,
  addQuestion,
  deleteQuestion,
  updateQuestion,
} from '../services/quizService'

import {
  createSession,
  fetchParticipants,
} from '../services/sessionService'

import StudentScannerModal from '../components/teacher/StudentScannerModal'

import { useValidation, rules } from '../hooks/useValidation'


export default function QuizzesPage() {
  const { isMobile, isTablet } = useResponsive()

  const [quizzes, setQuizzes] = useState([])
  const [loading, setLoading] = useState(true)

  const [showForm, setShowForm] = useState(false)
  const [showQForm, setShowQForm] = useState(null)
  const [selectedQuiz, setSelectedQuiz] = useState(null)
  const [editingQuestion, setEditingQuestion] = useState(null)
  const [showEditModal, setShowEditModal] = useState(false)
  const [editForm, setEditForm] = useState({
    question_text: '',
    type: 'multiple_choice',
    points: 1,
    choices: [
      { text: '', isCorrect: true },
      { text: '', isCorrect: false },
      { text: '', isCorrect: false },
      { text: '', isCorrect: false },
    ],
    tfCorrect: undefined,
  })
  const [editLoading, setEditLoading] = useState(false)
  const [editErrors, setEditErrors] = useState({})
  const [questionErrors, setQuestionErrors] = useState({})
  const [feedback, setFeedback] = useState({ type: '', message: '' })
  const [qrModal, setQrModal] = useState(null)

  const [showScanner, setShowScanner] = useState(false)
  const [participants, setParticipants] = useState([])
  const [participantsLoading, setParticipantsLoading] = useState(false)
  const [participantsError, setParticipantsError] = useState('')
  const [activeSessionId, setActiveSessionId] = useState(null)


  const [rowsPerPage, setRowsPerPage] = useState(10)
  const [currentPage, setCurrentPage] = useState(1)

  const [form, setForm] = useState({
    title: '',
    description: '',
    subject: '',
    time_limit: 30,
    passing_score: 75,
  })

  const [qForm, setQForm] = useState({
    question_text: '',
    type: 'multiple_choice',
    points: 1,
    choices: [
      { text: '', isCorrect: true },
      { text: '', isCorrect: false },
      { text: '', isCorrect: false },
      { text: '', isCorrect: false },
    ],
    tfCorrect: undefined,
  })

  const quizSchema = {
    title: [
      rules.required('Title'),
      rules.minLength(3, 'Title'),
      rules.maxLength(200, 'Title'),
    ],
    time_limit: [
      rules.positiveNumber('Time limit'),
      rules.range(1, 300, 'Time limit'),
    ],
    passing_score: [
      rules.positiveNumber('Passing score'),
      rules.range(1, 100, 'Passing score'),
    ],
  }

  const {
    getError: getQuizError,
    isValid: isQuizValid,
    handleBlur: quizBlur,
    handleChange: quizChange,
    validateAll: validateQuiz,
    reset: resetQuiz,
  } = useValidation(quizSchema)

  useEffect(() => {
    loadQuizzes()
  }, [])

  useEffect(() => {
    setCurrentPage(1)
  }, [rowsPerPage])

  const totalItems = quizzes.length
  const totalPages = Math.max(1, Math.ceil(totalItems / rowsPerPage))

  useEffect(() => {
    setCurrentPage((p) => Math.min(Math.max(1, p), totalPages))
  }, [totalPages])


  const startIndex = (currentPage - 1) * rowsPerPage
  const endIndex = startIndex + rowsPerPage

  const paginatedQuizzes = quizzes.slice(startIndex, endIndex)

  async function loadQuizzes() {
    try {
      const res = await getQuizzes()
      setQuizzes(res.data.data)
    } catch (err) {
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  async function refreshSelectedQuiz(quizId) {
    try {
      const res = await getQuiz(quizId)
      setSelectedQuiz(res.data.data)
    } catch (err) {
      console.error(err)
      setSelectedQuiz(null)
    }
  }

  function getDefaultChoices(type = 'multiple_choice') {
    return type === 'true_false'
      ? [
          { text: 'True', isCorrect: true },
          { text: 'False', isCorrect: false },
        ]
      : [
          { text: '', isCorrect: true },
          { text: '', isCorrect: false },
          { text: '', isCorrect: false },
          { text: '', isCorrect: false },
        ]
  }

  function validateQuestionForm(values) {
    const errors = {}
    const trimmedQuestion = values.question_text?.trim() || ''

    if (!trimmedQuestion) {
      errors.question_text = 'Question text is required.'
    }

    const type = values.type
    if (!['multiple_choice', 'true_false'].includes(type)) {
      errors.type = 'Invalid question type.'
    }

    if (type === 'multiple_choice') {
      const nonEmptyChoices = (values.choices || []).filter((choice) => choice.text.trim())
      const hasCorrect = nonEmptyChoices.some((choice) => choice.isCorrect)

      if (nonEmptyChoices.length < 2) {
        errors.choices = 'At least two answer choices are required.'
      } else if (!hasCorrect) {
        errors.choices = 'Please select the correct answer.'
      }
    }

    if (type === 'true_false') {
      const hasCorrect = values.tfCorrect === true || values.tfCorrect === false
      if (!hasCorrect) {
        errors.tfCorrect = 'Select the correct answer.'
      }
    }

    if (!values.points || values.points < 1) {
      errors.points = 'Points must be at least 1.'
    }

    return errors
  }

  async function handleCreateQuiz(e) {
    e.preventDefault()

    if (!validateQuiz(form)) return

    try {
      await createQuiz(form)

      setShowForm(false)
      resetQuiz()

      setForm({
        title: '',
        description: '',
        subject: '',
        time_limit: 30,
        passing_score: 75,
      })

      loadQuizzes()
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to create quiz')
    }
  }

  async function handleDeleteQuiz(id) {
    if (!window.confirm('Delete this quiz?')) return

    try {
      await deleteQuiz(id)
      loadQuizzes()
    } catch (err) {
      alert('Failed to delete quiz')
    }
  }

  async function handleAddQuestion(e, quizId) {
    e.preventDefault()
    const validation = validateQuestionForm(qForm)
    if (Object.keys(validation).length) {
      setQuestionErrors(validation)
      return
    }

    try {
      await addQuestion(quizId, qForm)
      setQuestionErrors({})
      setShowQForm(null)
      setSelectedQuiz(null)
      setQForm({
        question_text: '',
        type: 'multiple_choice',
        points: 1,
        tfCorrect: undefined,
        choices: getDefaultChoices('multiple_choice'),
      })

      await loadQuizzes()
      await refreshSelectedQuiz(quizId)
      setFeedback({ type: 'success', message: 'Question added successfully' })
    } catch (err) {
      setFeedback({ type: 'error', message: err.response?.data?.message || 'Failed to add question' })
    }
  }

  async function handleToggleQuizPanel(quiz) {
    if (showQForm === quiz.id) {
      setShowQForm(null)
      setSelectedQuiz(null)
      return
    }

    setShowQForm(quiz.id)
    setSelectedQuiz(null)
    try {
      const res = await getQuiz(quiz.id)
      setSelectedQuiz(res.data.data)
    } catch (err) {
      console.error(err)
      setSelectedQuiz(null)
    }
  }

  function openEditQuestion(question, quizId) {
    const choices = Array.isArray(question.choices)
      ? question.choices.map((choice) => ({
          text: choice.text || choice.choice_text || '',
          isCorrect: !!choice.isCorrect,
        }))
      : getDefaultChoices(question.type)

    const tfCorrect = question.type === 'true_false'
      ? choices.find((choice) => choice.isCorrect)?.text === 'True'
      : undefined

    setEditingQuestion({ ...question, quizId })
    setEditForm({
      question_text: question.question_text || '',
      type: question.type || 'multiple_choice',
      points: question.points || 1,
      choices,
      tfCorrect,
    })
    setEditErrors({})
    setShowEditModal(true)
  }

  async function handleUpdateQuestion() {
    const validation = validateQuestionForm(editForm)
    if (Object.keys(validation).length) {
      setEditErrors(validation)
      return
    }

    setEditLoading(true)
    try {
      const payload = {
        question_text: editForm.question_text.trim(),
        type: editForm.type,
        points: editForm.points,
        choices:
          editForm.type === 'true_false'
            ? [
                { text: 'True', isCorrect: editForm.tfCorrect === true },
                { text: 'False', isCorrect: editForm.tfCorrect === false },
              ]
            : editForm.choices
                .map((choice) => ({
                  text: choice.text?.trim() || '',
                  isCorrect: !!choice.isCorrect,
                }))
                .filter((choice) => choice.text),
      }

      await updateQuestion(editingQuestion.quizId, editingQuestion.id, payload)
      setShowEditModal(false)
      setEditingQuestion(null)
      setEditLoading(false)
      setEditErrors({})
      setFeedback({ type: 'success', message: 'Question updated successfully' })

      await refreshSelectedQuiz(editingQuestion.quizId)
      await loadQuizzes()
    } catch (err) {
      setEditLoading(false)
      setFeedback({ type: 'error', message: err.response?.data?.message || 'Failed to update question' })
    }
  }

  async function handleDeleteQuestionClick(quizId, questionId) {
    if (!window.confirm('Delete this question?')) return

    try {
      await deleteQuestion(quizId, questionId)
      await refreshSelectedQuiz(quizId)
      await loadQuizzes()
      setFeedback({ type: 'success', message: 'Question deleted successfully' })
    } catch (err) {
      setFeedback({ type: 'error', message: err.response?.data?.message || 'Failed to delete question' })
    }
  }

  async function handleStartSession(quizId) {
    try {
      const res = await createSession(quizId)
      setQrModal(res.data.data)
      setActiveSessionId(res.data.data?.id || null)
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to create session')
    }
  }


  const inputStyle = {
    width: '100%',
    padding: '10px 14px',
    background: 'rgba(255,255,255,0.06)',
    border: '1px solid rgba(103,232,249,0.25)',
    borderRadius: 10,
    color: '#e0f7ff',
    fontSize: 13,
    outline: 'none',
    boxSizing: 'border-box',
  }

  const labelStyle = {
    display: 'block',
    fontSize: 12,
    color: 'rgba(186,230,253,0.6)',
    marginBottom: 4,
  }

  useEffect(() => {
    let interval
    async function refresh() {
      if (!activeSessionId) return
      try {
        setParticipantsLoading(true)
        setParticipantsError('')
        const res = await fetchParticipants(activeSessionId)
        // backend returns {success:true, students:[...]}
        const list = res.data?.students || res.data?.data || []
        setParticipants(Array.isArray(list) ? list : [])
      } catch (err) {
        setParticipantsError(err.response?.data?.message || 'Failed to load participants')
      } finally {
        setParticipantsLoading(false)
      }
    }

    if (qrModal && activeSessionId) {
      refresh()
      interval = setInterval(refresh, 5000)
    }

    return () => {
      if (interval) clearInterval(interval)
    }
  }, [activeSessionId, qrModal])

  useEffect(() => {
    if (!feedback.message) return
    const timer = setTimeout(() => setFeedback({ type: '', message: '' }), 4200)
    return () => clearTimeout(timer)
  }, [feedback])

  return (

    <div
      style={{
        display: 'flex',
        minHeight: '100vh',
        background:
          'linear-gradient(135deg,#060d1f 0%,#0a1628 50%,#0d1f3c 100%)',
        fontFamily: "'Segoe UI',system-ui,sans-serif",
      }}
    >
      <Sidebar />

      <div style={{ flex: 1, overflow: 'auto' }}>
        {/* Top bar */}
        <div
          style={{
            padding: isMobile
              ? '12px 14px'
              : isTablet
                ? '16px 18px'
                : '16px 28px',
            background: 'rgba(255,255,255,0.03)',
            backdropFilter: 'blur(16px)',
            borderBottom: '1px solid rgba(103,232,249,0.08)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: isMobile ? 12 : 0,
            flexDirection: isMobile ? 'column' : 'row',
          }}
        >
          <div>
            <h1
              style={{
                color: '#e0f7ff',
                fontSize: isMobile ? 18 : 20,
                fontWeight: 600,
                margin: 0,
              }}
            >
              Quizzes
            </h1>
            <p
              style={{
                color: 'rgba(186,230,253,0.5)',
                fontSize: 13,
                margin: '2px 0 0',
              }}
            >
              Create and manage your quizzes
            </p>
          </div>

          <button
            onClick={() => setShowForm(true)}
            style={{
              padding: isMobile ? '9px 16px' : '10px 20px',
              background:
                'linear-gradient(135deg,rgba(34,211,238,0.2),rgba(99,102,241,0.2))',
              border: '1px solid rgba(34,211,238,0.45)',
              borderRadius: 12,
              color: '#22d3ee',
              fontSize: isMobile ? 13 : 14,
              fontWeight: 600,
              cursor: 'pointer',
              whiteSpace: 'nowrap',
            }}
          >
            + New Quiz
          </button>
        </div>

        <div
          style={{
            padding: isMobile
              ? '16px 14px'
              : isTablet
                ? '20px 18px'
                : '24px 28px',
          }}
        >
          {/* Create Quiz Form */}
          {showForm && (
            <GlassCard glow style={{ marginBottom: 24 }}>
              <h2
                style={{
                  color: '#e0f7ff',
                  fontSize: 16,
                  fontWeight: 600,
                  margin: '0 0 20px',
                }}
              >
                Create New Quiz
              </h2>
              <form onSubmit={handleCreateQuiz}>
                <div
                  style={{
                    display: 'grid',
                    gridTemplateColumns: isMobile
                      ? '1fr'
                      : isTablet
                        ? 'repeat(2, 1fr)'
                        : '1fr 1fr',
                    gap: isMobile ? 12 : 16,
                    marginBottom: isMobile ? 12 : 16,
                  }}
                >
                  <div>
                    <label style={labelStyle}>Title *</label>
                    <input
                      style={{
                        ...inputStyle,
                        borderColor: getQuizError('title')
                          ? 'rgba(248,113,113,0.7)'
                          : isQuizValid('title')
                            ? 'rgba(74,222,128,0.6)'
                            : 'rgba(103,232,249,0.25)',
                      }}
                      required
                      value={form.title}
                      onChange={(e) => {
                        setForm({ ...form, title: e.target.value })
                        quizChange('title', e.target.value)
                      }}
                      onBlur={(e) => quizBlur('title', e.target.value)}
                      placeholder="e.g. CS101 Midterm"
                    />

                    {getQuizError('title') && (
                      <p
                        style={{
                          color: '#f87171',
                          fontSize: 11,
                          margin: '4px 0 0',
                          display: 'flex',
                          alignItems: 'center',
                          gap: 4,
                        }}
                      >
                        ⚠ {getQuizError('title')}
                      </p>
                    )}
                  </div>

                  <div>
                    <label style={labelStyle}>Subject</label>
                    <input
                      style={inputStyle}
                      value={form.subject}
                      onChange={(e) => setForm({ ...form, subject: e.target.value })}
                      placeholder="e.g. Computer Science"
                    />
                  </div>

                  <div>
                    <label style={labelStyle}>Time Limit (minutes)</label>
                    <input
                      style={inputStyle}
                      type="number"
                      value={form.time_limit}
                      onChange={(e) =>
                        setForm({ ...form, time_limit: +e.target.value })
                      }
                    />
                  </div>

                  <div>
                    <label style={labelStyle}>Passing Score (%)</label>
                    <input
                      style={inputStyle}
                      type="number"
                      value={form.passing_score}
                      onChange={(e) =>
                        setForm({ ...form, passing_score: +e.target.value })
                      }
                    />
                  </div>
                </div>

                <div style={{ marginBottom: 16 }}>
                  <label style={labelStyle}>Description</label>
                  <textarea
                    style={{ ...inputStyle, height: 80, resize: 'vertical' }}
                    value={form.description}
                    onChange={(e) => setForm({ ...form, description: e.target.value })}
                    placeholder="Optional description..."
                  />
                </div>

                <div style={{ display: 'flex', gap: 10 }}>
                  <button
                    type="submit"
                    style={{
                      padding: '10px 24px',
                      background: 'rgba(34,211,238,0.15)',
                      border: '1px solid rgba(34,211,238,0.4)',
                      borderRadius: 10,
                      color: '#22d3ee',
                      fontWeight: 600,
                      cursor: 'pointer',
                      fontSize: 13,
                    }}
                  >
                    Create Quiz
                  </button>
                  <button
                    type="button"
                    onClick={() => setShowForm(false)}
                    style={{
                      padding: '10px 24px',
                      background: 'transparent',
                      border: '1px solid rgba(103,232,249,0.2)',
                      borderRadius: 10,
                      color: 'rgba(186,230,253,0.6)',
                      cursor: 'pointer',
                      fontSize: 13,
                    }}
                  >
                    Cancel
                  </button>
                </div>
              </form>
            </GlassCard>
          )}

          {/* Quiz list */}
          {loading ? (
            <p style={{ color: 'rgba(186,230,253,0.5)' }}>Loading quizzes...</p>
          ) : quizzes.length === 0 ? (
            <GlassCard style={{ textAlign: 'center', padding: 48 }}>
              <p style={{ color: 'rgba(186,230,253,0.4)', fontSize: 15 }}>
                No quizzes yet. Click "+ New Quiz" to create one.
              </p>
            </GlassCard>
          ) : (
            <>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
                {paginatedQuizzes.map((quiz) => (
                  <GlassCard key={quiz.id}>
                    <div
                      style={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'flex-start',
                        flexDirection: isMobile ? 'column' : 'row',
                        gap: isMobile ? 12 : 0,
                      }}
                    >
                      <div style={{ flex: 1 }}>
                        <div
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: 10,
                            marginBottom: 4,
                          }}
                        >
                          <h3
                            style={{
                              color: '#e0f7ff',
                              fontSize: 16,
                              fontWeight: 600,
                              margin: 0,
                            }}
                          >
                            {quiz.title}
                          </h3>
                          {quiz.subject && (
                            <span
                              style={{
                                fontSize: 11,
                                padding: '2px 8px',
                                borderRadius: 20,
                                background: 'rgba(99,102,241,0.15)',
                                border: '1px solid rgba(99,102,241,0.3)',
                                color: '#a5b4fc',
                              }}
                            >
                              {quiz.subject}
                            </span>
                          )}
                        </div>

                        {quiz.description && (
                          <p
                            style={{
                              color: 'rgba(186,230,253,0.5)',
                              fontSize: 13,
                              margin: '0 0 10px',
                            }}
                          >
                            {quiz.description}
                          </p>
                        )}

                        <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap' }}>
                          {[
                            ['📋', `${quiz.question_count} questions`],
                            ['⏱', `${quiz.time_limit} min`],
                            ['✅', `Pass: ${quiz.passing_score}%`],
                            ['🔳', `${quiz.session_count} sessions`],
                          ].map(([icon, text]) => (
                            <span key={text} style={{ color: 'rgba(186,230,253,0.5)', fontSize: 12 }}>
                              {icon} {text}
                            </span>
                          ))}
                        </div>
                      </div>

                      <div
                        style={{
                          display: 'flex',
                          gap: 8,
                          flexShrink: 0,
                          flexWrap: isMobile ? 'wrap' : 'nowrap',
                          width: isMobile ? '100%' : 'auto',
                        }}
                      >
                        <button
                          onClick={() => handleToggleQuizPanel(quiz)}
                          style={{
                            padding: '7px 14px',
                            background: 'rgba(99,102,241,0.15)',
                            border: '1px solid rgba(99,102,241,0.3)',
                            borderRadius: 10,
                            color: '#a5b4fc',
                            fontSize: 12,
                            cursor: 'pointer',
                          }}
                        >
                          {showQForm === quiz.id ? 'Close Questions' : 'Questions'}
                        </button>

                        <button
                          onClick={() => handleStartSession(quiz.id)}
                          style={{
                            padding: '7px 14px',
                            background: 'rgba(34,211,238,0.15)',
                            border: '1px solid rgba(34,211,238,0.3)',
                            borderRadius: 10,
                            color: '#22d3ee',
                            fontSize: 12,
                            cursor: 'pointer',
                          }}
                        >
                          ▶ Start Session
                        </button>

                        <button
                          onClick={() => handleDeleteQuiz(quiz.id)}
                          style={{
                            padding: '7px 14px',
                            background: 'rgba(248,113,113,0.1)',
                            border: '1px solid rgba(248,113,113,0.3)',
                            borderRadius: 10,
                            color: '#f87171',
                            fontSize: 12,
                            cursor: 'pointer',
                          }}
                        >
                          🗑
                        </button>
                      </div>
                    </div>

                    {showQForm === quiz.id && (
                      <div
                        style={{
                          marginTop: 20,
                          paddingTop: 20,
                          borderTop: '1px solid rgba(103,232,249,0.1)',
                        }}
                      >
                        <div
                          style={{
                            display: 'flex',
                            justifyContent: 'space-between',
                            gap: 14,
                            flexDirection: isMobile ? 'column' : 'row',
                            alignItems: 'flex-start',
                            marginBottom: 18,
                          }}
                        >
                          <div>
                            <h4
                              style={{
                                color: '#e0f7ff',
                                fontSize: 14,
                                fontWeight: 600,
                                margin: '0 0 6px',
                              }}
                            >
                              Questions
                            </h4>
                            <p style={{ color: 'rgba(186,230,253,0.6)', fontSize: 12, margin: 0 }}>
                              Manage existing quiz questions and add new ones.
                            </p>
                          </div>
                          {feedback.message && (
                            <div
                              style={{
                                padding: '10px 14px',
                                borderRadius: 14,
                                background:
                                  feedback.type === 'success'
                                    ? 'rgba(34,197,94,0.12)'
                                    : 'rgba(248,113,113,0.12)',
                                border:
                                  feedback.type === 'success'
                                    ? '1px solid rgba(34,197,94,0.25)'
                                    : '1px solid rgba(248,113,113,0.25)',
                                color: feedback.type === 'success' ? '#a7f3d0' : '#fecaca',
                                fontSize: 12,
                              }}
                            >
                              {feedback.message}
                            </div>
                          )}
                        </div>

                        <div style={{ display: 'flex', flexDirection: 'column', gap: 14, marginBottom: 20 }}>
                          {selectedQuiz?.questions?.length > 0 ? (
                            selectedQuiz.questions.map((question) => {
                              const correctChoice = question.choices?.find((choice) => choice.isCorrect)
                              const correctText = correctChoice?.text || correctChoice?.choice_text || ''
                              const correctLabel = question.type === 'true_false'
                                ? correctText || 'True / False'
                                : correctText || 'No answer selected'

                              return (
                                <div
                                  key={question.id}
                                  style={{
                                    background: 'rgba(255,255,255,0.04)',
                                    border: '1px solid rgba(103,232,249,0.15)',
                                    borderRadius: 20,
                                    padding: 16,
                                  }}
                                >
                                  <div
                                    style={{
                                      display: 'flex',
                                      justifyContent: 'space-between',
                                      alignItems: 'flex-start',
                                      gap: 12,
                                      flexDirection: isMobile ? 'column' : 'row',
                                    }}
                                  >
                                    <div style={{ flex: 1 }}>
                                      <p
                                        style={{
                                          color: '#e0f7ff',
                                          fontSize: 14,
                                          fontWeight: 600,
                                          margin: 0,
                                          lineHeight: 1.4,
                                        }}
                                      >
                                        {question.question_text}
                                      </p>
                                      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, marginTop: 10 }}>
                                        <span
                                          style={{
                                            fontSize: 11,
                                            color: '#8dddfb',
                                            padding: '4px 10px',
                                            borderRadius: 999,
                                            background: 'rgba(34,211,238,0.08)',
                                            border: '1px solid rgba(34,211,238,0.18)',
                                          }}
                                        >
                                          {question.type === 'multiple_choice' ? 'Multiple Choice' : 'True / False'}
                                        </span>
                                        <span
                                          style={{
                                            fontSize: 11,
                                            color: '#c7d2fe',
                                            padding: '4px 10px',
                                            borderRadius: 999,
                                            background: 'rgba(99,102,241,0.08)',
                                            border: '1px solid rgba(99,102,241,0.18)',
                                          }}
                                        >
                                          {question.points} pts
                                        </span>
                                        <span
                                          style={{
                                            fontSize: 11,
                                            color: '#a5f3fc',
                                            padding: '4px 10px',
                                            borderRadius: 999,
                                            background: 'rgba(56,189,248,0.08)',
                                            border: '1px solid rgba(56,189,248,0.18)',
                                          }}
                                        >
                                          Correct: {correctLabel}
                                        </span>
                                      </div>
                                    </div>
                                    <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
                                      <button
                                        onClick={() => openEditQuestion(question, quiz.id)}
                                        style={{
                                          padding: '8px 14px',
                                          borderRadius: 12,
                                          border: '1px solid rgba(34,211,238,0.5)',
                                          background: 'rgba(34,211,238,0.12)',
                                          color: '#22d3ee',
                                          cursor: 'pointer',
                                          fontSize: 12,
                                        }}
                                      >
                                        ✏ Edit Question
                                      </button>
                                      <button
                                        onClick={() => handleDeleteQuestionClick(quiz.id, question.id)}
                                        style={{
                                          padding: '8px 14px',
                                          borderRadius: 12,
                                          border: '1px solid rgba(248,113,113,0.4)',
                                          background: 'rgba(248,113,113,0.12)',
                                          color: '#f87171',
                                          cursor: 'pointer',
                                          fontSize: 12,
                                        }}
                                      >
                                        🗑 Delete Question
                                      </button>
                                    </div>
                                  </div>
                                </div>
                              )
                            })
                          ) : (
                            <div
                              style={{
                                padding: 18,
                                borderRadius: 18,
                                background: 'rgba(255,255,255,0.02)',
                                border: '1px dashed rgba(103,232,249,0.18)',
                                color: 'rgba(186,230,253,0.6)',
                                fontSize: 13,
                              }}
                            >
                              No questions have been added for this quiz yet.
                            </div>
                          )}
                        </div>

                        <GlassCard glow style={{ marginBottom: 24 }}>
                          <h4
                            style={{
                              color: '#e0f7ff',
                              fontSize: 14,
                              fontWeight: 600,
                              margin: '0 0 14px',
                            }}
                          >
                            Add Question
                          </h4>

                          <form onSubmit={(e) => handleAddQuestion(e, quiz.id)}>
                            <div style={{ marginBottom: 12 }}>
                              <label style={labelStyle}>Question Text *</label>
                              <textarea
                                style={{
                                  ...inputStyle,
                                  height: 70,
                                  resize: 'vertical',
                                  borderColor: questionErrors.question_text
                                    ? 'rgba(248,113,113,0.7)'
                                    : 'rgba(103,232,249,0.25)',
                                }}
                                value={qForm.question_text}
                                onChange={(e) =>
                                  setQForm({ ...qForm, question_text: e.target.value })
                                }
                                placeholder="Enter your question..."
                              />
                              {questionErrors.question_text && (
                                <p style={{ color: '#f87171', fontSize: 11, margin: '6px 0 0' }}>
                                  ⚠ {questionErrors.question_text}
                                </p>
                              )}
                            </div>

                            <div
                              style={{
                                display: 'grid',
                                gridTemplateColumns: isMobile
                                  ? '1fr'
                                  : isTablet
                                    ? 'repeat(2, 1fr)'
                                    : '1fr 1fr',
                                gap: isMobile ? 10 : 12,
                                marginBottom: isMobile ? 10 : 12,
                              }}
                            >
                              <div>
                                <label style={labelStyle}>Type</label>
                                <select
                                  style={inputStyle}
                                  value={qForm.type}
                                  onChange={(e) => {
                                    const newType = e.target.value
                                    setQForm({
                                      ...qForm,
                                      type: newType,
                                      tfCorrect: undefined,
                                      choices: getDefaultChoices(newType),
                                    })
                                  }}
                                >
                                  <option value="multiple_choice">Multiple Choice</option>
                                  <option value="true_false">True / False</option>
                                </select>
                              </div>

                              <div>
                                <label style={labelStyle}>Points</label>
                                <input
                                  style={inputStyle}
                                  type="number"
                                  min="1"
                                  value={qForm.points}
                                  onChange={(e) => setQForm({ ...qForm, points: +e.target.value })}
                                />
                                {questionErrors.points && (
                                  <p style={{ color: '#f87171', fontSize: 11, margin: '6px 0 0' }}>
                                    ⚠ {questionErrors.points}
                                  </p>
                                )}
                              </div>
                            </div>

                            <div style={{ marginBottom: 14 }}>
                              <label style={labelStyle}>
                                Choices (check the correct answer)
                              </label>

                              {qForm.type === 'multiple_choice' && (
                                <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                                  {qForm.choices.map((choice, index) => (
                                    <div
                                      key={index}
                                      style={{
                                        display: 'flex',
                                        alignItems: 'center',
                                        gap: 10,
                                        flexDirection: isMobile ? 'column' : 'row',
                                      }}
                                    >
                                      <label style={{ display: 'flex', alignItems: 'center', gap: 8, width: isMobile ? '100%' : 'auto' }}>
                                        <input
                                          type="radio"
                                          name="mc_correct"
                                          checked={!!choice.isCorrect}
                                          onChange={() => {
                                            const updatedChoices = qForm.choices.map((c, i) => ({
                                              ...c,
                                              isCorrect: i === index,
                                            }))
                                            setQForm({ ...qForm, choices: updatedChoices })
                                          }}
                                        />
                                        <span style={{ color: '#e0f7ff', fontSize: 13 }}>
                                          Choice {index + 1}
                                        </span>
                                      </label>

                                      <input
                                        style={{
                                          ...inputStyle,
                                          flex: 1,
                                        }}
                                        value={choice.text}
                                        onChange={(e) => {
                                          const updatedChoices = qForm.choices.map((c, i) =>
                                            i === index ? { ...c, text: e.target.value } : c
                                          )
                                          setQForm({ ...qForm, choices: updatedChoices })
                                        }}
                                        placeholder="Type a custom answer..."
                                      />
                                      <button
                                        type="button"
                                        onClick={() => {
                                          const updatedChoices = qForm.choices.filter((_, i) => i !== index)
                                          const hasCorrect = updatedChoices.some((c) => c.isCorrect)
                                          if (!hasCorrect && updatedChoices.length) {
                                            updatedChoices[0].isCorrect = true
                                          }
                                          setQForm({ ...qForm, choices: updatedChoices })
                                        }}
                                        style={{
                                          padding: '8px 12px',
                                          borderRadius: 10,
                                          border: '1px solid rgba(248,113,113,0.35)',
                                          background: 'rgba(248,113,113,0.1)',
                                          color: '#f87171',
                                          cursor: 'pointer',
                                          fontSize: 12,
                                        }}
                                      >
                                        Remove
                                      </button>
                                    </div>
                                  ))}
                                  <button
                                    type="button"
                                    onClick={() =>
                                      setQForm({
                                        ...qForm,
                                        choices: [...qForm.choices, { text: '', isCorrect: false }],
                                      })
                                    }
                                    style={{
                                      padding: '8px 14px',
                                      borderRadius: 12,
                                      border: '1px solid rgba(99,102,241,0.35)',
                                      background: 'rgba(99,102,241,0.12)',
                                      color: '#a5b4fc',
                                      cursor: 'pointer',
                                      fontSize: 12,
                                      width: 'fit-content',
                                    }}
                                  >
                                    + Add Choice
                                  </button>
                                </div>
                              )}

                              {qForm.type === 'true_false' && (
                                <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                                  {[
                                    { text: 'True', val: true },
                                    { text: 'False', val: false },
                                  ].map((opt) => (
                                    <label
                                      key={String(opt.val)}
                                      style={{
                                        display: 'flex',
                                        alignItems: 'center',
                                        gap: 10,
                                        padding: '10px 12px',
                                        borderRadius: 12,
                                        border: '1px solid rgba(103,232,249,0.15)',
                                        background: 'rgba(255,255,255,0.03)',
                                        cursor: 'pointer',
                                      }}
                                    >
                                      <input
                                        type="radio"
                                        name="tf_correct"
                                        checked={qForm.tfCorrect === opt.val}
                                        onChange={() => {
                                          const tfCorrect = opt.val
                                          const choices = [
                                            { text: 'True', isCorrect: tfCorrect === true },
                                            { text: 'False', isCorrect: tfCorrect === false },
                                          ]
                                          setQForm({ ...qForm, tfCorrect, choices })
                                        }}
                                      />
                                      <span style={{ color: '#e0f7ff', fontSize: 13 }}>{opt.text}</span>
                                    </label>
                                  ))}
                                </div>
                              )}
                              {questionErrors.choices && (
                                <p style={{ color: '#f87171', fontSize: 11, margin: '8px 0 0' }}>
                                  ⚠ {questionErrors.choices}
                                </p>
                              )}
                              {questionErrors.tfCorrect && (
                                <p style={{ color: '#f87171', fontSize: 11, margin: '8px 0 0' }}>
                                  ⚠ {questionErrors.tfCorrect}
                                </p>
                              )}
                            </div>

                            <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap' }}>
                              <button
                                type="submit"
                                style={{
                                  padding: '8px 20px',
                                  background: 'rgba(99,102,241,0.2)',
                                  border: '1px solid rgba(99,102,241,0.4)',
                                  borderRadius: 10,
                                  color: '#a5b4fc',
                                  fontWeight: 600,
                                  cursor: 'pointer',
                                  fontSize: 13,
                                }}
                              >
                                Add Question
                              </button>
                              <button
                                type="button"
                                onClick={() => {
                                  setShowQForm(null)
                                  setQuestionErrors({})
                                }}
                                style={{
                                  padding: '8px 20px',
                                  background: 'transparent',
                                  border: '1px solid rgba(103,232,249,0.2)',
                                  borderRadius: 10,
                                  color: 'rgba(186,230,253,0.6)',
                                  cursor: 'pointer',
                                  fontSize: 13,
                                }}
                              >
                                Cancel
                              </button>
                            </div>
                          </form>
                        </GlassCard>
                      </div>
                    )}
                  </GlassCard>
                ))}
              </div>

              {/* Pagination */}
              <div style={{ padding: '20px 0 0' }}>
                <Pagination
                  currentPage={currentPage}
                  totalPages={totalPages}
                  rowsPerPage={rowsPerPage}
                  setRowsPerPage={setRowsPerPage}
                  onPageChange={(p) => {
                    const next = Math.min(Math.max(1, p), totalPages)
                    setCurrentPage(next)
                  }}
                  totalItems={totalItems}
                  isMobile={isMobile}
                />
              </div>
            </>
          )}
        </div>
      </div>

      {/* Edit Question Modal */}
      {showEditModal && editingQuestion && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            background: 'rgba(0,0,0,0.72)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 200,
            backdropFilter: 'blur(8px)',
            padding: 18,
          }}
        >
          <div
            style={{
              width: isMobile ? '100%' : '680px',
              maxWidth: '100%',
              background: 'rgba(10,22,40,0.98)',
              border: '1px solid rgba(34,211,238,0.25)',
              borderRadius: 24,
              padding: 22,
              boxShadow: '0 0 80px rgba(34,211,238,0.12)',
              overflow: 'auto',
              maxHeight: '92vh',
            }}
          >
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                gap: 12,
                flexWrap: 'wrap',
                marginBottom: 18,
              }}
            >
              <div>
                <h2
                  style={{
                    color: '#e0f7ff',
                    fontSize: 18,
                    margin: 0,
                    fontWeight: 700,
                  }}
                >
                  Edit Question
                </h2>
                <p style={{ color: 'rgba(186,230,253,0.6)', fontSize: 13, margin: '8px 0 0' }}>
                  Update question text, answer choices, type, and points.
                </p>
              </div>
              <button
                type="button"
                onClick={() => {
                  setShowEditModal(false)
                  setEditingQuestion(null)
                  setEditErrors({})
                }}
                style={{
                  border: 'none',
                  background: 'transparent',
                  color: '#e0f7ff',
                  fontSize: 24,
                  lineHeight: 1,
                  cursor: 'pointer',
                }}
              >
                ×
              </button>
            </div>

            <form
              onSubmit={(e) => {
                e.preventDefault()
                handleUpdateQuestion()
              }}
            >
              <div style={{ marginBottom: 16 }}>
                <label style={labelStyle}>Question Text *</label>
                <textarea
                  style={{
                    ...inputStyle,
                    height: 90,
                    resize: 'vertical',
                    borderColor: editErrors.question_text
                      ? 'rgba(248,113,113,0.7)'
                      : 'rgba(103,232,249,0.25)',
                  }}
                  value={editForm.question_text}
                  onChange={(e) => setEditForm({ ...editForm, question_text: e.target.value })}
                  placeholder="Enter your question..."
                />
                {editErrors.question_text && (
                  <p style={{ color: '#f87171', fontSize: 11, margin: '6px 0 0' }}>
                    ⚠ {editErrors.question_text}
                  </p>
                )}
              </div>

              <div
                style={{
                  display: 'grid',
                  gridTemplateColumns: isMobile ? '1fr' : '1fr 1fr',
                  gap: 12,
                  marginBottom: 16,
                }}
              >
                <div>
                  <label style={labelStyle}>Type</label>
                  <select
                    style={inputStyle}
                    value={editForm.type}
                    onChange={(e) => {
                      const newType = e.target.value
                      setEditForm({
                        ...editForm,
                        type: newType,
                        tfCorrect: undefined,
                        choices: getDefaultChoices(newType),
                      })
                    }}
                  >
                    <option value="multiple_choice">Multiple Choice</option>
                    <option value="true_false">True / False</option>
                  </select>
                  {editErrors.type && (
                    <p style={{ color: '#f87171', fontSize: 11, margin: '6px 0 0' }}>
                      ⚠ {editErrors.type}
                    </p>
                  )}
                </div>
                <div>
                  <label style={labelStyle}>Points</label>
                  <input
                    style={inputStyle}
                    type="number"
                    min="1"
                    value={editForm.points}
                    onChange={(e) => setEditForm({ ...editForm, points: +e.target.value })}
                  />
                  {editErrors.points && (
                    <p style={{ color: '#f87171', fontSize: 11, margin: '6px 0 0' }}>
                      ⚠ {editErrors.points}
                    </p>
                  )}
                </div>
              </div>

              <div style={{ marginBottom: 18 }}>
                <label style={labelStyle}>Choices (correct answer highlighted)</label>
                {editForm.type === 'multiple_choice' && (
                  <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
                    {editForm.choices.map((choice, index) => (
                      <div
                        key={index}
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          gap: 10,
                          flexDirection: isMobile ? 'column' : 'row',
                        }}
                      >
                        <label style={{ display: 'flex', alignItems: 'center', gap: 8, width: isMobile ? '100%' : 'auto' }}>
                          <input
                            type="radio"
                            name="edit_mc_correct"
                            checked={!!choice.isCorrect}
                            onChange={() => {
                              const updatedChoices = editForm.choices.map((c, i) => ({
                                ...c,
                                isCorrect: i === index,
                              }))
                              setEditForm({ ...editForm, choices: updatedChoices })
                            }}
                          />
                          <span style={{ color: '#e0f7ff', fontSize: 13 }}>
                            Choice {index + 1}
                          </span>
                        </label>
                        <input
                          style={{ ...inputStyle, flex: 1 }}
                          value={choice.text}
                          onChange={(e) => {
                            const updatedChoices = editForm.choices.map((c, i) =>
                              i === index ? { ...c, text: e.target.value } : c
                            )
                            setEditForm({ ...editForm, choices: updatedChoices })
                          }}
                          placeholder="Enter option text..."
                        />
                        <button
                          type="button"
                          onClick={() => {
                            const updatedChoices = editForm.choices.filter((_, i) => i !== index)
                            const hasCorrect = updatedChoices.some((c) => c.isCorrect)
                            if (!hasCorrect && updatedChoices.length) {
                              updatedChoices[0].isCorrect = true
                            }
                            setEditForm({ ...editForm, choices: updatedChoices })
                          }}
                          style={{
                            minWidth: 96,
                            padding: '8px 12px',
                            borderRadius: 10,
                            border: '1px solid rgba(248,113,113,0.35)',
                            background: 'rgba(248,113,113,0.1)',
                            color: '#f87171',
                            cursor: 'pointer',
                            fontSize: 12,
                          }}
                        >
                          Remove
                        </button>
                      </div>
                    ))}
                    <button
                      type="button"
                      onClick={() =>
                        setEditForm({
                          ...editForm,
                          choices: [...editForm.choices, { text: '', isCorrect: false }],
                        })
                      }
                      style={{
                        padding: '10px 14px',
                        borderRadius: 12,
                        border: '1px solid rgba(99,102,241,0.35)',
                        background: 'rgba(99,102,241,0.12)',
                        color: '#a5b4fc',
                        cursor: 'pointer',
                        fontSize: 13,
                        width: 'fit-content',
                      }}
                    >
                      + Add Choice
                    </button>
                  </div>
                )}

                {editForm.type === 'true_false' && (
                  <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                    {[
                      { text: 'True', val: true },
                      { text: 'False', val: false },
                    ].map((opt) => (
                      <label
                        key={String(opt.val)}
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          gap: 10,
                          padding: '10px 12px',
                          borderRadius: 12,
                          border: '1px solid rgba(103,232,249,0.15)',
                          background: 'rgba(255,255,255,0.03)',
                          cursor: 'pointer',
                        }}
                      >
                        <input
                          type="radio"
                          name="edit_tf_correct"
                          checked={editForm.tfCorrect === opt.val}
                          onChange={() => {
                            const tfCorrect = opt.val
                            const choices = [
                              { text: 'True', isCorrect: tfCorrect === true },
                              { text: 'False', isCorrect: tfCorrect === false },
                            ]
                            setEditForm({ ...editForm, tfCorrect, choices })
                          }}
                        />
                        <span style={{ color: '#e0f7ff', fontSize: 13 }}>{opt.text}</span>
                      </label>
                    ))}
                  </div>
                )}

                {editErrors.choices && (
                  <p style={{ color: '#f87171', fontSize: 11, margin: '8px 0 0' }}>
                    ⚠ {editErrors.choices}
                  </p>
                )}
                {editErrors.tfCorrect && (
                  <p style={{ color: '#f87171', fontSize: 11, margin: '8px 0 0' }}>
                    ⚠ {editErrors.tfCorrect}
                  </p>
                )}
              </div>

              <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap', justifyContent: 'flex-end' }}>
                <button
                  type="button"
                  onClick={() => {
                    setShowEditModal(false)
                    setEditingQuestion(null)
                    setEditErrors({})
                  }}
                  style={{
                    padding: '10px 16px',
                    borderRadius: 12,
                    border: '1px solid rgba(103,232,249,0.25)',
                    background: 'transparent',
                    color: 'rgba(186,230,253,0.8)',
                    cursor: 'pointer',
                    fontSize: 13,
                  }}
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={editLoading}
                  style={{
                    padding: '10px 16px',
                    borderRadius: 12,
                    border: '1px solid rgba(34,211,238,0.5)',
                    background: editLoading ? 'rgba(34,211,238,0.15)' : 'rgba(34,211,238,0.2)',
                    color: '#22d3ee',
                    cursor: editLoading ? 'not-allowed' : 'pointer',
                    fontSize: 13,
                  }}
                >
                  {editLoading ? 'Saving...' : '💾 Save Changes'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* QR Modal */}
      {qrModal && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            background: 'rgba(0,0,0,0.7)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 100,
            backdropFilter: 'blur(4px)',
            padding: 14,
          }}
        >
          <div
            style={{
              background: 'rgba(10,22,40,0.95)',
              border: '1px solid rgba(34,211,238,0.3)',
              borderRadius: 24,
              padding: 18,
              textAlign: 'center',
              maxWidth: 980,
              width: '100%',
              boxShadow: '0 0 60px rgba(34,211,238,0.15)',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              gap: 16,
            }}
          >
            <div style={{ width: '100%', display: 'flex', gap: 12, justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap' }}>
              <div style={{ flex: '1 1 300px' }}>
                <h2
                  style={{
                    color: '#e0f7ff',
                    fontSize: 18,
                    fontWeight: 600,
                    margin: '0 0 4px',
                  }}
                >
                  Session Started! 🎉
                </h2>
                <p
                  style={{
                    color: 'rgba(186,230,253,0.5)',
                    fontSize: 13,
                    margin: '0 0 8px',
                  }}
                >
                  {qrModal.quizTitle}
                </p>
              </div>

              <div style={{ flex: '0 0 auto' }}>
                <div
                  style={{
                    background: 'rgba(34,211,238,0.1)',
                    border: '1px solid rgba(34,211,238,0.3)',
                    borderRadius: 12,
                    padding: '12px 20px',
                    minWidth: 240,
                  }}
                >
                  <p
                    style={{
                      color: 'rgba(186,230,253,0.5)',
                      fontSize: 11,
                      margin: '0 0 4px',
                      textTransform: 'uppercase',
                      letterSpacing: '0.8px',
                    }}
                  >
                    Session Code
                  </p>
                  <p
                    style={{
                      color: '#22d3ee',
                      fontSize: isMobile ? 20 : 26,
                      fontWeight: 700,
                      margin: 0,
                      fontFamily: 'monospace',
                      letterSpacing: 4,
                    }}
                  >
                    {qrModal.sessionCode}
                  </p>
                </div>
              </div>
            </div>

            <div
              style={{
                width: '100%',
                display: 'grid',
                gridTemplateColumns: isMobile ? '1fr' : '420px 1fr',
                gap: 16,
                alignItems: 'start',
              }}
            >
              <div style={{ display: 'flex', flexDirection: 'column', gap: 12, alignItems: 'center' }}>
                {/* QR Code */}
                <div
                  style={{
                    display: 'flex',
                    justifyContent: 'center',
                    alignItems: 'center',
                    marginBottom: 6,
                    width: '100%',
                  }}
                >
                  <img
                    src={qrModal.qrImage}
                    alt="QR Code"
                    style={{
                      width: isMobile ? 170 : 200,
                      height: isMobile ? 170 : 200,
                      borderRadius: 12,
                      display: 'block',
                      margin: '0 auto',
                    }}
                  />
                </div>

                <div style={{ width: '100%', display: 'flex', gap: 10, flexWrap: 'wrap', justifyContent: 'center' }}>
                  <button
                    onClick={() => {
                      setActiveSessionId(qrModal.id);
                      setShowScanner(true);
                    }}
                    style={{
                      flex: '1 1 200px',
                      padding: isMobile ? '12px 14px' : '12px 18px',
                      background:
                        'linear-gradient(135deg,rgba(34,211,238,0.18),rgba(99,102,241,0.15))',
                      border: '1px solid rgba(34,211,238,0.45)',
                      borderRadius: 16,
                      color: '#22d3ee',
                      fontWeight: 800,
                      fontSize: 14,
                      cursor: 'pointer',
                      boxShadow: '0 0 18px rgba(34,211,238,0.18)',
                    }}
                  >
                    📷 Scan Student ID
                  </button>

                  <button
                    onClick={() => {
                      setQrModal(null);
                      setShowScanner(false);
                      setParticipants([]);
                      setActiveSessionId(null);
                    }}
                    style={{
                      flex: '0 1 160px',
                      padding: '12px 16px',
                      background: 'rgba(34,211,238,0.15)',
                      border: '1px solid rgba(34,211,238,0.4)',
                      borderRadius: 16,
                      color: '#22d3ee',
                      fontWeight: 700,
                      fontSize: 14,
                      cursor: 'pointer',
                    }}
                  >
                    Close
                  </button>
                </div>

                <p
                  style={{
                    color: 'rgba(186,230,253,0.45)',
                    fontSize: 12,
                    margin: 0,
                  }}
                >
                  Students scan this QR code to join the session
                </p>

                <div
                  style={{
                    width: '100%',
                    background: 'rgba(255,255,255,0.03)',
                    border: '1px solid rgba(103,232,249,0.12)',
                    borderRadius: 16,
                    padding: '12px 14px',
                  }}
                >
                  <div style={{ display: 'flex', justifyContent: 'space-between', gap: 10, alignItems: 'baseline' }}>
                    <span style={{ color: 'rgba(186,230,253,0.55)', fontSize: 12, textTransform: 'uppercase', letterSpacing: 0.8 }}>Participants</span>
                    <span style={{ color: '#e0f7ff', fontSize: 20, fontWeight: 900, fontFamily: 'monospace' }}>
                      {participants.length}
                    </span>
                  </div>
                  {participantsLoading && (
                    <p style={{ color: 'rgba(186,230,253,0.4)', fontSize: 12, margin: '6px 0 0' }}>
                      Refreshing...
                    </p>
                  )}
                </div>
              </div>

              <div>
                {/* Live participant table */}
                <div
                  style={{
                    background: 'rgba(255,255,255,0.03)',
                    border: '1px solid rgba(103,232,249,0.12)',
                    borderRadius: 16,
                    overflow: 'hidden',
                  }}
                >
                  <div style={{ padding: '12px 14px', borderBottom: '1px solid rgba(103,232,249,0.10)' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 10, flexWrap: 'wrap' }}>
                      <p style={{ margin: 0, color: '#e0f7ff', fontSize: 13, fontWeight: 800 }}>
                        Live Attendance
                      </p>
                      <span style={{ color: 'rgba(186,230,253,0.45)', fontSize: 12 }}>
                        Auto-refresh every 5s
                      </span>
                    </div>
                  </div>

                  {participantsError && (
                    <div style={{ padding: 12, color: '#f87171', fontSize: 13, fontWeight: 700 }}>
                      {participantsError}
                    </div>
                  )}

                  {participantsLoading && participants.length === 0 ? (
                    <div style={{ padding: 14, color: 'rgba(186,230,253,0.55)' }}>
                      Loading participants...
                    </div>
                  ) : participants.length === 0 ? (
                    <div style={{ padding: 24, color: 'rgba(186,230,253,0.4)', fontSize: 13, textAlign: 'center' }}>
                      No students have joined yet.
                    </div>
                  ) : (
                    <div style={{ maxHeight: isMobile ? 320 : 420, overflowY: 'auto' }}>
                      <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                        <thead>
                          <tr>
                            {['Student ID', 'Student Name', 'Attendance Status', 'Joined At'].map((h) => (
                              <th
                                key={h}
                                style={{
                                  textAlign: 'left',
                                  padding: '10px 12px',
                                  fontSize: 11,
                                  color: 'rgba(186,230,253,0.45)',
                                  fontWeight: 700,
                                  textTransform: 'uppercase',
                                  letterSpacing: '0.7px',
                                  borderBottom: '1px solid rgba(103,232,249,0.10)',
                                }}
                              >
                                {h}
                              </th>
                            ))}
                          </tr>
                        </thead>
                        <tbody>
                          {participants.map((p) => (
                            <tr key={p.id} style={{ borderBottom: '1px solid rgba(103,232,249,0.06)' }}>
                              <td style={{ padding: '10px 12px', color: '#22d3ee', fontFamily: 'monospace', fontWeight: 800, fontSize: 12 }}>
                                {p.student_id}
                              </td>
                              <td style={{ padding: '10px 12px', color: 'rgba(224,247,255,0.95)', fontSize: 13 }}>
                                {p.full_name}
                              </td>
                              <td style={{ padding: '10px 12px', fontSize: 12 }}>
                                <span
                                  style={{
                                    fontSize: 11,
                                    fontWeight: 800,
                                    padding: '3px 10px',
                                    borderRadius: 999,
                                    background: 'rgba(74,222,128,0.12)',
                                    border: '1px solid rgba(74,222,128,0.25)',
                                    color: '#4ade80',
                                  }}
                                >
                                  {p.attendance_status || 'present'}
                                </span>
                              </td>
                              <td style={{ padding: '10px 12px', color: 'rgba(186,230,253,0.5)', fontSize: 12 }}>
                                {p.joined_at ? new Date(p.joined_at).toLocaleTimeString() : '—'}
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  )}
                </div>
              </div>
            </div>

            <StudentScannerModal
              open={showScanner}
              onClose={() => setShowScanner(false)}
              sessionId={activeSessionId}
              sessionCode={qrModal.sessionCode}
              onStudentAdded={(list) => {
                if (Array.isArray(list)) setParticipants(list)
              }}
            />
          </div>
        </div>
      )}

    </div>
  )
}