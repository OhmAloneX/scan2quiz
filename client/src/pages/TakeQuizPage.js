import { useState, useEffect, useCallback } from 'react'
import { useParams, useSearchParams, useNavigate }
  from 'react-router-dom'
import GlassCard from '../components/ui/GlassCard'
import api from '../services/api'

export default function TakeQuizPage() {
  const { attemptId }               = useParams()
  const [searchParams]              = useSearchParams()
  const navigate                    = useNavigate()
  const studentToken                = searchParams.get('token')
  const [questions,  setQuestions]  = useState([])
  const [answers,    setAnswers]    = useState({})
  const [current,    setCurrent]    = useState(0)
  const [timeLeft,   setTimeLeft]   = useState(null)
  const [loading,    setLoading]    = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [result,     setResult]     = useState(null)
  const [error,      setError]      = useState('')

  // Axios instance with student token
  const studentApi = {
    get:  (url) => api.get(url, {
      headers: { Authorization: `Bearer ${studentToken}` }
    }),
    post: (url, data) => api.post(url, data, {
      headers: { Authorization: `Bearer ${studentToken}` }
    })
  }

  useEffect(() => {
    async function load() {
      try {
        const res = await studentApi.get(
          `/attempts/${attemptId}/questions`
        )
        setQuestions(res.data.data)
        setTimeLeft(30 * 60)
      } catch (err) {
        setError(
          err.response?.data?.message ||
          'Failed to load questions'
        )
      } finally {
        setLoading(false)
      }
    }
    if (studentToken) load()
    else setError('No student token found')
  }, [attemptId, studentToken])

  const handleSubmit = useCallback(async (auto = false) => {
    if (submitting) return
    if (!auto && questions.length > 0) {
      const answered = Object.keys(answers).length
      if (answered < questions.length) {
        const ok = window.confirm(
          `You answered ${answered} of ` +
          `${questions.length} questions. Submit anyway?`
        )
        if (!ok) return
      }
    }
    setSubmitting(true)
    try {
      const formatted = Object.entries(answers).map(
        ([questionId, choiceId]) => ({
          questionId: +questionId, choiceId
        })
      )
      await studentApi.post(
        `/attempts/${attemptId}/submit`,
        { answers: formatted }
      )
      const res = await studentApi.get(
        `/attempts/${attemptId}/result`
      )
      setResult(res.data.data)
    } catch (err) {
      setError(err.response?.data?.message || 'Submit failed')
      setSubmitting(false)
    }
  }, [answers, attemptId, questions, submitting, studentToken])

  useEffect(() => {
    if (timeLeft === null || result) return
    if (timeLeft <= 0) { handleSubmit(true); return }
    const t = setInterval(
      () => setTimeLeft(p => p - 1), 1000
    )
    return () => clearInterval(t)
  }, [timeLeft, result, handleSubmit])

  function formatTime(s) {
    return `${String(Math.floor(s/60)).padStart(2,'0')}:` +
           `${String(s%60).padStart(2,'0')}`
  }

  const timerColor = timeLeft <= 60
    ? '#f87171' : timeLeft <= 300 ? '#fbbf24' : '#22d3ee'

  // ── Result screen ────────────────────────────────────
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
          maxWidth: 420, width: '100%',
          textAlign: 'center', padding: 36
        }}>
          <div style={{ fontSize: 56, marginBottom: 12 }}>
            {passed ? '🎉' : '😔'}
          </div>
          <h1 style={{
            color: '#e0f7ff', fontSize: 22,
            fontWeight: 700, margin: '0 0 4px'
          }}>
            {passed ? 'Quiz Passed!' : 'Keep Practicing!'}
          </h1>
          <p style={{
            color: 'rgba(186,230,253,0.5)',
            fontSize: 13, margin: '0 0 24px'
          }}>
            {result.quiz_title}
          </p>

          <div style={{
            width:          120,
            height:         120,
            borderRadius:   '50%',
            border:         `4px solid ${passed
              ? '#4ade80' : '#f87171'}`,
            display:        'flex',
            flexDirection:  'column',
            alignItems:     'center',
            justifyContent: 'center',
            margin:         '0 auto 24px',
            background:     passed
              ? 'rgba(74,222,128,0.08)'
              : 'rgba(248,113,113,0.08)'
          }}>
            <span style={{
              fontSize:   32,
              fontWeight: 700,
              color:      passed ? '#4ade80' : '#f87171'
            }}>
              {result.percentage}%
            </span>
            <span style={{
              fontSize: 11,
              color:    'rgba(186,230,253,0.5)'
            }}>
              {passed ? 'PASSED' : 'FAILED'}
            </span>
          </div>

          <div style={{
            display:             'grid',
            gridTemplateColumns: '1fr 1fr',
            gap:                 12,
            marginBottom:        20
          }}>
            {[
              ['Score',  `${result.score}/${result.total_points}`],
              ['Status', passed ? '✅ Passed' : '❌ Failed']
            ].map(([label, value]) => (
              <div key={label} style={{
                background:   'rgba(255,255,255,0.04)',
                border:       '1px solid rgba(103,232,249,0.15)',
                borderRadius: 12,
                padding:      '10px'
              }}>
                <p style={{
                  color:         'rgba(186,230,253,0.5)',
                  fontSize:      10,
                  margin:        '0 0 4px',
                  textTransform: 'uppercase'
                }}>
                  {label}
                </p>
                <p style={{
                  color:      '#e0f7ff',
                  fontSize:   14,
                  fontWeight: 600,
                  margin:     0
                }}>
                  {value}
                </p>
              </div>
            ))}
          </div>

          <p style={{
            color:    'rgba(186,230,253,0.4)',
            fontSize: 13,
            margin:   0
          }}>
            You may close this page or return it to your teacher.
          </p>
        </GlassCard>
      </div>
    )
  }

  if (loading) return (
    <div style={{
      minHeight:      '100vh',
      display:        'flex',
      alignItems:     'center',
      justifyContent: 'center',
      background:     '#0a1628'
    }}>
      <p style={{ color: '#22d3ee', fontFamily: 'inherit' }}>
        Loading quiz...
      </p>
    </div>
  )

  if (error) return (
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
        <p style={{
          color: 'rgba(186,230,253,0.4)', fontSize: 13, margin: 0
        }}>
          Please ask your teacher for a new QR code.
        </p>
      </GlassCard>
    </div>
  )

  const q = questions[current]

  return (
    <div style={{
      minHeight:  '100vh',
      background: 'linear-gradient(135deg,' +
        '#060d1f 0%,#0a1628 50%,#0d1f3c 100%)',
      fontFamily: "'Segoe UI',system-ui,sans-serif",
      padding:    '20px 16px'
    }}>
      <div style={{ maxWidth: 600, margin: '0 auto' }}>

        {/* Header */}
        <div style={{
          display:        'flex',
          justifyContent: 'space-between',
          alignItems:     'center',
          marginBottom:   16
        }}>
          <div>
            <p style={{
              color:    'rgba(186,230,253,0.5)',
              fontSize: 12, margin: '0 0 4px'
            }}>
              Question {current + 1} of {questions.length}
            </p>
            <div style={{
              width:        160,
              height:       4,
              borderRadius: 2,
              background:   'rgba(255,255,255,0.1)'
            }}>
              <div style={{
                height:       '100%',
                borderRadius: 2,
                background:   'linear-gradient(90deg,#22d3ee,#6366f1)',
                width:        `${((current+1)/questions.length)*100}%`,
                transition:   'width 0.3s'
              }}/>
            </div>
          </div>

          {timeLeft !== null && (
            <div style={{
              display:      'flex',
              alignItems:   'center',
              gap:          6,
              background:   'rgba(255,255,255,0.06)',
              border:       `1px solid ${timerColor}44`,
              borderRadius: 10,
              padding:      '6px 14px'
            }}>
              <span>⏱</span>
              <span style={{
                fontFamily: 'monospace',
                fontSize:   16,
                fontWeight: 700,
                color:      timerColor
              }}>
                {formatTime(timeLeft)}
              </span>
            </div>
          )}
        </div>

        {/* Question card */}
        <GlassCard glow style={{ marginBottom: 14 }}>
          <div style={{
            display:      'inline-block',
            background:   'rgba(34,211,238,0.1)',
            border:       '1px solid rgba(34,211,238,0.25)',
            borderRadius: 8,
            padding:      '3px 10px',
            fontSize:     11,
            color:        '#22d3ee',
            fontWeight:   600,
            marginBottom: 12
          }}>
            Q{current + 1}
            {q?.points > 1 && ` · ${q.points} pts`}
          </div>

          <h2 style={{
            color:      '#e0f7ff',
            fontSize:   17,
            fontWeight: 600,
            margin:     '0 0 20px',
            lineHeight: 1.5
          }}>
            {q?.question_text}
          </h2>

          <div style={{
            display: 'flex', flexDirection: 'column', gap: 10
          }}>
            {q?.choices?.map(choice => {
              const selected = answers[q.id] === choice.id
              return (
                <button
                  key={choice.id}
                  onClick={() => setAnswers(prev => ({
                    ...prev, [q.id]: choice.id
                  }))}
                  style={{
                    display:      'flex',
                    alignItems:   'center',
                    gap:          14,
                    padding:      '13px 16px',
                    borderRadius: 12,
                    border:       `1px solid ${selected
                      ? 'rgba(34,211,238,0.6)'
                      : 'rgba(103,232,249,0.15)'}`,
                    background:   selected
                      ? 'rgba(34,211,238,0.12)'
                      : 'rgba(255,255,255,0.03)',
                    cursor:       'pointer',
                    textAlign:    'left',
                    width:        '100%',
                    fontFamily:   'inherit',
                    transition:   'all 0.15s'
                  }}>
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
                    color:    selected
                      ? '#e0f7ff'
                      : 'rgba(186,230,253,0.8)',
                    fontSize: 15
                  }}>
                    {choice.choice_text}
                  </span>
                </button>
              )
            })}
          </div>
        </GlassCard>

        {/* Navigation */}
        <div style={{
          display:        'flex',
          justifyContent: 'space-between',
          alignItems:     'center',
          gap:            10
        }}>
          <button
            onClick={() => setCurrent(c => c - 1)}
            disabled={current === 0}
            style={{
              padding:      '11px 20px',
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
            ← Prev
          </button>

          {/* Dots */}
          <div style={{
            display:        'flex',
            gap:            5,
            flexWrap:       'wrap',
            justifyContent: 'center',
            flex:           1
          }}>
            {questions.map((qu, i) => (
              <button key={i}
                onClick={() => setCurrent(i)}
                style={{
                  width:        24,
                  height:       24,
                  borderRadius: '50%',
                  border:       `1px solid ${
                    i === current
                      ? 'rgba(34,211,238,0.8)'
                      : answers[qu.id]
                      ? 'rgba(74,222,128,0.4)'
                      : 'rgba(103,232,249,0.2)'}`,
                  background:   i === current
                    ? 'rgba(34,211,238,0.2)'
                    : answers[qu.id]
                    ? 'rgba(74,222,128,0.1)'
                    : 'transparent',
                  color:    i === current
                    ? '#22d3ee'
                    : answers[qu.id]
                    ? '#4ade80'
                    : 'rgba(186,230,253,0.4)',
                  fontSize: 10,
                  cursor:   'pointer',
                  fontFamily: 'inherit'
                }}>
                {i + 1}
              </button>
            ))}
          </div>

          {current < questions.length - 1 ? (
            <button
              onClick={() => setCurrent(c => c + 1)}
              style={{
                padding:      '11px 20px',
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
                padding:      '11px 20px',
                borderRadius: 12,
                border:       '1px solid rgba(74,222,128,0.4)',
                background:   'rgba(74,222,128,0.1)',
                color:        '#4ade80',
                fontSize:     14,
                fontWeight:   600,
                cursor:       submitting ? 'default' : 'pointer',
                fontFamily:   'inherit'
              }}>
              {submitting ? 'Submitting...' : 'Submit ✓'}
            </button>
          )}
        </div>

        <p style={{
          textAlign: 'center',
          color:     'rgba(186,230,253,0.3)',
          fontSize:  11,
          marginTop: 12
        }}>
          {Object.keys(answers).length} of {questions.length} answered
        </p>
      </div>
    </div>
  )
}