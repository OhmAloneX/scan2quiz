import { useEffect, useRef, useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { useAuth }       from '../context/AuthContext'
import { useValidation, rules } from '../hooks/useValidation'
import FormInput         from '../components/ui/FormInput'
import api               from '../services/api'


// Validation schema for login
const schema = {
  email:    [rules.required('Email'), rules.email()],
  password: [rules.required('Password'), rules.passwordSimple()]
}

export default function LoginPage() {
  const navigate        = useNavigate()
  const { login }       = useAuth()
  const [form, setForm] = useState({ email: '', password: '' })

  // Ensure the browser password manager/autofill does not repopulate these fields.
  // These attributes are only applied on the actual inputs (not the hidden decoys).

  const emailRef = useRef(null)
  const passwordRef = useRef(null)

  const [serverError, setServerError] = useState('')
  const [loading, setLoading]         = useState(false)

  const {
    getError, isValid, handleBlur,
    handleChange, validateAll
  } = useValidation(schema)

  function update(field, value) {
    setForm(prev => ({ ...prev, [field]: value }))
    handleChange(field, value)
    setServerError('')
  }

  useEffect(() => {
    // Force empty fields on mount (defeats Chrome/Edge re-applying saved credentials)
    setForm({ email: '', password: '' })

    // Also clear DOM input values defensively (some Chrome builds briefly render autofill values
    // before React's controlled updates settle).
    const emailEl = emailRef.current
    const passEl = passwordRef.current
    if (!emailEl || !passEl) return

    const t2 = window.setTimeout(() => {
      // Clear React state
      setForm({ email: '', password: '' })

      // Clear DOM values
      emailEl.value = ''
      passEl.value = ''

      // Remove focus (Chrome autofill is frequently tied to focus/first paint)
      emailEl.blur()
      passEl.blur()
    }, 0)

    return () => {
      window.clearTimeout(t2)
    }
  }, [])


  async function handleLogin(e) {
    e.preventDefault()
    setServerError('')
    if (!validateAll(form)) return
    setLoading(true)
    try {
      const res = await api.post('/auth/login', {
        email:    form.email,
        password: form.password
      })
      login(res.data.token)
      navigate('/dashboard')
    } catch (err) {
      setServerError(
        err.response?.data?.message || 'Login failed'
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
      padding:        20
    }}>
      {/* Ambient blobs */}
      <div style={{
        position:   'fixed', top: '10%', left: '15%',
        width: 400, height: 400, borderRadius: '50%',
        background: 'radial-gradient(circle,' +
          'rgba(34,211,238,0.08) 0%,transparent 70%)',
        pointerEvents: 'none'
      }}/>
      <div style={{
        position:   'fixed', bottom: '10%', right: '10%',
        width: 360, height: 360, borderRadius: '50%',
        background: 'radial-gradient(circle,' +
          'rgba(99,102,241,0.09) 0%,transparent 70%)',
        pointerEvents: 'none'
      }}/>

      <div style={{ width: '100%', maxWidth: 440 }}>
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
            color:   'rgba(186,230,253,0.45)',
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
          <h1 style={{
            color: '#e0f7ff', fontSize: 22,
            fontWeight: 600, margin: '0 0 4px'
          }}>
            Welcome back
          </h1>
          <p style={{
            color: 'rgba(186,230,253,0.5)',
            fontSize: 13, margin: '0 0 24px'
          }}>
            Sign in to access your dashboard
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

          <form
            onSubmit={handleLogin}
            noValidate
            autoComplete="off"
            method="post"
            action="/"
            autoCorrect="off"
            spellCheck={false}
          >

            {/* Autofill/credential-matching resistance (Chrome/Edge) */}
            {/* Hidden fields: reduce credential autofill matches in Chrome/Edge */}
            <div style={{ display: 'none' }} aria-hidden="true">
              <input
                type="text"
                name="fakeusernameremembered"
                tabIndex={-1}
                autoComplete="off"
                value=""
              />
              <input
                type="password"
                name="fakepasswordremembered"
                tabIndex={-1}
                autoComplete="new-password"
                value=""
              />
            </div>


            <div style={{
              display:       'flex',
              flexDirection: 'column',
              gap:           18
            }}>
              <FormInput
                label="Email Address"
                name="login_email"

                type="email"
                required
                value={form.email}
                error={getError('email')}
                isValid={isValid('email')}
                // Explicitly disable autofill/autocomplete heuristics for email.
                autoComplete="off"
                onChange={v => update('email', v)}

                onBlur={v => handleBlur('email', v)}
                inputRef={emailRef}
              />

              <FormInput
                label="Password"
                name="login_password"

                type="password"
                required
                value={form.password}
                error={getError('password')}
                isValid={isValid('password')}
                autoComplete="new-password"
                onChange={v => update('password', v)}

                onBlur={v => handleBlur('password', v)}
                inputRef={passwordRef}
              />

              {/* Forgot password link */}
              <div style={{ textAlign: 'right', marginTop: -10 }}>
                <span style={{
                  color:    '#22d3ee',
                  fontSize: 12,
                  cursor:   'pointer'
                }}>
                  Forgot password?
                </span>
              </div>

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
                {loading ? 'Signing in...' : 'Sign In →'}
              </button>
            </div>
          </form>

          <div style={{ textAlign: 'center', marginTop: 20 }}>
            <p style={{
              color:   'rgba(186,230,253,0.35)',
              fontSize: 11, margin: '0 0 8px'
            }}>
            </p>
            <p style={{
              color: 'rgba(186,230,253,0.4)',
              fontSize: 13, margin: 0
            }}>
              New teacher?{' '}
              <Link to="/register" style={{
                color: '#22d3ee', textDecoration: 'none',
                fontWeight: 500
              }}>
                Create an account
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}