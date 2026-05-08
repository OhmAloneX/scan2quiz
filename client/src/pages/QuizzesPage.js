import { useState, useEffect } from 'react'
import { } from 'react-router-dom'
import Sidebar            from '../components/layout/Sidebar'
import GlassCard          from '../components/ui/GlassCard'
import {
  getQuizzes, createQuiz, deleteQuiz, addQuestion
} from '../services/quizService'
import { createSession }  from '../services/sessionService'

export default function QuizzesPage() {
  
  const [quizzes,   setQuizzes]   = useState([])
  const [loading,   setLoading]   = useState(true)
  const [showForm,  setShowForm]  = useState(false)
  const [showQForm, setShowQForm] = useState(null)
  const [qrModal,   setQrModal]   = useState(null)
  const [form, setForm] = useState({
    title: '', description: '', subject: '',
    time_limit: 30, passing_score: 75
  })
  const [qForm, setQForm] = useState({
    question_text: '', type: 'multiple_choice', points: 1,
    choices: [
      { text: '', isCorrect: true  },
      { text: '', isCorrect: false },
      { text: '', isCorrect: false },
      { text: '', isCorrect: false },
    ]
  })

  useEffect(() => { loadQuizzes() }, [])

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

  async function handleCreateQuiz(e) {
    e.preventDefault()
    try {
      await createQuiz(form)
      setShowForm(false)
      setForm({
        title: '', description: '', subject: '',
        time_limit: 30, passing_score: 75
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
    try {
      await addQuestion(quizId, qForm)
      setShowQForm(null)
      setQForm({
        question_text: '',
        type:          'multiple_choice',
        points:        1,
        tfCorrect:     undefined,
        choices: [
          { text: '', isCorrect: true  },
          { text: '', isCorrect: false },
          { text: '', isCorrect: false },
          { text: '', isCorrect: false },
        ]
      })
      loadQuizzes()
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to add question')
    }
  }

  async function handleStartSession(quizId) {
    try {
      const res = await createSession(quizId)
      setQrModal(res.data.data)
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to create session')
    }
  }

  const inputStyle = {
    width:        '100%',
    padding:      '10px 14px',
    background:   'rgba(255,255,255,0.06)',
    border:       '1px solid rgba(103,232,249,0.25)',
    borderRadius: 10,
    color:        '#e0f7ff',
    fontSize:     13,
    outline:      'none',
    boxSizing:    'border-box'
  }

  const labelStyle = {
    display:    'block',
    fontSize:   12,
    color:      'rgba(186,230,253,0.6)',
    marginBottom: 4
  }

  return (
    <div style={{
      display:    'flex',
      minHeight:  '100vh',
      background: 'linear-gradient(135deg,#060d1f 0%,#0a1628 50%,#0d1f3c 100%)',
      fontFamily: "'Segoe UI',system-ui,sans-serif"
    }}>
      <Sidebar />

      <div style={{ flex: 1, overflow: 'auto' }}>
        {/* Top bar */}
        <div style={{
          padding:      '16px 28px',
          background:   'rgba(255,255,255,0.03)',
          backdropFilter: 'blur(16px)',
          borderBottom: '1px solid rgba(103,232,249,0.08)',
          display:      'flex',
          alignItems:   'center',
          justifyContent: 'space-between'
        }}>
          <div>
            <h1 style={{
              color: '#e0f7ff', fontSize: 20,
              fontWeight: 600, margin: 0
            }}>
              Quizzes
            </h1>
            <p style={{
              color: 'rgba(186,230,253,0.5)',
              fontSize: 13, margin: '2px 0 0'
            }}>
              Create and manage your quizzes
            </p>
          </div>
          <button onClick={() => setShowForm(true)} style={{
            padding:      '10px 20px',
            background:   'linear-gradient(135deg,' +
              'rgba(34,211,238,0.2),rgba(99,102,241,0.2))',
            border:       '1px solid rgba(34,211,238,0.45)',
            borderRadius: 12,
            color:        '#22d3ee',
            fontSize:     14,
            fontWeight:   600,
            cursor:       'pointer'
          }}>
            + New Quiz
          </button>
        </div>

        <div style={{ padding: '24px 28px' }}>

          {/* Create Quiz Form */}
          {showForm && (
            <GlassCard glow style={{ marginBottom: 24 }}>
              <h2 style={{
                color: '#e0f7ff', fontSize: 16,
                fontWeight: 600, margin: '0 0 20px'
              }}>
                Create New Quiz
              </h2>
              <form onSubmit={handleCreateQuiz}>
                <div style={{
                  display: 'grid',
                  gridTemplateColumns: '1fr 1fr',
                  gap: 16, marginBottom: 16
                }}>
                  <div>
                    <label style={labelStyle}>Title *</label>
                    <input style={inputStyle} required
                      value={form.title}
                      onChange={e => setForm({
                        ...form, title: e.target.value
                      })}
                      placeholder="e.g. CS101 Midterm"
                    />
                  </div>
                  <div>
                    <label style={labelStyle}>Subject</label>
                    <input style={inputStyle}
                      value={form.subject}
                      onChange={e => setForm({
                        ...form, subject: e.target.value
                      })}
                      placeholder="e.g. Computer Science"
                    />
                  </div>
                  <div>
                    <label style={labelStyle}>
                      Time Limit (minutes)
                    </label>
                    <input style={inputStyle} type="number"
                      value={form.time_limit}
                      onChange={e => setForm({
                        ...form, time_limit: +e.target.value
                      })}
                    />
                  </div>
                  <div>
                    <label style={labelStyle}>
                      Passing Score (%)
                    </label>
                    <input style={inputStyle} type="number"
                      value={form.passing_score}
                      onChange={e => setForm({
                        ...form, passing_score: +e.target.value
                      })}
                    />
                  </div>
                </div>
                <div style={{ marginBottom: 16 }}>
                  <label style={labelStyle}>Description</label>
                  <textarea style={{
                    ...inputStyle, height: 80, resize: 'vertical'
                  }}
                    value={form.description}
                    onChange={e => setForm({
                      ...form, description: e.target.value
                    })}
                    placeholder="Optional description..."
                  />
                </div>
                <div style={{ display: 'flex', gap: 10 }}>
                  <button type="submit" style={{
                    padding:      '10px 24px',
                    background:   'rgba(34,211,238,0.15)',
                    border:       '1px solid rgba(34,211,238,0.4)',
                    borderRadius: 10,
                    color:        '#22d3ee',
                    fontWeight:   600,
                    cursor:       'pointer',
                    fontSize:     13
                  }}>
                    Create Quiz
                  </button>
                  <button type="button"
                    onClick={() => setShowForm(false)} style={{
                      padding:      '10px 24px',
                      background:   'transparent',
                      border:       '1px solid rgba(103,232,249,0.2)',
                      borderRadius: 10,
                      color:        'rgba(186,230,253,0.6)',
                      cursor:       'pointer',
                      fontSize:     13
                    }}>
                    Cancel
                  </button>
                </div>
              </form>
            </GlassCard>
          )}

          {/* Quiz list */}
          {loading ? (
            <p style={{ color: 'rgba(186,230,253,0.5)' }}>
              Loading quizzes...
            </p>
          ) : quizzes.length === 0 ? (
            <GlassCard style={{ textAlign: 'center', padding: 48 }}>
              <p style={{
                color: 'rgba(186,230,253,0.4)', fontSize: 15
              }}>
                No quizzes yet. Click "+ New Quiz" to create one.
              </p>
            </GlassCard>
          ) : (
            <div style={{
              display: 'flex', flexDirection: 'column', gap: 16
            }}>
              {quizzes.map(quiz => (
                <GlassCard key={quiz.id}>
                  <div style={{
                    display:        'flex',
                    justifyContent: 'space-between',
                    alignItems:     'flex-start'
                  }}>
                    <div style={{ flex: 1 }}>
                      <div style={{
                        display: 'flex', alignItems: 'center',
                        gap: 10, marginBottom: 4
                      }}>
                        <h3 style={{
                          color: '#e0f7ff', fontSize: 16,
                          fontWeight: 600, margin: 0
                        }}>
                          {quiz.title}
                        </h3>
                        {quiz.subject && (
                          <span style={{
                            fontSize:     11,
                            padding:      '2px 8px',
                            borderRadius: 20,
                            background:   'rgba(99,102,241,0.15)',
                            border:       '1px solid rgba(99,102,241,0.3)',
                            color:        '#a5b4fc'
                          }}>
                            {quiz.subject}
                          </span>
                        )}
                      </div>
                      {quiz.description && (
                        <p style={{
                          color: 'rgba(186,230,253,0.5)',
                          fontSize: 13, margin: '0 0 10px'
                        }}>
                          {quiz.description}
                        </p>
                      )}
                      <div style={{
                        display: 'flex', gap: 16, flexWrap: 'wrap'
                      }}>
                        {[
                          ['📋', `${quiz.question_count} questions`],
                          ['⏱', `${quiz.time_limit} min`],
                          ['✅', `Pass: ${quiz.passing_score}%`],
                          ['🔳', `${quiz.session_count} sessions`],
                        ].map(([icon, text]) => (
                          <span key={text} style={{
                            color: 'rgba(186,230,253,0.5)',
                            fontSize: 12
                          }}>
                            {icon} {text}
                          </span>
                        ))}
                      </div>
                    </div>

                    {/* Action buttons */}
                    <div style={{
                      display: 'flex', gap: 8, flexShrink: 0
                    }}>
                      <button
                        onClick={() => setShowQForm(
                          showQForm === quiz.id ? null : quiz.id
                        )}
                        style={{
                          padding:      '7px 14px',
                          background:   'rgba(99,102,241,0.15)',
                          border:       '1px solid rgba(99,102,241,0.3)',
                          borderRadius: 10,
                          color:        '#a5b4fc',
                          fontSize:     12,
                          cursor:       'pointer'
                        }}>
                        + Question
                      </button>
                      <button
                        onClick={() => handleStartSession(quiz.id)}
                        style={{
                          padding:      '7px 14px',
                          background:   'rgba(34,211,238,0.15)',
                          border:       '1px solid rgba(34,211,238,0.3)',
                          borderRadius: 10,
                          color:        '#22d3ee',
                          fontSize:     12,
                          cursor:       'pointer'
                        }}>
                        ▶ Start Session
                      </button>
                      <button
                        onClick={() => handleDeleteQuiz(quiz.id)}
                        style={{
                          padding:      '7px 14px',
                          background:   'rgba(248,113,113,0.1)',
                          border:       '1px solid rgba(248,113,113,0.3)',
                          borderRadius: 10,
                          color:        '#f87171',
                          fontSize:     12,
                          cursor:       'pointer'
                        }}>
                        🗑
                      </button>
                    </div>
                  </div>

                  {/* Add Question Form */}
                  {showQForm === quiz.id && (
                    <div style={{
                      marginTop:  20,
                      paddingTop: 20,
                      borderTop:  '1px solid rgba(103,232,249,0.1)'
                    }}>
                      <h4 style={{
                        color: '#e0f7ff', fontSize: 14,
                        fontWeight: 600, margin: '0 0 14px'
                      }}>
                        Add Question
                      </h4>
                      <form onSubmit={e =>
                        handleAddQuestion(e, quiz.id)}>
                        <div style={{ marginBottom: 12 }}>
                          <label style={labelStyle}>
                            Question Text *
                          </label>
                          <textarea
                            style={{
                              ...inputStyle,
                              height: 70,
                              resize: 'vertical'
                            }}
                            required
                            value={qForm.question_text}
                            onChange={e => setQForm({
                              ...qForm,
                              question_text: e.target.value
                            })}
                            placeholder="Enter your question..."
                          />
                        </div>

                        <div style={{
                          display: 'grid',
                          gridTemplateColumns: '1fr 1fr',
                          gap: 12, marginBottom: 12
                        }}>
                          <div>
                            <label style={labelStyle}>Type</label>
                            <select style={inputStyle}
                              value={qForm.type}
                              onChange={e => {
                                const newType = e.target.value
                                setQForm({
                                  ...qForm,
                                  type: newType,
                                  tfCorrect: undefined,
                                  choices: newType === 'true_false'
                                    ? [
                                        { text: 'True',  isCorrect: true  },
                                        { text: 'False', isCorrect: false }
                                      ]
                                    : [
                                        { text: '', isCorrect: true  },
                                        { text: '', isCorrect: false },
                                        { text: '', isCorrect: false },
                                        { text: '', isCorrect: false },
                                      ]
                                })
                              }}>
                              <option value="multiple_choice">
                                Multiple Choice
                              </option>
                              <option value="true_false">
                                True / False
                              </option>
                            </select>
                          </div>
                          <div>
                            <label style={labelStyle}>Points</label>
                            <input style={inputStyle} type="number"
                              min="1" value={qForm.points}
                              onChange={e => setQForm({
                                ...qForm, points: +e.target.value
                              })}
                            />
                          </div>
                        </div>

                        {/* Choices */}
                        <div style={{ marginBottom: 14 }}>
                          <label style={labelStyle}>
                            Choices (check the correct answer)
                          </label>
                          {/* True/False choices */}
                            {qForm.type === 'true_false' && (
                              [
                                { text: 'True',  val: true  },
                                { text: 'False', val: false }
                              ].map((opt, i) => {
                                const tfChoices = [
                                  { text: 'True',  isCorrect: true  },
                                  { text: 'False', isCorrect: false }
                                ]
                                const isSelected = qForm.choices.length === 2
                                  ? qForm.choices[i]?.isCorrect
                                  : opt.val === true
                                    ? qForm.choices[0]?.isCorrect
                                    : !qForm.choices[0]?.isCorrect

                                return (
                                  <div key={i} style={{
                                    display:      'flex',
                                    alignItems:   'center',
                                    gap:          8,
                                    marginBottom: 8
                                  }}>
                                    <input
                                      type="radio"
                                      name="tf_correct"
                                      checked={
                                        qForm.tfCorrect === undefined
                                          ? opt.val === true
                                          : qForm.tfCorrect === opt.val
                                      }
                                      onChange={() => setQForm({
                                        ...qForm,
                                        tfCorrect: opt.val,
                                        choices: [
                                          { text: 'True',  isCorrect: opt.val === true  },
                                          { text: 'False', isCorrect: opt.val === false }
                                        ]
                                      })}
                                      style={{ accentColor: '#22d3ee', cursor: 'pointer' }}
                                    />
                                    <span style={{ color: '#e0f7ff', fontSize: 13 }}>
                                      {opt.text}
                                    </span>
                                  </div>
                                )
                              })
                            )}

                            {/* Multiple choice choices */}
                            {qForm.type === 'multiple_choice' && (
                              qForm.choices.map((choice, i) => (
                                <div key={i} style={{
                                  display:      'flex',
                                  alignItems:   'center',
                                  gap:          8,
                                  marginBottom: 8
                                }}>
                                  <input
                                    type="radio"
                                    name="mc_correct"
                                    checked={choice.isCorrect}
                                    onChange={() => setQForm({
                                      ...qForm,
                                      choices: qForm.choices.map((c, j) => ({
                                        ...c, isCorrect: j === i
                                      }))
                                    })}
                                    style={{ accentColor: '#22d3ee', cursor: 'pointer' }}
                                  />
                                  <input
                                    style={{ ...inputStyle, margin: 0 }}
                                    value={choice.text}
                                    onChange={e => setQForm({
                                      ...qForm,
                                      choices: qForm.choices.map((c, j) =>
                                        j === i ? { ...c, text: e.target.value } : c
                                      )
                                    })}
                                    placeholder={`Choice ${i + 1}`}
                                  />
                                </div>
                              ))
                            )}
                        </div>

                        <div style={{ display: 'flex', gap: 10 }}>
                          <button type="submit" style={{
                            padding:      '8px 20px',
                            background:   'rgba(99,102,241,0.2)',
                            border:       '1px solid rgba(99,102,241,0.4)',
                            borderRadius: 10,
                            color:        '#a5b4fc',
                            fontWeight:   600,
                            cursor:       'pointer',
                            fontSize:     13
                          }}>
                            Add Question
                          </button>
                          <button type="button"
                            onClick={() => setShowQForm(null)}
                            style={{
                              padding:      '8px 20px',
                              background:   'transparent',
                              border:       '1px solid rgba(103,232,249,0.2)',
                              borderRadius: 10,
                              color:        'rgba(186,230,253,0.6)',
                              cursor:       'pointer',
                              fontSize:     13
                            }}>
                            Cancel
                          </button>
                        </div>
                      </form>
                    </div>
                  )}
                </GlassCard>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* QR Modal */}
      {qrModal && (
        <div style={{
          position:        'fixed',
          inset:           0,
          background:      'rgba(0,0,0,0.7)',
          display:         'flex',
          alignItems:      'center',
          justifyContent:  'center',
          zIndex:          100,
          backdropFilter:  'blur(4px)'
        }}>
          <div style={{
            background:     'rgba(10,22,40,0.95)',
            border:         '1px solid rgba(34,211,238,0.3)',
            borderRadius:   24,
            padding:        36,
            textAlign:      'center',
            maxWidth:       400,
            width:          '90%',
            boxShadow:      '0 0 60px rgba(34,211,238,0.15)',
            display:        'flex',
            flexDirection:  'column',
            alignItems:     'center'
          }}>
            <h2 style={{
              color: '#e0f7ff', fontSize: 18,
              fontWeight: 600, margin: '0 0 4px'
            }}>
              Session Started! 🎉
            </h2>
            <p style={{
              color: 'rgba(186,230,253,0.5)',
              fontSize: 13, margin: '0 0 20px'
            }}>
              {qrModal.quizTitle}
            </p>

            {/* QR Code */}
            <div style={{
                display:        'flex',
                justifyContent: 'center',
                alignItems:     'center',
                marginBottom:   16
            }}>
                <img src={qrModal.qrImage} alt="QR Code"
                    style={{
                        width:        200,
                        height:       200,
                        borderRadius: 12,
                        display:      'block',
                        margin:       '0 auto'
                    }}
                />
            </div>

            {/* Session code */}
            <div style={{
              background:   'rgba(34,211,238,0.1)',
              border:       '1px solid rgba(34,211,238,0.3)',
              borderRadius: 12,
              padding:      '12px 20px',
              marginBottom: 20
            }}>
              <p style={{
                color: 'rgba(186,230,253,0.5)',
                fontSize: 11, margin: '0 0 4px',
                textTransform: 'uppercase', letterSpacing: '0.8px'
              }}>
                Session Code
              </p>
              <p style={{
                color: '#22d3ee', fontSize: 28,
                fontWeight: 700, margin: 0,
                fontFamily: 'monospace', letterSpacing: 4
              }}>
                {qrModal.sessionCode}
              </p>
            </div>

            <button onClick={() => setQrModal(null)} style={{
              padding:      '10px 28px',
              background:   'rgba(34,211,238,0.15)',
              border:       '1px solid rgba(34,211,238,0.4)',
              borderRadius: 12,
              color:        '#22d3ee',
              fontWeight:   600,
              cursor:       'pointer',
              fontSize:     14
            }}>
              Close
            </button>
          </div>
        </div>
      )}
    </div>
  )
}