import { useState, useEffect } from 'react'
import { useSearchParams, useNavigate } from 'react-router-dom'
import api from '../services/api'

export default function JoinPage() {
  const [searchParams]              = useSearchParams()
  const navigate                    = useNavigate()
  const [step,      setStep]        = useState('identify')
  const [student,   setStudent]     = useState(null)
  const [session,   setSession]     = useState(null)
  const [studentId, setStudentId]   = useState('')
  const [error,     setError]       = useState('')
  const [loading,   setLoading]     = useState(false)
  const [joining,   setJoining]     = useState(false)

  const token = searchParams.get('token')
  const code  = searchParams.get('code')
  const quiz  = searchParams.get('quiz')

  // Verify session on load
  useEffect(() => {
    if (!token) {
      setError('Invalid QR code — no session token found.')
      return
    }
    verifySession()
  }, [token])

  async function verifySession() {
    setLoading(true)
    try {
      const res = await api.post('/scan', {
        type:  'QR_CODE',
        value: JSON.stringify({ token, code, quiz })
      })
      if (res.data.success) {
        setSession(res.data.session)
      } else {
        setError(res.data.message || 'Session not found')
      }
    } catch (err) {
        const msg = err.response?.data?.message
        if (!msg && !err.response) {
        // Network error — backend unreachable
        setError(
            'Cannot reach server. Make sure you are on the ' +
            'same WiFi network as the teacher\'s computer.'
        )
        } else {
        setError(msg || 'Session expired or not found')
        }
    } finally {
      setLoading(false)
    }
  }

  async function handleIdentify(e) {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      // Try barcode login first
      const res = await api.post('/auth/barcode-login', {
        barcode: studentId.trim()
      })
      setStudent(res.data.student)
      // Store student token
      localStorage.setItem('s2q_student_token', res.data.token)
      setStep('confirm')
    } catch {
      // Try student_id as barcode fallback
      setError('Student ID not found. Check your ID number and try again.')
    } finally {
      setLoading(false)
    }
  }

  async function handleJoin() {
    setJoining(true)
    setError('')
    try {
      // Use student token
      const studentToken = localStorage.getItem('s2q_student_token')
      const res = await api.post(
        `/sessions/${session.id}/join`,
        {},
        {
          headers: {
            Authorization: `Bearer ${studentToken}`
          }
        }
      )
      const attemptId = res.data.data.id
      // Navigate to quiz page
      navigate(`/take-quiz/${attemptId}?token=${studentToken}`)
    } catch (err) {
      setError(
        err.response?.data?.message || 'Failed to join session'
      )
      setJoining(false)
    }
  }

  const cardStyle = {
    background:           'rgba(255,255,255,0.055)',
    backdropFilter:       'blur(24px)',
    WebkitBackdropFilter: 'blur(24px)',
    border:               '1px solid rgba(103,232,249,0.18)',
    borderRadius:         24,
    boxShadow:            '0 8px 48px rgba(0,0,0,0.4)',
    padding:              '32px 28px'
  }

  const inputStyle = {
    width:        '100%',
    padding:      '14px 16px',
    background:   'rgba(255,255,255,0.06)',
    border:       '1px solid rgba(103,232,249,0.25)',
    borderRadius: 12,
    color:        '#e0f7ff',
    fontSize:     16,
    outline:      'none',
    fontFamily:   'inherit',
    boxSizing:    'border-box',
    textAlign:    'center',
    letterSpacing: 2
  }

  const btnStyle = {
    width:        '100%',
    padding:      '15px',
    background:   'linear-gradient(135deg,' +
      'rgba(34,211,238,0.2),rgba(99,102,241,0.2))',
    border:       '1px solid rgba(34,211,238,0.45)',
    borderRadius: 14,
    color:        '#22d3ee',
    fontSize:     16,
    fontWeight:   600,
    cursor:       'pointer',
    fontFamily:   'inherit'
  }

  return (
    <div style={{
      minHeight:      '100vh',
      display:        'flex',
      alignItems:     'center',
      justifyContent: 'center',
      background:     'linear-gradient(135deg,' +
        '#060d1f 0%,#0a1628 50%,#0d1f3c 100%)',
      fontFamily:     "'Segoe UI',system-ui,sans-serif",
      padding:        '20px 16px'
    }}>
      {/* Ambient blobs */}
      <div style={{
        position:   'fixed', top: '5%', left: '10%',
        width: 300, height: 300, borderRadius: '50%',
        background: 'radial-gradient(circle,' +
          'rgba(34,211,238,0.1) 0%,transparent 70%)',
        pointerEvents: 'none'
      }}/>
      <div style={{
        position:   'fixed', bottom: '5%', right: '5%',
        width: 280, height: 280, borderRadius: '50%',
        background: 'radial-gradient(circle,' +
          'rgba(99,102,241,0.1) 0%,transparent 70%)',
        pointerEvents: 'none'
      }}/>

      <div style={{ width: '100%', maxWidth: 420 }}>

        {/* Logo */}
        <div style={{
          textAlign: 'center', marginBottom: 24
        }}>
          <div style={{
            display:        'inline-flex',
            alignItems:     'center',
            gap:            10
          }}>
            <div style={{
              width:          40,
              height:         40,
              borderRadius:   12,
              background:     'linear-gradient(135deg,#22d3ee,#6366f1)',
              display:        'flex',
              alignItems:     'center',
              justifyContent: 'center',
              fontWeight:     700,
              color:          '#0f172a',
              fontSize:       18,
              boxShadow:      '0 0 18px rgba(34,211,238,0.4)'
            }}>
              S
            </div>
            <span style={{
              fontFamily: 'monospace',
              fontSize:   20,
              fontWeight: 700,
              color:      '#e0f7ff'
            }}>
              Scan<span style={{ color: '#22d3ee' }}>2</span>Quiz
            </span>
          </div>
        </div>

        {/* Loading state */}
        {loading && step === 'identify' && (
          <div style={{ ...cardStyle, textAlign: 'center' }}>
            <div style={{
              width:        40,
              height:       40,
              border:       '3px solid rgba(34,211,238,0.2)',
              borderTop:    '3px solid #22d3ee',
              borderRadius: '50%',
              margin:       '0 auto 16px',
              animation:    'spin 0.75s linear infinite'
            }}/>
            <p style={{
              color: 'rgba(186,230,253,0.6)', fontSize: 14, margin: 0
            }}>
              Verifying session...
            </p>
            <style>{`
              @keyframes spin { to { transform: rotate(360deg) } }
            `}</style>
          </div>
        )}

        {/* Error state — invalid QR */}
        {error && !session && !loading && (
          <div style={{ ...cardStyle, textAlign: 'center' }}>
            <div style={{ fontSize: 48, marginBottom: 16 }}>❌</div>
            <h2 style={{
              color: '#f87171', fontSize: 18,
              fontWeight: 600, margin: '0 0 8px'
            }}>
              Session Error
            </h2>
            <p style={{
              color: 'rgba(186,230,253,0.5)',
              fontSize: 14, margin: '0 0 20px'
            }}>
              {error}
            </p>
            <p style={{
              color: 'rgba(186,230,253,0.35)', fontSize: 12, margin: 0
            }}>
              Ask your teacher to generate a new QR code
            </p>
          </div>
        )}

        {/* Step 1 — Identify student */}
        {session && step === 'identify' && (
          <div style={cardStyle}>
            {/* Session info */}
            <div style={{
              background:   'rgba(34,211,238,0.08)',
              border:       '1px solid rgba(34,211,238,0.2)',
              borderRadius: 12,
              padding:      '12px 16px',
              marginBottom: 24,
              textAlign:    'center'
            }}>
              <p style={{
                color:         'rgba(186,230,253,0.5)',
                fontSize:      11,
                margin:        '0 0 4px',
                textTransform: 'uppercase',
                letterSpacing: '0.8px'
              }}>
                Joining Session
              </p>
              <p style={{
                color:      '#e0f7ff',
                fontSize:   16,
                fontWeight: 600,
                margin:     '0 0 4px'
              }}>
                {session.quiz_title}
              </p>
              <p style={{
                color:         '#22d3ee',
                fontSize:      13,
                fontFamily:    'monospace',
                letterSpacing: 2,
                margin:        0
              }}>
                {session.session_code}
              </p>
            </div>

            <h2 style={{
              color: '#e0f7ff', fontSize: 18,
              fontWeight: 600, margin: '0 0 6px',
              textAlign: 'center'
            }}>
              Enter Your Student ID
            </h2>
            <p style={{
              color:    'rgba(186,230,253,0.5)',
              fontSize: 13,
              margin:   '0 0 20px',
              textAlign: 'center'
            }}>
              Type the barcode printed on your school ID card
            </p>

            {error && (
              <div style={{
                marginBottom: 16,
                padding:      '10px 14px',
                background:   'rgba(248,113,113,0.1)',
                border:       '1px solid rgba(248,113,113,0.3)',
                borderRadius: 10,
                color:        '#f87171',
                fontSize:     13
              }}>
                {error}
              </div>
            )}

            <form onSubmit={handleIdentify}>
              <div style={{ marginBottom: 16 }}>
                <input
                  style={inputStyle}
                  type="text"
                  required
                  placeholder="e.g. BC2024001"
                  value={studentId}
                  onChange={e => setStudentId(
                    e.target.value.toUpperCase()
                  )}
                  onFocus={e => {
                    e.target.style.borderColor =
                      'rgba(34,211,238,0.7)'
                    e.target.style.boxShadow =
                      '0 0 0 3px rgba(34,211,238,0.1)'
                  }}
                  onBlur={e => {
                    e.target.style.borderColor =
                      'rgba(103,232,249,0.25)'
                    e.target.style.boxShadow = 'none'
                  }}
                />
                <p style={{
                  color:    'rgba(186,230,253,0.35)',
                  fontSize: 11,
                  margin:   '6px 0 0',
                  textAlign: 'center'
                }}>
                  Found on the back of your school ID card
                </p>
              </div>
              <button
                type="submit"
                disabled={loading || !studentId.trim()}
                style={btnStyle}>
                {loading ? 'Verifying...' : 'Continue →'}
              </button>
            </form>
          </div>
        )}

        {/* Step 2 — Confirm and join */}
        {step === 'confirm' && student && session && (
          <div style={cardStyle}>
            {/* Success checkmark */}
            <div style={{
              width:          64,
              height:         64,
              borderRadius:   '50%',
              background:     'rgba(74,222,128,0.1)',
              border:         '2px solid rgba(74,222,128,0.4)',
              display:        'flex',
              alignItems:     'center',
              justifyContent: 'center',
              margin:         '0 auto 16px',
              fontSize:       28
            }}>
              ✅
            </div>

            <h2 style={{
              color:      '#e0f7ff',
              fontSize:   20,
              fontWeight: 600,
              margin:     '0 0 4px',
              textAlign:  'center'
            }}>
              Welcome, {student.name.split(' ')[0]}!
            </h2>
            <p style={{
              color:    'rgba(186,230,253,0.5)',
              fontSize: 13,
              margin:   '0 0 24px',
              textAlign: 'center'
            }}>
              Student verified successfully
            </p>

            {/* Student info */}
            <div style={{
              background:   'rgba(255,255,255,0.04)',
              border:       '1px solid rgba(103,232,249,0.15)',
              borderRadius: 14,
              padding:      '14px 16px',
              marginBottom: 20
            }}>
              {[
                ['👤', 'Name',     student.name],
                ['🎓', 'ID',       student.student_id],
                ['🏫', 'Section',  student.section || '—'],
              ].map(([icon, label, value]) => (
                <div key={label} style={{
                  display:        'flex',
                  justifyContent: 'space-between',
                  alignItems:     'center',
                  padding:        '6px 0',
                  borderBottom:   label !== 'Section'
                    ? '1px solid rgba(103,232,249,0.08)'
                    : 'none'
                }}>
                  <span style={{
                    color: 'rgba(186,230,253,0.5)',
                    fontSize: 13
                  }}>
                    {icon} {label}
                  </span>
                  <span style={{
                    color: '#e0f7ff', fontSize: 13, fontWeight: 500
                  }}>
                    {value}
                  </span>
                </div>
              ))}
            </div>

            {/* Quiz info */}
            <div style={{
              background:   'rgba(34,211,238,0.08)',
              border:       '1px solid rgba(34,211,238,0.2)',
              borderRadius: 14,
              padding:      '14px 16px',
              marginBottom: 24,
              textAlign:    'center'
            }}>
              <p style={{
                color:    'rgba(186,230,253,0.5)',
                fontSize: 11, margin: '0 0 4px',
                textTransform: 'uppercase', letterSpacing: '0.8px'
              }}>
                You are about to take
              </p>
              <p style={{
                color:      '#e0f7ff',
                fontSize:   16,
                fontWeight: 600,
                margin:     '0 0 4px'
              }}>
                {session.quiz_title}
              </p>
              <p style={{
                color:    'rgba(186,230,253,0.5)',
                fontSize: 12, margin: 0
              }}>
                ⏱ {session.time_limit} minutes time limit
              </p>
            </div>

            {error && (
              <div style={{
                marginBottom: 16,
                padding:      '10px 14px',
                background:   'rgba(248,113,113,0.1)',
                border:       '1px solid rgba(248,113,113,0.3)',
                borderRadius: 10,
                color:        '#f87171',
                fontSize:     13
              }}>
                {error}
              </div>
            )}

            <button
              onClick={handleJoin}
              disabled={joining}
              style={btnStyle}>
              {joining ? 'Joining...' : '🚀 Start Quiz'}
            </button>

            <button
              onClick={() => {
                setStep('identify')
                setStudent(null)
                setStudentId('')
                setError('')
              }}
              style={{
                width:        '100%',
                padding:      '12px',
                background:   'transparent',
                border:       '1px solid rgba(103,232,249,0.15)',
                borderRadius: 14,
                color:        'rgba(186,230,253,0.5)',
                fontSize:     14,
                cursor:       'pointer',
                fontFamily:   'inherit',
                marginTop:    10
              }}>
              Not you? Go back
            </button>
          </div>
        )}
      </div>
    </div>
  )
}