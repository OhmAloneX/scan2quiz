import { useState, useEffect } from 'react'
import Sidebar from '../components/layout/Sidebar'
import GlassCard from '../components/ui/GlassCard'
import api       from '../services/api'
import { useAuth } from '../context/AuthContext'
import { useNavigate } from 'react-router-dom'

export default function AdminPage() {
  const { user }                    = useAuth()
  const navigate                    = useNavigate()
  const [users,     setUsers]       = useState([])
  const [loading,   setLoading]     = useState(true)
  const [filter,    setFilter]      = useState('all')
  const [acting,    setActing]      = useState(null)
  const [message,   setMessage]     = useState(null)

  // Redirect non-admins
  useEffect(() => {
    if (user && user.role !== 'admin') {
      navigate('/dashboard')
    }
  }, [user, navigate])

  useEffect(() => { loadUsers() }, [])

  async function loadUsers() {
    try {
      const res = await api.get('/auth/users')
      setUsers(res.data.data)
    } catch (err) {
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  function showMessage(text, type = 'success') {
    setMessage({ text, type })
    setTimeout(() => setMessage(null), 3000)
  }

  async function handleApprove(id, name) {
    setActing(id)
    try {
      await api.patch(`/auth/users/${id}/approve`)
      showMessage(`${name} has been approved`)
      loadUsers()
    } catch (err) {
      showMessage(
        err.response?.data?.message || 'Failed to approve',
        'error'
      )
    } finally {
      setActing(null)
    }
  }

  async function handleReject(id, name) {
    if (!window.confirm(
      `Reject ${name}'s account? They will not be able to log in.`
    )) return
    setActing(id)
    try {
      await api.patch(`/auth/users/${id}/reject`)
      showMessage(`${name} has been rejected`, 'error')
      loadUsers()
    } catch (err) {
      showMessage(
        err.response?.data?.message || 'Failed to reject',
        'error'
      )
    } finally {
      setActing(null)
    }
  }

  async function handleDelete(id, name) {
    if (!window.confirm(
      `Delete ${name}'s account permanently? This cannot be undone.`
    )) return
    setActing(id)
    try {
      await api.delete(`/auth/users/${id}`)
      showMessage(`${name}'s account deleted`)
      loadUsers()
    } catch (err) {
      showMessage(
        err.response?.data?.message || 'Failed to delete',
        'error'
      )
    } finally {
      setActing(null)
    }
  }

  const filtered = users.filter(u => {
    if (filter === 'all')     return true
    if (filter === 'pending') return u.status === 'pending'
    if (filter === 'active')  return u.status === 'active'
    if (filter === 'rejected')return u.status === 'rejected'
    return true
  })

  const pendingCount = users.filter(u => u.status === 'pending').length

  const statusStyle = (status) => {
    if (status === 'active')   return {
      background: 'rgba(74,222,128,0.15)',
      border:     '1px solid rgba(74,222,128,0.3)',
      color:      '#4ade80'
    }
    if (status === 'pending')  return {
      background: 'rgba(251,191,36,0.15)',
      border:     '1px solid rgba(251,191,36,0.3)',
      color:      '#fbbf24'
    }
    if (status === 'rejected') return {
      background: 'rgba(248,113,113,0.15)',
      border:     '1px solid rgba(248,113,113,0.3)',
      color:      '#f87171'
    }
    return {}
  }

  return (
    <div style={{
      display:    'flex',
      minHeight:  '100vh',
      background: 'linear-gradient(135deg,#060d1f 0%,#0a1628 50%,#0d1f3c 100%)',
      fontFamily: "'Segoe UI', system-ui, sans-serif"
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
              color:      '#e0f7ff',
              fontSize:   20,
              fontWeight: 600,
              margin:     0
            }}>
              Admin Panel 
            </h1>

            <p style={{
              color:    'rgba(186,230,253,0.5)',
              fontSize: 13,
              margin:   '2px 0 0'
            }}>
              Manage teacher accounts and approvals
            </p>
          </div>

          <div style={{
            background:   'rgba(255,255,255,0.06)',
            border:       '1px solid rgba(103,232,249,0.2)',
            borderRadius: 10,
            padding:      '6px 14px',
            color:        'rgba(186,230,253,0.6)',
            fontSize:     12
          }}>
            {new Date().toLocaleDateString('en-US', {
              weekday: 'long',
              year:    'numeric',
              month:   'long',
              day:     'numeric'
            })}
          </div>
        </div>

        {/* Body */}
        <div style={{ padding: '24px 28px' }}>
      <div style={{ padding: 'clamp(16px,3vw,28px)' }}>

        {/* Message banner */}
        {message && (
          <div style={{
            padding:      '12px 16px',
            marginBottom: 20,
            background:   message.type === 'error'
              ? 'rgba(248,113,113,0.1)'
              : 'rgba(74,222,128,0.1)',
            border: `1px solid ${message.type === 'error'
              ? 'rgba(248,113,113,0.3)'
              : 'rgba(74,222,128,0.3)'}`,
            borderRadius: 12,
            color:        message.type === 'error'
              ? '#f87171' : '#4ade80',
            fontSize:     14,
            fontWeight:   500
          }}>
            {message.text}
          </div>
        )}

        {/* Stats row */}
        <div style={{
          display:             'grid',
          gridTemplateColumns: 'repeat(auto-fit,minmax(150px,1fr))',
          gap:                 16,
          marginBottom:        24
        }}>
          {[
            {
              label: 'Total Users',
              value: users.length,
              color: '#22d3ee',
              
            },
            {
              label: 'Pending',
              value: users.filter(u => u.status === 'pending').length,
              color: '#fbbf24',
              
            },
            {
              label: 'Active',
              value: users.filter(u => u.status === 'active').length,
              color: '#4ade80',
              
            },
            {
              label: 'Rejected',
              value: users.filter(u => u.status === 'rejected').length,
              color: '#f87171',
              
            }
          ].map(stat => (
            <GlassCard key={stat.label} style={{ padding: 18 }}>
              <div style={{
                display:        'flex',
                justifyContent: 'space-between',
                marginBottom:   8
              }}>
                <span style={{
                  fontSize:      11,
                  color:         'rgba(186,230,253,0.5)',
                  textTransform: 'uppercase',
                  letterSpacing: '0.8px'
                }}>
                  {stat.label}
                </span>
                <span style={{ fontSize: 18 }}>{stat.icon}</span>
              </div>
              <p style={{
                fontSize:   28,
                fontWeight: 700,
                color:      stat.color,
                margin:     0
              }}>
                {stat.value}
              </p>
            </GlassCard>
          ))}
        </div>

        {/* Pending alert */}
        {pendingCount > 0 && (
          <div style={{
            padding:      '14px 18px',
            marginBottom: 20,
            background:   'rgba(251,191,36,0.08)',
            border:       '1px solid rgba(251,191,36,0.3)',
            borderRadius: 14,
            display:      'flex',
            alignItems:   'center',
            gap:          12
          }}>
            <span style={{ fontSize: 24 }}>⏳</span>
            <div>
              <p style={{
                color:      '#fbbf24',
                fontSize:   14,
                fontWeight: 600,
                margin:     '0 0 2px'
              }}>
                {pendingCount} account{pendingCount > 1 ? 's' : ''}
                {' '}awaiting your approval
              </p>
              <p style={{
                color:    'rgba(186,230,253,0.5)',
                fontSize: 12,
                margin:   0
              }}>
                Review and approve or reject teacher
                registration requests below
              </p>
            </div>
            <button
              onClick={() => setFilter('pending')}
              style={{
                marginLeft:   'auto',
                padding:      '7px 16px',
                background:   'rgba(251,191,36,0.15)',
                border:       '1px solid rgba(251,191,36,0.4)',
                borderRadius: 10,
                color:        '#fbbf24',
                fontSize:     12,
                fontWeight:   600,
                cursor:       'pointer',
                fontFamily:   'inherit',
                flexShrink:   0
              }}>
              View Pending
            </button>
          </div>
        )}

        {/* Filter tabs */}
        <div style={{
          display:      'flex',
          gap:          8,
          marginBottom: 20,
          flexWrap:     'wrap'
        }}>
          {[
            { key: 'all',      label: 'All Users' },
            { key: 'pending',  label: `Pending (${pendingCount})` },
            { key: 'active',   label: 'Active' },
            { key: 'rejected', label: 'Rejected' },
          ].map(tab => (
            <button
              key={tab.key}
              onClick={() => setFilter(tab.key)}
              style={{
                padding:      '7px 16px',
                borderRadius: 10,
                border:       `1px solid ${filter === tab.key
                  ? 'rgba(34,211,238,0.5)'
                  : 'rgba(103,232,249,0.15)'}`,
                background:   filter === tab.key
                  ? 'rgba(34,211,238,0.12)'
                  : 'transparent',
                color:        filter === tab.key
                  ? '#22d3ee'
                  : 'rgba(186,230,253,0.6)',
                fontSize:     13,
                fontWeight:   filter === tab.key ? 600 : 400,
                cursor:       'pointer',
                fontFamily:   'inherit',
                transition:   'all 0.2s'
              }}>
              {tab.label}
            </button>
          ))}
        </div>

        {/* Users table */}
        {loading ? (
          <div style={{
            display:        'flex',
            alignItems:     'center',
            justifyContent: 'center',
            height:         300
          }}>
            <p style={{ color: 'rgba(186,230,253,0.5)' }}>
              Loading users...
            </p>
          </div>
        ) : filtered.length === 0 ? (
          <GlassCard style={{ textAlign: 'center', padding: 48 }}>
            <p style={{ fontSize: 40, marginBottom: 12 }}>👥</p>
            <p style={{
              color: '#e0f7ff', fontSize: 16,
              fontWeight: 600, margin: '0 0 8px'
            }}>
              No users found
            </p>
            <p style={{
              color: 'rgba(186,230,253,0.4)', fontSize: 13
            }}>
              No accounts match the selected filter
            </p>
          </GlassCard>
        ) : (
          <GlassCard>
            <div style={{
              display:        'flex',
              justifyContent: 'space-between',
              alignItems:     'center',
              marginBottom:   18
            }}>
              <h2 style={{
                color: '#e0f7ff', fontSize: 16,
                fontWeight: 600, margin: 0
              }}>
                Teacher Accounts
              </h2>
              <span style={{
                fontSize: 12,
                color:    'rgba(186,230,253,0.4)'
              }}>
                {filtered.length} user{filtered.length !== 1 ? 's' : ''}
              </span>
            </div>

            <div style={{ overflowX: 'auto' }}>
              <table style={{
                width:           '100%',
                borderCollapse:  'collapse',
                minWidth:        600
              }}>
                <thead>
                  <tr>
                    {['Name', 'Email', 'Role',
                      'Status', 'Registered', 'Actions'].map(h => (
                      <th key={h} style={{
                        textAlign:     'left',
                        padding:       '8px 12px',
                        fontSize:      11,
                        color:         'rgba(186,230,253,0.45)',
                        fontWeight:    500,
                        textTransform: 'uppercase',
                        letterSpacing: '0.7px',
                        borderBottom:
                          '1px solid rgba(103,232,249,0.1)'
                      }}>
                        {h}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {filtered.map((u, i) => {
                    const ss = statusStyle(u.status)
                    const isMe = u.email === user?.email
                    return (
                      <tr key={u.id} style={{
                        borderBottom: i < filtered.length - 1
                          ? '1px solid rgba(103,232,249,0.06)'
                          : 'none',
                        background: u.status === 'pending'
                          ? 'rgba(251,191,36,0.03)'
                          : 'transparent'
                      }}>
                        {/* Name */}
                        <td style={{ padding: '14px 12px' }}>
                          <div style={{
                            display:    'flex',
                            alignItems: 'center',
                            gap:        10
                          }}>
                            <div style={{
                              width:          32,
                              height:         32,
                              borderRadius:   '50%',
                              background:     u.status === 'pending'
                                ? 'linear-gradient(135deg,#fbbf24,#f59e0b)'
                                : 'linear-gradient(135deg,#22d3ee,#6366f1)',
                              display:        'flex',
                              alignItems:     'center',
                              justifyContent: 'center',
                              fontSize:       13,
                              fontWeight:     700,
                              color:          '#0f172a',
                              flexShrink:     0
                            }}>
                              {u.name.charAt(0).toUpperCase()}
                            </div>
                            <div>
                              <p style={{
                                color:      '#e0f7ff',
                                fontSize:   13,
                                fontWeight: 500,
                                margin:     0
                              }}>
                                {u.name}
                                {isMe && (
                                  <span style={{
                                    fontSize:     10,
                                    color:        '#22d3ee',
                                    marginLeft:   6,
                                    background:   'rgba(34,211,238,0.1)',
                                    border:       '1px solid rgba(34,211,238,0.3)',
                                    borderRadius: 4,
                                    padding:      '1px 5px'
                                  }}>
                                    You
                                  </span>
                                )}
                              </p>
                            </div>
                          </div>
                        </td>

                        {/* Email */}
                        <td style={{
                          padding:  '14px 12px',
                          color:    'rgba(186,230,253,0.6)',
                          fontSize: 13
                        }}>
                          {u.email}
                        </td>

                        {/* Role */}
                        <td style={{ padding: '14px 12px' }}>
                          <span style={{
                            fontSize:     11,
                            fontWeight:   600,
                            padding:      '3px 10px',
                            borderRadius: 20,
                            background:   u.role === 'admin'
                              ? 'rgba(99,102,241,0.15)'
                              : 'rgba(34,211,238,0.1)',
                            border: u.role === 'admin'
                              ? '1px solid rgba(99,102,241,0.3)'
                              : '1px solid rgba(34,211,238,0.2)',
                            color: u.role === 'admin'
                              ? '#a5b4fc' : '#22d3ee'
                          }}>
                            {u.role}
                          </span>
                        </td>

                        {/* Status */}
                        <td style={{ padding: '14px 12px' }}>
                          <span style={{
                            fontSize:     11,
                            fontWeight:   600,
                            padding:      '3px 10px',
                            borderRadius: 20,
                            ...ss
                          }}>
                            {u.status === 'pending'  ? 'Pending'  : ''}
                            {u.status === 'active'   ? 'Active'   : ''}
                            {u.status === 'rejected' ? 'Rejected' : ''}
                          </span>
                        </td>

                        {/* Registered */}
                        <td style={{
                          padding:  '14px 12px',
                          color:    'rgba(186,230,253,0.5)',
                          fontSize: 12
                        }}>
                          {new Date(u.created_at)
                            .toLocaleDateString('en-US', {
                              month: 'short',
                              day:   'numeric',
                              year:  'numeric'
                            })}
                        </td>

                        {/* Actions */}
                        <td style={{ padding: '14px 12px' }}>
                          <div style={{
                            display:  'flex',
                            gap:      6,
                            flexWrap: 'wrap'
                          }}>
                            {/* Approve button — pending only */}
                            {u.status === 'pending' && (
                              <button
                                onClick={() =>
                                  handleApprove(u.id, u.name)}
                                disabled={acting === u.id}
                                style={{
                                  padding:      '5px 12px',
                                  background:   'rgba(74,222,128,0.15)',
                                  border:       '1px solid rgba(74,222,128,0.4)',
                                  borderRadius: 8,
                                  color:        '#4ade80',
                                  fontSize:     11,
                                  fontWeight:   600,
                                  cursor:       'pointer',
                                  fontFamily:   'inherit'
                                }}>
                                {acting === u.id
                                  ? '...' : 'Approve'}
                              </button>
                            )}

                            {/* Reject button — pending only */}
                            {u.status === 'pending' && (
                              <button
                                onClick={() =>
                                  handleReject(u.id, u.name)}
                                disabled={acting === u.id}
                                style={{
                                  padding:      '5px 12px',
                                  background:   'rgba(248,113,113,0.1)',
                                  border:       '1px solid rgba(248,113,113,0.3)',
                                  borderRadius: 8,
                                  color:        '#f87171',
                                  fontSize:     11,
                                  fontWeight:   600,
                                  cursor:       'pointer',
                                  fontFamily:   'inherit'
                                }}>
                                {acting === u.id
                                  ? '...' : 'Reject'}
                              </button>
                            )}

                            {/* Delete button — not self, not pending */}
                            {!isMe && u.status !== 'pending' && (
                              <button
                                onClick={() =>
                                  handleDelete(u.id, u.name)}
                                disabled={acting === u.id}
                                style={{
                                  padding:      '5px 12px',
                                  background:   'rgba(248,113,113,0.07)',
                                  border:       '1px solid rgba(248,113,113,0.2)',
                                  borderRadius: 8,
                                  color:        '#f87171',
                                  fontSize:     11,
                                  cursor:       'pointer',
                                  fontFamily:   'inherit'
                                }}>
                                {acting === u.id ? '...' : '🗑'}
                              </button>
                            )}

                            {/* No actions for self */}
                            {isMe && (
                              <span style={{
                                color:    'rgba(186,230,253,0.3)',
                                fontSize: 11
                              }}>
                                —
                              </span>
                            )}
                          </div>
                        </td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            </div>
          </GlassCard>
        )}
      </div>
      </div>
    </div>
  </div>
  )
}