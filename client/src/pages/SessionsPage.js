import { useState, useEffect } from 'react'
import useResponsive from '../hooks/useResponsive'

import Sidebar       from '../components/layout/Sidebar'
import GlassCard     from '../components/ui/GlassCard'
import Pagination    from '../components/ui/Pagination'
import { getSessions, closeSession, createSession } from '../services/sessionService'

import StudentScannerModal from '../components/teacher/StudentScannerModal'

import { fetchParticipants } from '../services/sessionService'


import { getQuizzes } from '../services/quizService'

export default function SessionsPage() {
  const [sessions,  setSessions]  = useState([])
  const [quizzes,   setQuizzes]   = useState([])
  const [loading,   setLoading]   = useState(true)
  const [qrModal,   setQrModal]   = useState(null)
  const [showForm,  setShowForm]  = useState(false)

  const [showScanner, setShowScanner] = useState(false)
  const [activeSessionId, setActiveSessionId] = useState(null)
  const [participants, setParticipants] = useState([])
  const [participantsLoading, setParticipantsLoading] = useState(false)
  const [participantsError, setParticipantsError] = useState('')

  const [selQuiz,   setSelQuiz]   = useState('')
  const [creating,  setCreating]  = useState(false)
  const [closing,   setClosing]   = useState(null)

  const responsive = useResponsive()

  useEffect(() => { loadData() }, [])

  async function loadData() {
    try {
      const [s, q] = await Promise.all([
        getSessions(),
        getQuizzes()
      ])
      setSessions(s.data.data)
      setQuizzes(q.data.data)
    } catch (err) {
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  async function handleCreate(e) {
    e.preventDefault()
    if (!selQuiz) return
    setCreating(true)
    try {
      const res = await createSession(+selQuiz)
      setQrModal(res.data.data)
      setShowForm(false)
      setSelQuiz('')
      loadData()
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to create session')
    } finally {
      setCreating(false)
    }
  }

  async function handleClose(id) {
    if (!window.confirm(
      'Close this session? Students can no longer join.'))
      return
    setClosing(id)
    try {
      await closeSession(id)
      loadData()
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to close session')
    } finally {
      setClosing(null)
    }
  }

  const [rowsPerPage, setRowsPerPage] = useState(10)
  const [currentPage, setCurrentPage] = useState(1)

  useEffect(() => {
    setCurrentPage(1)
  }, [rowsPerPage])

  const totalItems = sessions.length
  const totalPages = Math.max(1, Math.ceil(totalItems / rowsPerPage))

  const startIndex = (currentPage - 1) * rowsPerPage
  const endIndex = startIndex + rowsPerPage

  const paginatedSessions = sessions.slice(startIndex, endIndex)

  const statusColor = (status) => {

    if (status === 'open')   return {
      bg: 'rgba(74,222,128,0.15)',
      border: 'rgba(74,222,128,0.3)',
      color: '#4ade80'
    }
    if (status === 'closed') return {
      bg: 'rgba(248,113,113,0.15)',
      border: 'rgba(248,113,113,0.3)',
      color: '#f87171'
    }
    return {
      bg: 'rgba(165,180,252,0.15)',
      border: 'rgba(165,180,252,0.3)',
      color: '#a5b4fc'
    }
  }

  const btnStyle = {
    padding:      '10px 20px',
    background:   'linear-gradient(135deg,' +
      'rgba(34,211,238,0.2),rgba(99,102,241,0.2))',
    border:       '1px solid rgba(34,211,238,0.45)',
    borderRadius: 12,
    color:        '#22d3ee',
    fontSize:     14,
    fontWeight:   600,
    cursor:       'pointer',
    fontFamily:   'inherit'
  }

  return (
    <div style={{
      display:    'flex',
      minHeight:  '100vh',
      background: 'linear-gradient(135deg,' +
        '#060d1f 0%,#0a1628 50%,#0d1f3c 100%)',
      fontFamily: "'Segoe UI',system-ui,sans-serif"
    }}>
      <Sidebar />

      <div style={{ flex: 1, overflow: 'auto' }}>
        {/* Top bar */}
        <div style={{
          padding:        '16px 28px',
          background:     'rgba(255,255,255,0.03)',
          backdropFilter: 'blur(16px)',
          borderBottom:   '1px solid rgba(103,232,249,0.08)',
          display:        'flex',
          alignItems:     'center',
          justifyContent: 'space-between'
        }}>
          <div>
            <h1 style={{
              color: '#e0f7ff', fontSize: 20,
              fontWeight: 600, margin: 0
            }}>
              Sessions
            </h1>
            <p style={{
              color: 'rgba(186,230,253,0.5)',
              fontSize: 13, margin: '2px 0 0'
            }}>
              Manage your quiz sessions and QR codes
            </p>
          </div>
          <button
            onClick={() => setShowForm(f => !f)}
            style={btnStyle}>
            + New Session
          </button>
        </div>

        <div style={{
          padding: '16px 14px',
        }}>

          {/* Create Session Form */}
          {showForm && (
            <GlassCard glow style={{ marginBottom: 24 }}>
              <h2 style={{
                color: '#e0f7ff', fontSize: 16,
                fontWeight: 600, margin: '0 0 16px'
              }}>
                Start New Session
              </h2>
              <form onSubmit={handleCreate}>
                <div style={{ marginBottom: 16 }}>
                  <label style={{
                    display: 'block', fontSize: 12,
                    color: 'rgba(186,230,253,0.6)',
                    marginBottom: 6
                  }}>
                    Select Quiz
                  </label>
                  <select
                    value={selQuiz}
                    onChange={e => setSelQuiz(e.target.value)}
                    required
                    style={{
                      width:        '100%',
                      padding:      '10px 14px',
                      background:   'rgba(255,255,255,0.06)',
                      border:       '1px solid rgba(103,232,249,0.25)',
                      borderRadius: 10,
                      color:        '#e0f7ff',
                      fontSize:     13,
                      outline:      'none',
                      fontFamily:   'inherit'
                    }}>
                    <option value="">-- Choose a quiz --</option>
                    {quizzes.map(q => (
                      <option
                        key={q.id} value={q.id}
                        style={{ background: '#0a1628' }}>
                        {q.title}
                        {q.subject ? ` · ${q.subject}` : ''}
                      </option>
                    ))}
                  </select>
                </div>

                {/* Selected quiz info */}
                {selQuiz && (() => {
                  const q = quizzes.find(q => q.id === +selQuiz)
                  return q ? (
                    <div style={{
                      padding:      '10px 14px',
                      background:   'rgba(34,211,238,0.06)',
                      border:       '1px solid rgba(34,211,238,0.15)',
                      borderRadius: 10,
                      marginBottom: 16,
                      display:      'flex',
                      gap:          20,
                      flexWrap:    'wrap'
                    }}>
                      {[
                        ['📋', `${q.question_count} questions`],
                        ['⏱', `${q.time_limit} min`],
                        ['✅', `Pass: ${q.passing_score}%`]
                      ].map(([icon, text]) => (
                        <span key={text} style={{
                          color: 'rgba(186,230,253,0.6)',
                          fontSize: 12
                        }}>
                          {icon} {text}
                        </span>
                      ))}
                    </div>
                  ) : null
                })()}

                <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap' }}>
                  <button
                    type="submit"
                    disabled={creating || !selQuiz}
                    style={btnStyle}>
                    {creating ? 'Creating...' : '▶ Start Session'}
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setShowForm(false)
                      setSelQuiz('')
                    }}
                    style={{
                      padding:      '10px 20px',
                      background:   'transparent',
                      border:       '1px solid rgba(103,232,249,0.2)',
                      borderRadius: 12,
                      color:        'rgba(186,230,253,0.6)',
                      cursor:       'pointer',
                      fontFamily:   'inherit',
                      flex:          responsive.width <= 480 ? '1 1 100%' : '0 0 auto'
                    }}>
                    Cancel
                  </button>
                </div>

                <style>{`@media (max-width: 768px){
                  .s2q-sessions-stats{grid-template-columns:repeat(2,1fr) !important;}
                }
                @media (max-width: 480px){
                  .s2q-sessions-stats{grid-template-columns:repeat(2,1fr) !important;gap:12px !important;}
                }`}</style>
              </form>
            </GlassCard>
          )}

          {/* Stats row */}
          {!loading && (
            <div
              className="s2q-sessions-stats"
              style={{
                display: 'grid',
                gridTemplateColumns: (responsive.width <= 1024)
                  ? 'repeat(2, 1fr)'
                  : 'repeat(4, 1fr)',
                gap: (responsive.width <= 480) ? 12 : 16,
                marginBottom: 24,
              }}
            >
              {[
                {
                  label: 'Total Sessions',
                  value: sessions.length,
                  color: '#22d3ee',
                },
                {
                  label: 'Open Now',
                  value: sessions.filter(s => s.status === 'open').length,
                  color: '#4ade80',
                },
                {
                  label: 'Closed',
                  value: sessions.filter(s => s.status === 'closed').length,
                  color: '#f87171',
                },
                {
                  label: 'Total Attempts',
                  value: sessions.reduce(
                    (sum, s) => sum + (+s.attempt_count || 0), 0),
                  color: '#a78bfa',
                }
              ].map(stat => (
                <GlassCard key={stat.label} style={{ padding: 18 }}>
                  <div style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    marginBottom: 8,
                  }}>
                    <span style={{
                      fontSize: 11,
                      color: 'rgba(186,230,253,0.5)',
                      textTransform: 'uppercase',
                      letterSpacing: '0.8px'
                    }}>
                      {stat.label}
                    </span>
                    <span style={{ fontSize: 18 }}>{stat.icon}</span>
                  </div>
                  <p style={{
                    fontSize: 28,
                    fontWeight: 700,
                    color: stat.color,
                    margin: 0
                  }}>
                    {stat.value}
                  </p>
                </GlassCard>
              ))}
            </div>
          )}

          {/* Sessions list */}
          {loading ? (
            <div style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              height: 300
            }}>
              <p style={{ color: 'rgba(186,230,253,0.5)' }}>
                Loading sessions...
              </p>
            </div>
          ) : sessions.length === 0 ? (
            <GlassCard style={{ textAlign: 'center', padding: 48 }}>
              <p style={{
                color: '#e0f7ff',
                fontSize: 16,
                fontWeight: 600,
                margin: '0 0 8px'
              }}>
                No sessions yet
              </p>
              <p style={{
                color: 'rgba(186,230,253,0.4)',
                fontSize: 13
              }}>
                Click "+ New Session" to generate your first QR code
              </p>
            </GlassCard>
          ) : (
            <GlassCard>
              <div style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                marginBottom: 18
              }}>
                <h2 style={{
                  color: '#e0f7ff', fontSize: 16,
                  fontWeight: 600, margin: 0
                }}>
                  All Sessions
                </h2>
                <span style={{
                  fontSize: 12,
                  color: 'rgba(186,230,253,0.4)'
                }}>
                  {sessions.length} total
                </span>
              </div>

              <div style={{ overflowX: 'auto', width: '100%' }}>
                <table style={{
                  width: '100%',
                  borderCollapse: 'collapse',
                  minWidth: 760,
                }}>
                  <thead>
                    <tr>
                      {['Quiz', 'Code', 'Attempts',
                        'Started', 'Status', 'Actions'].map(h => (
                        <th key={h} style={{
                          textAlign: 'left',
                          padding: '8px 12px',
                          fontSize: 11,
                          color: 'rgba(186,230,253,0.45)',
                          fontWeight: 500,
                          textTransform: 'uppercase',
                          letterSpacing: '0.7px',
                          borderBottom: '1px solid rgba(103,232,249,0.1)'
                        }}>
                          {h}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {paginatedSessions.map((s, i) => {

                      const sc = statusColor(s.status)
                      const rowIndex = startIndex + i

                      return (
                        <tr key={s.id} style={{
                          borderBottom:
                            i < sessions.length - 1
                              ? '1px solid rgba(103,232,249,0.06)'
                              : 'none'
                        }}>
                          <td style={{ padding: '12px' }}>
                            <p style={{
                              color: '#e0f7ff',
                              fontWeight: 500,
                              margin: 0,
                              fontSize: 13
                            }}>
                              {s.quiz_title}
                            </p>
                          </td>
                          <td style={{ padding: '12px' }}>
                            <span style={{
                              fontFamily: 'monospace',
                              color: '#22d3ee',
                              fontSize: 14,
                              fontWeight: 700,
                              letterSpacing: 2
                            }}>
                              {s.session_code}
                            </span>
                          </td>
                          <td style={{ padding: '12px' }}>
                            <span style={{
                              color: '#e0f7ff',
                              fontWeight: 500,
                              fontSize: 13
                            }}>
                              {s.attempt_count}
                            </span>
                          </td>
                          <td style={{
                            padding: '12px',
                            color: 'rgba(186,230,253,0.5)',
                            fontSize: 12
                          }}>
                            {new Date(s.started_at).toLocaleDateString('en-US', {
                              month: 'short',
                              day: 'numeric',
                              year: 'numeric'
                            })}
                          </td>
                          <td style={{ padding: '12px' }}>
                            <span style={{
                              fontSize: 11,
                              fontWeight: 600,
                              padding: '3px 10px',
                              borderRadius: 20,
                              background: sc.bg,
                              border: `1px solid ${sc.border}`,
                              color: sc.color
                            }}>
                              {s.status}
                            </span>
                          </td>
                          <td style={{ padding: '12px' }}>
                            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
                              <button
                                onClick={async () => {
                                  try {
                                    const q = quizzes.find(q => q.title === s.quiz_title)
                                    if (!q) return alert('Quiz not found')
                                    const res = await createSession(q.id)
                                    setQrModal(res.data.data)
                                    loadData()
                                  } catch {
                                    alert('Could not create new session')
                                  }
                                }}
                                style={{
                                  padding: '5px 12px',
                                  background: 'rgba(34,211,238,0.1)',
                                  border: '1px solid rgba(34,211,238,0.3)',
                                  borderRadius: 8,
                                  color: '#22d3ee',
                                  fontSize: 11,
                                  cursor: 'pointer',
                                  fontFamily: 'inherit'
                                }}>
                                🔳 New QR
                              </button>

                              {s.status === 'open' && (
                                <button
                                  onClick={() => handleClose(s.id)}
                                  disabled={closing === s.id}
                                  style={{
                                    padding: '5px 12px',
                                    background: 'rgba(248,113,113,0.1)',
                                    border: '1px solid rgba(248,113,113,0.3)',
                                    borderRadius: 8,
                                    color: '#f87171',
                                    fontSize: 11,
                                    cursor: 'pointer',
                                    fontFamily: 'inherit'
                                  }}>
                                  {closing === s.id ? '...' : '🔒 Close'}
                                </button>
                              )}
                            </div>
                          </td>
                        </tr>
                      )
                    })}
                  </tbody>
                </table>
              </div>

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
                isMobile={responsive.isMobile}
              />
            </GlassCard>

          )}
        </div>
      </div>

      {/* QR Modal */}
      {qrModal && (
        <div style={{
          position: 'fixed',
          inset: 0,
          background: 'rgba(0,0,0,0.7)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          zIndex: 100,
          backdropFilter: 'blur(4px)'
        }}>
          <div style={{
            background: 'rgba(10,22,40,0.95)',
            border: '1px solid rgba(34,211,238,0.3)',
            borderRadius: 24,
            padding: 36,
            textAlign: 'center',
            maxWidth: 400,
            width: '90%',
            boxShadow: '0 0 60px rgba(34,211,238,0.15)',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center'
          }}>
            <h2 style={{
              color: '#e0f7ff',
              fontSize: 18,
              fontWeight: 600,
              margin: '0 0 4px'
            }}>
              Session Ready!
            </h2>
            <p style={{
              color: 'rgba(186,230,253,0.5)',
              fontSize: 13,
              margin: '0 0 20px'
            }}>
              {qrModal.quizTitle}
            </p>

            <div style={{
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
              marginBottom: 16
            }}>
              <img
                src={qrModal.qrImage}
                alt="QR Code"
                style={{
                  width: 200,
                  height: 200,
                  borderRadius: 12,
                  display: 'block'
                }}
              />
            </div>

            <div style={{
              background: 'rgba(34,211,238,0.1)',
              border: '1px solid rgba(34,211,238,0.3)',
              borderRadius: 12,
              padding: '12px 20px',
              marginBottom: 20,
              width: '100%'
            }}>
              <p style={{
                color: 'rgba(186,230,253,0.5)',
                fontSize: 11,
                margin: '0 0 4px',
                textTransform: 'uppercase',
                letterSpacing: '0.8px'
              }}>
                Session Code
              </p>
              <p style={{
                color: '#22d3ee',
                fontSize: 28,
                fontWeight: 700,
                margin: 0,
                fontFamily: 'monospace',
                letterSpacing: 4
              }}>
                {qrModal.sessionCode}
              </p>
            </div>

            <p style={{
              color: 'rgba(186,230,253,0.4)',
              fontSize: 12,
              margin: '0 0 16px'
            }}>
              Students scan this QR code to join the session
            </p>

            <button
              onClick={() => setQrModal(null)}
              style={{
                ...btnStyle,
                width: '100%'
              }}>
              Close
            </button>
          </div>
        </div>
      )}
    </div>
  )
}

