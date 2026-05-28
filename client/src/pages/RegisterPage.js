import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { useValidation, rules } from '../hooks/useValidation'
import FormInput from '../components/ui/FormInput'
import api       from '../services/api'

export default function RegisterPage() {
  const navigate        = useNavigate()
  const [form, setForm] = useState({
    name: '', email: '', password: '', confirm: ''
  })
  const [serverError, setServerError] = useState('')
  const [success,     setSuccess]     = useState('')
  const [loading,     setLoading]     = useState(false)

  // Dynamic schema so confirm can reference password value
  const schema = {
    name:     [
      rules.required('Full name'),
      rules.minLength(2, 'Full name'),
      rules.maxLength(100, 'Full name')
    ],
    email:    [
      rules.required('Email'),
      rules.email()
    ],
    password: [
      rules.required('Password'),
      rules.password()
    ],
    confirm:  [
      rules.required('Confirm password'),
      rules.match(form.password, 'Passwords')
    ]
  }

  const {
    getError, isValid, handleBlur,
    handleChange, validateAll
  } = useValidation(schema)

  function update(field, value) {
    setForm(prev => ({ ...prev, [field]: value }))
    handleChange(field, value)
    setServerError('')
  }

  async function handleRegister(e) {
    e.preventDefault()
    setServerError('')
    if (!validateAll(form)) return
    setLoading(true)
    try {
      await api.post('/auth/register', {
        name:     form.name,
        email:    form.email,
        password: form.password,
        role:     'teacher'
      })
      setSuccess(true)
      setTimeout(() => navigate('/login'), 4000)
    } catch (err) {
      setServerError(
        err.response?.data?.message || 'Registration failed'
      )
    } finally {
      setLoading(false)
    }
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
      padding:        '24px 20px'
    }}>
      {/* Ambient blobs */}
      <div style={{
        position: 'fixed', top: '10%', left: '15%',
        width: 400, height: 400, borderRadius: '50%',
        background: 'radial-gradient(circle,' +
          'rgba(34,211,238,0.08) 0%,transparent 70%)',
        pointerEvents: 'none'
      }}/>
      <div style={{
        position: 'fixed', bottom: '10%', right: '10%',
        width: 360, height: 360, borderRadius: '50%',
        background: 'radial-gradient(circle,' +
          'rgba(99,102,241,0.09) 0%,transparent 70%)',
        pointerEvents: 'none'
      }}/>

      <div style={{ width: '100%', maxWidth: 460 }}>
        {/* Logo */}
        <div style={{ textAlign: 'center', marginBottom: 24 }}>
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
            color: 'rgba(186,230,253,0.45)',
            fontSize: 13, margin: 0
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

          {success ? (
            /* Success state */
            <div style={{ textAlign: 'center', padding: '16px 0' }}>
              <div style={{
                width:          72,
                height:         72,
                borderRadius:   '50%',
                background:     'rgba(74,222,128,0.1)',
                border:         '2px solid rgba(74,222,128,0.4)',
                display:        'flex',
                alignItems:     'center',
                justifyContent: 'center',
                margin:         '0 auto 20px',
                fontSize:       32
              }}>
                
              </div>
              <h2 style={{
                color: '#4ade80', fontSize: 20,
                fontWeight: 600, margin: '0 0 8px'
              }}>
                Registration Submitted!
              </h2>
              <p style={{
                color:      '#e0f7ff',
                fontSize:   14,
                fontWeight: 500,
                margin:     '0 0 8px'
              }}>
                Your account is pending admin approval
              </p>
              <p style={{
                color:    'rgba(186,230,253,0.5)',
                fontSize: 13,
                margin:   '0 0 20px',
                lineHeight: 1.6
              }}>
                An administrator will review your account shortly.
                You will be redirected to the login page in a moment.
              </p>
              <div style={{
                height:       4,
                borderRadius: 2,
                background:   'rgba(255,255,255,0.08)',
                overflow:     'hidden'
              }}>
                <div style={{
                  height:     '100%',
                  background: 'linear-gradient(90deg,#22d3ee,#6366f1)',
                  borderRadius: 2,
                  animation:  'shrink 4s linear forwards'
                }}/>
              </div>
              <style>{`
                @keyframes shrink {
                  from { width: 100% }
                  to   { width: 0%   }
                }
              `}</style>
            </div>
          ) : (
            <>
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

              {/* Server error */}
              {serverError && (
                <div style={{
                  marginBottom: 20,
                  padding:      '12px 14px',
                  background:   'rgba(248,113,113,0.1)',
                  border:       '1px solid rgba(248,113,113,0.3)',
                  borderRadius: 12,
                  display:      'flex',
                  alignItems:   'center',
                  gap:          8
                }}>
                  <span style={{ fontSize: 16 }}>⚠️</span>
                  <span style={{ color: '#f87171', fontSize: 13 }}>
                    {serverError}
                  </span>
                </div>
              )}

              <form onSubmit={handleRegister} noValidate>
                <div style={{
                  display:       'flex',
                  flexDirection: 'column',
                  gap:           18
                }}>
                  <FormInput
                    label="Full Name"
                    name="name"
                    required
                    value={form.name}
                    error={getError('name')}
                    isValid={isValid('name')}
                    autoComplete="name"
                    onChange={v => update('name', v)}
                    onBlur={v => handleBlur('name', v)}
                    hint="Your display name shown to students"
                  />

                  <FormInput
                    label="School Email"
                    name="email"
                    type="email"
                    required
                    value={form.email}
                    error={getError('email')}
                    isValid={isValid('email')}
                    autoComplete="email"
                    onChange={v => update('email', v)}
                    onBlur={v => handleBlur('email', v)}
                  />

                  <FormInput
                    label="Password"
                    name="password"
                    type="password"
                    required
                    value={form.password}
                    error={getError('password')}
                    isValid={isValid('password')}
                    autoComplete="new-password"
                    showStrength
                    onChange={v => update('password', v)}
                    onBlur={v => handleBlur('password', v)}
                  />

                  <FormInput
                    label="Confirm Password"
                    name="confirm"
                    type="password"
                    required
                    value={form.confirm}
                    error={getError('confirm')}
                    isValid={isValid('confirm')}
                    autoComplete="new-password"
                    onChange={v => update('confirm', v)}
                    onBlur={v => handleBlur('confirm', v)}
                  />

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

              <p style={{
                textAlign: 'center',
                color:     'rgba(186,230,253,0.4)',
                fontSize:  13,
                margin:    '20px 0 0'
              }}>
                Already have an account?{' '}
                <Link to="/login" style={{
                  color: '#22d3ee', textDecoration: 'none',
                  fontWeight: 500
                }}>
                  Sign in here
                </Link>
              </p>
            </>
          )}
        </div>

        <p style={{
          textAlign: 'center',
          color:     'rgba(186,230,253,0.2)',
          fontSize:  11,
          marginTop: 16
        }}>
          Teacher accounts only · Students log in via barcode scan
        </p>
      </div>
    </div>
  )
}