import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import api from '../services/api'

export default function LoginPage() {
  const [email,    setEmail]    = useState('')
  const [password, setPassword] = useState('')
  const [error,    setError]    = useState('')
  const [loading,  setLoading]  = useState(false)
  const { login } = useAuth()
  const navigate  = useNavigate()

  const handleLogin = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const res = await api.post('/auth/login', { email, password })
      login(res.data.token)
      navigate('/dashboard')
    } catch (err) {
      setError(err.response?.data?.message || 'Login failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center"
      style={{ background:
        'linear-gradient(135deg, #060d1f 0%, #0a1628 50%, #0d1f3c 100%)'
      }}>

      {/* Ambient glow blobs */}
      <div className="absolute top-20 left-40 w-96 h-96 rounded-full"
        style={{ background:
          'radial-gradient(circle, rgba(34,211,238,0.1) 0%, transparent 70%)'
        }}/>
      <div className="absolute bottom-20 right-40 w-80 h-80 rounded-full"
        style={{ background:
          'radial-gradient(circle, rgba(99,102,241,0.1) 0%, transparent 70%)'
        }}/>

      {/* Login card */}
      <div className="relative w-full max-w-md mx-4 p-10 rounded-3xl"
        style={{
          background:       'rgba(255,255,255,0.06)',
          backdropFilter:   'blur(24px)',
          border:           '1px solid rgba(103,232,249,0.2)',
          boxShadow:        '0 8px 48px rgba(0,0,0,0.4)'
        }}>

        {/* Logo */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center gap-3 mb-2">
            <div className="w-10 h-10 rounded-xl flex items-center
              justify-center text-white font-bold text-lg"
              style={{ background:
                'linear-gradient(135deg, #22d3ee, #6366f1)',
                boxShadow: '0 0 20px rgba(34,211,238,0.4)'
              }}>
              S
            </div>
            <span className="text-2xl font-bold text-sky-100"
              style={{ fontFamily: 'monospace' }}>
              Scan<span style={{ color: '#22d3ee' }}>2</span>Quiz
            </span>
          </div>
          <p style={{ color: 'rgba(186,230,253,0.5)', fontSize: 13 }}>
            Quiz Management System
          </p>
        </div>

        {/* Heading */}
        <h1 className="text-xl font-semibold text-sky-100 mb-1">
          Welcome back
        </h1>
        <p className="mb-6"
          style={{ color: 'rgba(186,230,253,0.5)', fontSize: 13 }}>
          Sign in to access your dashboard
        </p>

        {/* Error message */}
        {error && (
          <div className="mb-4 p-3 rounded-xl text-sm"
            style={{
              background: 'rgba(248,113,113,0.1)',
              border:     '1px solid rgba(248,113,113,0.3)',
              color:      '#f87171'
            }}>
            {error}
          </div>
        )}

        {/* Form */}
        <form onSubmit={handleLogin} className="space-y-4">
          {/* Email */}
          <div>
            <label className="block text-sm mb-1"
              style={{ color: 'rgba(186,230,253,0.6)' }}>
              Email
            </label>
            <input
              type="email"
              value={email}
              onChange={e => setEmail(e.target.value)}
              required
              className="w-full px-4 py-3 rounded-xl text-sky-100
                placeholder-sky-200/30 outline-none transition-all"
              style={{
                background:   'rgba(255,255,255,0.06)',
                border:       '1px solid rgba(103,232,249,0.25)',
                fontSize:     14
              }}
              onFocus={e => {
                e.target.style.borderColor = 'rgba(34,211,238,0.7)'
                e.target.style.boxShadow   =
                  '0 0 0 3px rgba(34,211,238,0.1)'
              }}
              onBlur={e => {
                e.target.style.borderColor = 'rgba(103,232,249,0.25)'
                e.target.style.boxShadow   = 'none'
              }}
            />
          </div>

          {/* Password */}
          <div>
            <label className="block text-sm mb-1"
              style={{ color: 'rgba(186,230,253,0.6)' }}>
              Password
            </label>
            <input
              type="password"
              value={password}
              onChange={e => setPassword(e.target.value)}
              required
              className="w-full px-4 py-3 rounded-xl text-sky-100
                placeholder-sky-200/30 outline-none transition-all"
              style={{
                background: 'rgba(255,255,255,0.06)',
                border:     '1px solid rgba(103,232,249,0.25)',
                fontSize:   14
              }}
              onFocus={e => {
                e.target.style.borderColor = 'rgba(34,211,238,0.7)'
                e.target.style.boxShadow   =
                  '0 0 0 3px rgba(34,211,238,0.1)'
              }}
              onBlur={e => {
                e.target.style.borderColor = 'rgba(103,232,249,0.25)'
                e.target.style.boxShadow   = 'none'
              }}
            />
          </div>

          {/* Submit button */}
          <button
            type="submit"
            disabled={loading}
            className="w-full py-3 rounded-xl font-semibold
              transition-all duration-200 mt-2"
            style={{
              background: 'linear-gradient(135deg,' +
                'rgba(34,211,238,0.2),rgba(99,102,241,0.2))',
              border:    '1px solid rgba(34,211,238,0.45)',
              color:     '#22d3ee',
              fontSize:  15
            }}
          >
            {loading ? 'Signing in...' : 'Sign In →'}
          </button>
        </form>
      </div>
    </div>
  )
}