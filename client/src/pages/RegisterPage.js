import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import api from '../services/api'

export default function RegisterPage() {
  const navigate = useNavigate()
  const [form, setForm] = useState({
    name:     '',
    email:    '',
    password: '',
    confirm:  ''
  })
  const [error,   setError]   = useState('')
  const [success, setSuccess] = useState('')
  const [loading, setLoading] = useState(false)

  async function handleRegister(e) {
    e.preventDefault()
    setError('')
    setSuccess('')

    // Validate
    if (form.password !== form.confirm) {
      return setError('Passwords do not match')
    }
    if (form.password.length < 6) {
      return setError('Password must be at least 6 characters')
    }

    setLoading(true)
    try {
      await api.post('/auth/register', {
        name:     form.name,
        email:    form.email,
        password: form.password,
        role:     'teacher'
      })
      setSuccess(
        'Registration submitted! Your account is ' +
        'pending admin approval. You will be notified ' +
        'once your account is approved.'
      )
      // Don't redirect — let them read the message
      setTimeout(() => navigate('/login'), 4000)
    } catch (err) {
      setError(err.response?.data?.message || 'Registration failed')
    } finally {
      setLoading(false)
    }
  }

  const inputStyle = {
    width:        '100%',
    padding:      '13px 16px',
    background:   'rgba(255,255,255,0.06)',
    border:       '1px solid rgba(103,232,249,0.25)',
    borderRadius: 12,
    color:        '#e0f7ff',
    fontSize:     14,
    outline:      'none',
    fontFamily:   'inherit',
    boxSizing:    'border-box',
    transition:   'border-color 0.2s, box-shadow 0.2s'
  }

  const labelStyle = {
    display:      'block',
    fontSize:     12,
    color:        'rgba(186,230,253,0.6)',
    marginBottom: 6,
    fontWeight:   500
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
      padding:        20
    }}>
      {/* Ambient blobs */}
      <div style={{
        position:   'fixed', top: '10%', left: '15%',
        width:      400,     height: 400,
        borderRadius: '50%', pointerEvents: 'none',
        background: 'radial-gradient(circle,' +
          'rgba(34,211,238,0.08) 0%,transparent 70%)'
      }}/>
      <div style={{
        position:   'fixed', bottom: '10%', right: '10%',
        width:      360,     height: 360,
        borderRadius: '50%', pointerEvents: 'none',
        background: 'radial-gradient(circle,' +
          'rgba(99,102,241,0.09) 0%,transparent 70%)'
      }}/>

      <div style={{ width: '100%', maxWidth: 460 }}>
        {/* Logo */}
        <div style={{ textAlign: 'center', marginBottom: 28 }}>
          <div style={{
            display:        'inline-flex',
            alignItems:     'center',
            gap:            10,
            marginBottom:   8
          }}>
            <div style={{
              width:          44,
              height:         44,
              borderRadius:   14,
              background:     'linear-gradient(135deg,#22d3ee,#6366f1)',
              display:        'flex',
              alignItems:     'center',
              justifyContent: 'center',
              fontWeight:     700,
              color:          '#0f172a',
              fontSize:       20,
              boxShadow:      '0 0 20px rgba(34,211,238,0.4)'
            }}>
              S
            </div>
            <span style={{
              fontFamily: 'monospace',
              fontSize:   22,
              fontWeight: 700,
              color:      '#e0f7ff'
            }}>
              Scan<span style={{ color: '#22d3ee' }}>2</span>Quiz
            </span>
          </div>
          <p style={{
            color: 'rgba(186,230,253,0.45)', fontSize: 13, margin: 0
          }}>
            School Quiz Management System
          </p>
        </div>

        {/* Card */}
        <div style={{
          background:           'rgba(255,255,255,0.055)',
          backdropFilter:       'blur(24px)',
          WebkitBackdropFilter: 'blur(24px)',
          border:               '1px solid rgba(103,232,249,0.18)',
          borderRadius:         28,
          boxShadow:            '0 8px 48px rgba(0,0,0,0.4)',
          padding:              '36px 32px'
        }}>
          <h1 style={{
            color: '#e0f7ff', fontSize: 22,
            fontWeight: 600, margin: '0 0 4px'
          }}>
            Create Teacher Account
          </h1>
          <p style={{
            color: 'rgba(186,230,253,0.5)',
            fontSize: 13, margin: '0 0 24px'
          }}>
            Register to start creating and managing quizzes
          </p>

          {/* Error */}
          {error && (
            <div style={{
              marginBottom: 16,
              padding:      '12px 14px',
              background:   'rgba(248,113,113,0.1)',
              border:       '1px solid rgba(248,113,113,0.3)',
              borderRadius: 12,
              color:        '#f87171',
              fontSize:     13
            }}>
              ❌ {error}
            </div>
          )}

          {/* Success */}
          {success && (
            <div style={{
              marginBottom: 16,
              padding:      '16px',
              background:   'rgba(74,222,128,0.08)',
              border:       '1px solid rgba(74,222,128,0.3)',
              borderRadius: 14,
            }}>
              <p style={{
                color:      '#4ade80',
                fontSize:   15,
                fontWeight: 600,
                margin:     '0 0 8px'
              }}>
                ✅ Registration Submitted!
              </p>
              <p style={{
                color:    'rgba(186,230,253,0.6)',
                fontSize: 13,
                margin:   0,
                lineHeight: 1.6
              }}>
                Your account is <strong style={{ color: '#fbbf24' }}>
                pending admin approval</strong>. An administrator
                will review your account shortly.
                You will be redirected to login in a moment.
              </p>
            </div>
          )}

          <form onSubmit={handleRegister}>
            <div style={{
              display: 'flex', flexDirection: 'column', gap: 16
            }}>
              {/* Full Name */}
              <div>
                <label style={labelStyle}>Full Name</label>
                <input
                  style={inputStyle}
                  type="text"
                  required
                  placeholder="e.g. Ms. Santos"
                  value={form.name}
                  onChange={e => setForm({
                    ...form, name: e.target.value
                  })}
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
              </div>

              {/* Email */}
              <div>
                <label style={labelStyle}>School Email</label>
                <input
                  style={inputStyle}
                  type="email"
                  required
                  placeholder="e.g. santos@school.edu"
                  value={form.email}
                  onChange={e => setForm({
                    ...form, email: e.target.value
                  })}
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
              </div>

              {/* Password */}
              <div>
                <label style={labelStyle}>Password</label>
                <input
                  style={inputStyle}
                  type="password"
                  required
                  placeholder="Minimum 6 characters"
                  value={form.password}
                  onChange={e => setForm({
                    ...form, password: e.target.value
                  })}
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
              </div>

              {/* Confirm Password */}
              <div>
                <label style={labelStyle}>Confirm Password</label>
                <input
                  style={inputStyle}
                  type="password"
                  required
                  placeholder="Re-enter your password"
                  value={form.confirm}
                  onChange={e => setForm({
                    ...form, confirm: e.target.value
                  })}
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
                {/* Password match indicator */}
                {form.confirm && (
                  <p style={{
                    fontSize: 11, margin: '4px 0 0',
                    color: form.password === form.confirm
                      ? '#4ade80' : '#f87171'
                  }}>
                    {form.password === form.confirm
                      ? '✓ Passwords match'
                      : '✗ Passwords do not match'}
                  </p>
                )}
              </div>

              {/* Password strength */}
              {form.password && (
                <div>
                  <div style={{
                    height:       4,
                    borderRadius: 2,
                    background:   'rgba(255,255,255,0.1)',
                    marginBottom: 4
                  }}>
                    <div style={{
                      height:     '100%',
                      borderRadius: 2,
                      transition: 'width 0.3s, background 0.3s',
                      width: form.password.length < 6
                        ? '25%'
                        : form.password.length < 10
                        ? '60%'
                        : '100%',
                      background: form.password.length < 6
                        ? '#f87171'
                        : form.password.length < 10
                        ? '#fbbf24'
                        : '#4ade80'
                    }}/>
                  </div>
                  <p style={{
                    fontSize: 11,
                    color:    form.password.length < 6
                      ? '#f87171'
                      : form.password.length < 10
                      ? '#fbbf24'
                      : '#4ade80',
                    margin: 0
                  }}>
                    {form.password.length < 6
                      ? 'Weak password'
                      : form.password.length < 10
                      ? 'Good password'
                      : 'Strong password'}
                  </p>
                </div>
              )}

              {/* Submit */}
              <button
                type="submit"
                disabled={loading}
                style={{
                  padding:      '14px',
                  background:   'linear-gradient(135deg,' +
                    'rgba(34,211,238,0.2),rgba(99,102,241,0.2))',
                  border:       '1px solid rgba(34,211,238,0.45)',
                  borderRadius: 14,
                  color:        '#22d3ee',
                  fontSize:     15,
                  fontWeight:   600,
                  cursor:       loading ? 'default' : 'pointer',
                  fontFamily:   'inherit',
                  marginTop:    4
                }}>
                {loading
                  ? 'Creating account...'
                  : 'Create Account →'}
              </button>
            </div>
          </form>

          {/* Link to login */}
          <p style={{
            textAlign: 'center',
            color:     'rgba(186,230,253,0.4)',
            fontSize:  13,
            margin:    '20px 0 0'
          }}>
            Already have an account?{' '}
            <Link to="/login" style={{
              color:          '#22d3ee',
              textDecoration: 'none',
              fontWeight:     500
            }}>
              Sign in here
            </Link>
          </p>
        </div>

        {/* Note */}
        <p style={{
          textAlign: 'center',
          color:     'rgba(186,230,253,0.25)',
          fontSize:  11,
          marginTop: 16
        }}>
          Teacher accounts only · Students log in via barcode scan
        </p>
      </div>
    </div>
  )
}