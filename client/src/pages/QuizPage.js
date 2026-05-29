import { useState, useEffect, useCallback } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import GlassCard from '../components/ui/GlassCard'
import { useModal } from '../components/ui/ModalProvider'
import {
  getQuestions, submitAttempt, getResult
} from '../services/sessionService'

export default function QuizPage() {
  const { attemptId }               = useParams()
  const navigate                    = useNavigate()
  const [questions,  setQuestions]  = useState([])
  const [answers,    setAnswers]    = useState({})
  const [current,    setCurrent]    = useState(0)
  const [timeLeft,   setTimeLeft]   = useState(null)
  const [loading,    setLoading]    = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [result,     setResult]     = useState(null)
  const [error,      setError]      = useState('')
  const { openConfirmModal } = useModal()

  // Load questions on mount
  useEffect(() => {
    async function load() {
      try {
        const res = await getQuestions(attemptId)
        setQuestions(res.data.data)
        // Default time limit 30 min
        setTimeLeft(30 * 60)
      } catch (err) {
        setError(
          err.response?.data?.message || 'Failed to load questions'
        )
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [attemptId])

  // Auto-submit when timer hits zero
  const handleSubmit = useCallback(async (auto = false) => {
    if (submitting) return
    if (!auto && questions.length > 0) {
      const answered = Object.keys(answers).length
      if (answered < questions.length) {
        const confirmed = await openConfirmModal({
          title: 'Submit answers',
          message: `You have answered ${answered} of ${questions.length} questions. Submit anyway?`,
          type: 'warning',
          confirmLabel: 'Submit',
          cancelLabel: 'Review answers'
        })
        if (!confirmed) return
      }
    }
    setSubmitting(true)
    try {
      const formatted = Object.entries(answers).map(
        ([questionId, choiceId]) => ({ questionId: +questionId, choiceId })
      )
      await submitAttempt(attemptId, formatted)
      const res = await getResult(attemptId)
      setResult(res.data.data)
    } catch (err) {
      setError(
        err.response?.data?.message || 'Failed to submit'
      )
      setSubmitting(false)
    }
  }, [answers, attemptId, questions, submitting])

  // Countdown timer
  useEffect(() => {
    if (timeLeft === null || result) return
    if (timeLeft <= 0) {
      handleSubmit(true)
      return
    }
    const timer = setInterval(() => {
      setTimeLeft(prev => prev - 1)
    }, 1000)
    return () => clearInterval(timer)
  }, [timeLeft, result, handleSubmit])

  function formatTime(secs) {
    const m = Math.floor(secs / 60)
    const s = secs % 60
    return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`
  }

  const timerColor = timeLeft <= 60
    ? '#f87171'
    : timeLeft <= 300
    ? '#fbbf24'
    : '#22d3ee'

  // ── Result screen ────────────────────────────────────────
  if (result) {
    const passed = result.passed || result.percentage >= 75
    return (
      <div style={{
        minHeight:      '100vh',
        display:        'flex',
        alignItems:     'center',
        justifyContent: 'center',
        background:     'linear-gradient(135deg,' +
          '#060d1f 0%,#0a1628 50%,#0d1f3c 100%)',
        fontFamily:     "'Segoe UI',system-ui,sans-serif",
        padding:        20
      }}>
        <GlassCard glow style={{
          maxWidth:  480,
          width:     '100%',
          textAlign: 'center',
          padding:   40
        }}>
          {/* Pass/Fail icon */}
          <div style={{
            fontSize:     64,
            marginBottom: 16
          }}>
            {passed ? '🎉' : '😔'}
          </div>

          <h1 style={{
            color:      '#e0f7ff',
            fontSize:   24,
            fontWeight: 700,
            margin:     '0 0 4px'
          }}>
            {passed ? 'Congratulations!' : 'Keep Practicing!'}
          </h1>
          <p style={{
            color:    'rgba(186,230,253,0.5)',
            fontSize: 14,
            margin:   '0 0 28px'
          }}>
            {result.quiz_title}
          </p>

          {/* Score circle */}
          <div style={{
            width:          140,
            height:         140,
            borderRadius:   '50%',
            border:         `4px solid ${passed ? '#4ade80' : '#f87171'}`,
            display:        'flex',
            flexDirection:  'column',
            alignItems:     'center',
            justifyContent: 'center',
            margin:         '0 auto 28px',
            background:     passed
              ? 'rgba(74,222,128,0.08)'
              : 'rgba(248,113,113,0.08)'
          }}>
            <span style={{
              fontSize:   36,
              fontWeight: 700,
              color:      passed ? '#4ade80' : '#f87171'
            }}>
              {result.percentage}%
            </span>
            <span style={{
              fontSize: 12,
              color:    'rgba(186,230,253,0.5)'
            }}>
              {passed ? 'PASSED' : 'FAILED'}
            </span>
          </div>

          {/* Score breakdown */}
          <div style={{
            display:             'grid',
            gridTemplateColumns: '1fr 1fr 1fr',
            gap:                 12,
            marginBottom:        28
          }}>
            {[
              ['Score',    `${result.score}/${result.total_points}`],
              ['Correct',  `${result.answers?.filter(
                a => a.is_correct).length ?? '—'
              } items`],
              ['Status',   passed ? 'Passed ✅' : 'Failed ❌'],
            ].map(([label, value]) => (
              <div key={label} style={{
                background:   'rgba(255,255,255,0.04)',
                border:       '1px solid rgba(103,232,249,0.15)',
                borderRadius: 12,
                padding:      '10px 8px'
              }}>
                <p style={{
                  color:    'rgba(186,230,253,0.5)',
                  fontSize: 10,
                  margin:   '0 0 4px',
                  textTransform: 'uppercase'
                }}>
                  {label}
                </p>
                <p style={{
                  color:      '#e0f7ff',
                  fontSize:   13,
                  fontWeight: 600,
                  margin:     0
                }}>
                  {value}
                </p>
              </div>
            ))}
          </div>

          {/* Answer review */}
          {result.answers && result.answers.length > 0 && (
            <div style={{
              textAlign:    'left',
              marginBottom: 24
            }}>
              <p style={{
                color:         'rgba(186,230,253,0.55)',
                fontSize:      11,
                margin:        '0 0 10px',
                textTransform: 'uppercase',
                letterSpacing: '0.8px'
              }}>
                Answer Review
              </p>
              <div style={{
                display:       'flex',
                flexDirection: 'column',
                gap:           8,
                maxHeight:     240,
                overflowY:     'auto'
              }}>
                {result.answers.map((a, i) => (
                  <div key={i} style={{
                    display:      'flex',
                    gap:          10,
                    alignItems:   'flex-start',
                    padding:      '10px 12px',
                    background:   a.is_correct
                      ? 'rgba(74,222,128,0.06)'
                      : 'rgba(248,113,113,0.06)',
                    border: `1px solid ${a.is_correct
                      ? 'rgba(74,222,128,0.2)'
                      : 'rgba(248,113,113,0.2)'}`,
                    borderRadius: 10
                  }}>
                    <span style={{ fontSize: 14, flexShrink: 0 }}>
                      {a.is_correct ? '✅' : '❌'}
                    </span>
                    <div style={{ flex: 1 }}>
                      <p style={{
                        color:    '#e0f7ff',
                        fontSize: 12,
                        margin:   '0 0 3px'
                      }}>
                        {a.question_text}
                      </p>
                      <p style={{
                        color:    'rgba(186,230,253,0.5)',
                        fontSize: 11,
                        margin:   0
                      }}>
                        Your answer: {a.selected_choice || '—'}
                      </p>
                    </div>
                    <span style={{
                      fontSize:   11,
                      fontWeight: 600,
                      color:      a.is_correct
                        ? '#4ade80' : '#f87171',
                      flexShrink: 0
                    }}>
                      +{a.points_earned}pts
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}

          <button
            onClick={() => navigate('/dashboard')}
            style={{
              width:        '100%',
              padding:      14,
              borderRadius: 14,
              background:   'linear-gradient(135deg,' +
                'rgba(34,211,238,0.2),rgba(99,102,241,0.2))',
              border:       '1px solid rgba(34,211,238,0.45)',
              color:        '#22d3ee',
              fontSize:     15,
              fontWeight:   600,
              cursor:       'pointer',
              fontFamily:   'inherit'
            }}>
            Back to Dashboard →
          </button>
        </GlassCard>
      </div>
    )
  }

  // ── Loading state ────────────────────────────────────────
  if (loading) {
    return (
      <div style={{
        minHeight:      '100vh',
        display:        'flex',
        alignItems:     'center',
        justifyContent: 'center',
        background:     '#0a1628'
      }}>
        <p style={{ color: '#22d3ee' }}>Loading quiz...</p>
      </div>
    )
  }

  // ── Error state ──────────────────────────────────────────
  if (error) {
    return (
      <div style={{
        minHeight:      '100vh',
        display:        'flex',
        alignItems:     'center',
        justifyContent: 'center',
        background:     '#0a1628',
        padding:        20
      }}>
        <GlassCard style={{ textAlign: 'center', padding: 32 }}>
          <p style={{
            color: '#f87171', fontSize: 16,
            fontWeight: 600, margin: '0 0 8px'
          }}>
            {error}
          </p>
          <button
            onClick={() => navigate('/dashboard')}
            style={{
              padding:      '10px 24px',
              borderRadius: 12,
              background:   'rgba(34,211,238,0.1)',
              border:       '1px solid rgba(34,211,238,0.3)',
              color:        '#22d3ee',
              cursor:       'pointer',
              fontFamily:   'inherit'
            }}>
            Go to Dashboard
          </button>
        </GlassCard>
      </div>
    )
  }

  const q = questions[current]

  // ── Quiz screen ──────────────────────────────────────────
  return (
    <div style={{
      minHeight:  '100vh',
      background: 'linear-gradient(135deg,' +
        '#060d1f 0%,#0a1628 50%,#0d1f3c 100%)',
      fontFamily: "'Segoe UI',system-ui,sans-serif",
      padding:    '24px 20px'
    }}>
      <div style={{ maxWidth: 680, margin: '0 auto' }}>

        {/* Header — timer + progress */}
        <div style={{
          display:        'flex',
          justifyContent: 'space-between',
          alignItems:     'center',
          marginBottom:   20
        }}>
          {/* Progress */}
          <div>
            <p style={{
              color:    'rgba(186,230,253,0.5)',
              fontSize: 12, margin: '0 0 4px'
            }}>
              Question {current + 1} of {questions.length}
            </p>
            <div style={{
              width:        200,
              height:       4,
              borderRadius: 2,
              background:   'rgba(255,255,255,0.1)'
            }}>
              <div style={{
                height:     '100%',
                borderRadius: 2,
                background:  'linear-gradient(90deg,#22d3ee,#6366f1)',
                width: `${((current + 1) / questions.length) * 100}%`,
                transition: 'width 0.3s'
              }}/>
            </div>
          </div>

          {/* Timer */}
          {timeLeft !== null && (
            <div style={{
              display:      'flex',
              alignItems:   'center',
              gap:          8,
              background:   'rgba(255,255,255,0.06)',
              border:       `1px solid ${timerColor}44`,
              borderRadius: 12,
              padding:      '8px 16px'
            }}>
              <span style={{ fontSize: 16 }}>⏱</span>
              <span style={{
                fontFamily: 'monospace',
                fontSize:   18,
                fontWeight: 700,
                color:      timerColor
              }}>
                {formatTime(timeLeft)}
              </span>
            </div>
          )}
        </div>

        {/* Question card */}
        <GlassCard glow style={{ marginBottom: 16 }}>
          {/* Question number badge */}
          <div style={{
            display:      'inline-block',
            background:   'rgba(34,211,238,0.1)',
            border:       '1px solid rgba(34,211,238,0.25)',
            borderRadius: 8,
            padding:      '3px 10px',
            fontSize:     11,
            color:        '#22d3ee',
            fontWeight:   600,
            marginBottom: 14
          }}>
            Question {current + 1}
            {q?.points > 1 && ` · ${q.points} pts`}
          </div>

          <h2 style={{
            color:      '#e0f7ff',
            fontSize:   18,
            fontWeight: 600,
            margin:     '0 0 24px',
            lineHeight: 1.5
          }}>
            {q?.question_text}
          </h2>

          {/* Choices */}
          <div style={{
            display:       'flex',
            flexDirection: 'column',
            gap:           10
          }}>
            {q?.choices?.map((choice) => {
              const selected = answers[q.id] === choice.id
              return (
                <button
                  key={choice.id}
                  onClick={() => setAnswers(prev => ({
                    ...prev, [q.id]: choice.id
                  }))}
                  style={{
                    display:     'flex',
                    alignItems:  'center',
                    gap:         14,
                    padding:     '14px 18px',
                    borderRadius: 14,
                    border:      `1px solid ${selected
                      ? 'rgba(34,211,238,0.6)'
                      : 'rgba(103,232,249,0.15)'}`,
                    background:  selected
                      ? 'rgba(34,211,238,0.12)'
                      : 'rgba(255,255,255,0.03)',
                    cursor:      'pointer',
                    textAlign:   'left',
                    width:       '100%',
                    fontFamily:  'inherit',
                    transition:  'all 0.15s'
                  }}>
                  {/* Radio circle */}
                  <div style={{
                    width:          20,
                    height:         20,
                    borderRadius:   '50%',
                    border:         `2px solid ${selected
                      ? '#22d3ee'
                      : 'rgba(103,232,249,0.3)'}`,
                    background:     selected
                      ? '#22d3ee' : 'transparent',
                    flexShrink:     0,
                    display:        'flex',
                    alignItems:     'center',
                    justifyContent: 'center'
                  }}>
                    {selected && (
                      <div style={{
                        width:        8,
                        height:       8,
                        borderRadius: '50%',
                        background:   '#0a1628'
                      }}/>
                    )}
                  </div>
                  <span style={{
                    color:    selected ? '#e0f7ff' : 'rgba(186,230,253,0.8)',
                    fontSize: 14
                  }}>
                    {choice.choice_text}
                  </span>
                </button>
              )
            })}
          </div>
        </GlassCard>

        {/* Navigation buttons */}
        <div style={{
          display:        'flex',
          justifyContent: 'space-between',
          alignItems:     'center',
          gap:            12
        }}>
          {/* Previous */}
          <button
            onClick={() => setCurrent(c => c - 1)}
            disabled={current === 0}
            style={{
              padding:      '12px 24px',
              borderRadius: 12,
              border:       '1px solid rgba(103,232,249,0.2)',
              background:   'transparent',
              color:        current === 0
                ? 'rgba(186,230,253,0.2)'
                : 'rgba(186,230,253,0.7)',
              fontSize:     14,
              cursor:       current === 0 ? 'default' : 'pointer',
              fontFamily:   'inherit'
            }}>
            ← Previous
          </button>

          {/* Question dots */}
          <div style={{
            display:  'flex',
            gap:      6,
            flexWrap: 'wrap',
            justifyContent: 'center',
            flex:     1
          }}>
            {questions.map((qu, i) => (
              <button key={i}
                onClick={() => setCurrent(i)}
                style={{
                  width:        28,
                  height:       28,
                  borderRadius: '50%',
                  border:       `1px solid ${
                    i === current
                      ? 'rgba(34,211,238,0.8)'
                      : answers[qu.id]
                      ? 'rgba(74,222,128,0.4)'
                      : 'rgba(103,232,249,0.2)'}`,
                  background: i === current
                    ? 'rgba(34,211,238,0.2)'
                    : answers[qu.id]
                    ? 'rgba(74,222,128,0.1)'
                    : 'transparent',
                  color:    i === current
                    ? '#22d3ee'
                    : answers[qu.id]
                    ? '#4ade80'
                    : 'rgba(186,230,253,0.4)',
                  fontSize: 11,
                  cursor:   'pointer',
                  fontFamily: 'inherit'
                }}>
                {i + 1}
              </button>
            ))}
          </div>

          {/* Next or Submit */}
          {current < questions.length - 1 ? (
            <button
              onClick={() => setCurrent(c => c + 1)}
              style={{
                padding:      '12px 24px',
                borderRadius: 12,
                border:       '1px solid rgba(34,211,238,0.4)',
                background:   'rgba(34,211,238,0.1)',
                color:        '#22d3ee',
                fontSize:     14,
                fontWeight:   600,
                cursor:       'pointer',
                fontFamily:   'inherit'
              }}>
              Next →
            </button>
          ) : (
            <button
              onClick={() => handleSubmit(false)}
              disabled={submitting}
              style={{
                padding:      '12px 24px',
                borderRadius: 12,
                border:       '1px solid rgba(74,222,128,0.4)',
                background:   'rgba(74,222,128,0.1)',
                color:        '#4ade80',
                fontSize:     14,
                fontWeight:   600,
                cursor:       submitting ? 'default' : 'pointer',
                fontFamily:   'inherit'
              }}>
              {submitting ? 'Submitting...' : 'Submit Quiz ✓'}
            </button>
          )}
        </div>

        {/* Answered count */}
        <p style={{
          textAlign: 'center',
          color:     'rgba(186,230,253,0.35)',
          fontSize:  11,
          marginTop: 16
        }}>
          {Object.keys(answers).length} of {questions.length} answered
        </p>
      </div>
    </div>
  )
}