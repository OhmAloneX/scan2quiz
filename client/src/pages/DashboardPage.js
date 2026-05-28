import { useState, useEffect } from 'react'
import { useAuth }   from '../context/AuthContext'
import Sidebar       from '../components/layout/Sidebar'
import StatCard      from '../components/ui/StatCard'
import GlassCard     from '../components/ui/GlassCard'
import { getDashboard, getTrend } from '../services/analyticsService'
import { getSessions }            from '../services/sessionService'
import useResponsive from '../hooks/useResponsive'


export default function DashboardPage() {
  const { user }                    = useAuth()
  const { isMobile, isTablet }     = useResponsive()
  const [stats,    setStats]        = useState(null)
  const [trend,    setTrend]        = useState([])
  const [sessions, setSessions]     = useState([])
  const [loading,  setLoading]      = useState(true)


  useEffect(() => {
    async function load() {
      try {
        const [s, t, se] = await Promise.all([
          getDashboard(),
          getTrend(),
          getSessions()
        ])
        setStats(s.data.data)
        setTrend(t.data.data)
        setSessions(se.data.data)
      } catch (err) {
        console.error(err)
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [])

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
              Hi, {user?.email?.split('@')[0]} !
            </h1>
            <p style={{
              color:    'rgba(186,230,253,0.5)',
              fontSize: 13,
              margin:   '2px 0 0'
            }}>
              Welcome to your Scan2Quiz Dashboard
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
        <div style={{ padding: isMobile ? '16px 14px' : isTablet ? '20px 18px' : '24px 28px' }}>

          {loading ? (
            <div style={{
              display:        'flex',
              alignItems:     'center',
              justifyContent: 'center',
              height:         300
            }}>
              <p style={{ color: 'rgba(186,230,253,0.5)' }}>
                Loading dashboard...
              </p>
            </div>
          ) : (
            <>
              {/* Stat cards */}
              <div style={{
                display:             'grid',
                gridTemplateColumns: isMobile
                  ? '1fr'
                  : isTablet
                    ? 'repeat(2, 1fr)'
                    : 'repeat(4, 1fr)',
                gap:                 isMobile ? 12 : 16,
                marginBottom:        isMobile ? 18 : 24
              }}>

                <StatCard
                  label="Total Quizzes"
                  value={stats?.total_quizzes ?? 0}
                  sub="All time"
                  
                  
                />
                <StatCard
                  label="Total Sessions"
                  value={stats?.total_sessions ?? 0}
                  sub="All time"
                  
                  
                />
                <StatCard
                  label="Avg Score"
                  value={stats?.avg_score
                    ? `${stats.avg_score}%` : '—'}
                  sub="Across all attempts"
                  
                  
                />
                <StatCard
                  label="Students"
                  value={stats?.unique_students ?? 0}
                  sub="Unique participants"
                  
                />
              </div>

              {/* Recent sessions */}
              <GlassCard glow>
                <div style={{
                  display:        'flex',
                  justifyContent: 'space-between',
                  alignItems:     'center',
                  marginBottom:   18,
                  gap:             isMobile ? 12 : 16,
                  flexWrap:       isMobile ? 'wrap' : 'nowrap'
                }}>
                  <h2 style={{
                    color:      '#e0f7ff',
                    fontSize:   16,
                    fontWeight: 600,
                    margin:     0
                  }}>
                    Recent Sessions
                  </h2>
                  <span style={{
                    fontSize: 11,
                    color:    'rgba(186,230,253,0.4)'
                  }}>
                    {sessions.length} total
                  </span>
                </div>

                {sessions.length === 0 ? (
                  <div style={{
                    textAlign: 'center',
                    padding:   isMobile ? '24px 0' : '32px 0'
                  }}>

                    <p style={{
                      color:    'rgba(186,230,253,0.4)',
                      fontSize: 14
                    }}>
                      No sessions yet. Create a quiz and
                      start a session!
                    </p>
                  </div>
                ) : (
                  <div style={{
                    width:      '100%',
                    overflowX: 'auto'
                  }}>
                    <table style={{
                      width:           '100%',
                      borderCollapse:  'collapse',
                      minWidth:        isMobile ? 420 : 0,
                      tableLayout:    'auto'
                    }}>

                    <thead>
                      <tr>
                        {['Quiz', 'Code', 'Attempts',
                          'Status', 'Started'].map(h => (
                          <th key={h} style={{
                            textAlign:     'left',
                            padding:       '8px 12px',
                            fontSize:      11,
                            color:         'rgba(186,230,253,0.45)',
                            fontWeight:    500,
                            textTransform: 'uppercase',
                            letterSpacing: '0.7px',
                            borderBottom:  '1px solid rgba(103,232,249,0.1)'
                          }}>
                            {h}
                          </th>
                        ))}
                      </tr>
                    </thead>
                    <tbody>
                      {sessions.slice(0, 8).map((s, i) => (
                        <tr key={s.id} style={{
                          borderBottom: i < sessions.length - 1
                            ? '1px solid rgba(103,232,249,0.06)'
                            : 'none'
                        }}>
                          <td style={{
                            padding:    '12px',
                            color:      '#e0f7ff',
                            fontSize:   13,
                            fontWeight: 500
                          }}>
                            {s.quiz_title}
                          </td>
                          <td style={{
                            padding:    '12px',
                            fontFamily: 'monospace',
                            color:      '#22d3ee',
                            fontSize:   13
                          }}>
                            {s.session_code}
                          </td>
                          <td style={{
                            padding:  '12px',
                            color:    'rgba(186,230,253,0.7)',
                            fontSize: 13
                          }}>
                            {s.attempt_count}
                          </td>
                          <td style={{ padding: '12px' }}>
                            <span style={{
                              fontSize:   11,
                              fontWeight: 600,
                              padding:    '3px 10px',
                              borderRadius: 20,
                              background: s.status === 'open'
                                ? 'rgba(74,222,128,0.15)'
                                : 'rgba(99,102,241,0.15)',
                              color: s.status === 'open'
                                ? '#4ade80'
                                : '#a5b4fc',
                              border: `1px solid ${s.status === 'open'
                            ? 'rgba(74,222,128,0.3)'
                                : 'rgba(165,180,252,0.3)'}`
                            }}>
                              {s.status}
                            </span>
                          </td>
                          <td style={{
                            padding:  '12px',
                            color:    'rgba(186,230,253,0.5)',
                            fontSize: 12
                          }}>
                            {new Date(s.started_at)
                              .toLocaleDateString()}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                    </table>
                  </div>
                )}

              </GlassCard>

              {/* Trend data */}
              {trend.length > 0 && (
                <GlassCard style={{ marginTop: 20 }}>
                  <h2 style={{
                    color:        '#e0f7ff',
                    fontSize:     16,
                    fontWeight:   600,
                    margin:       '0 0 16px'
                  }}>
                    Monthly Score Trend
                  </h2>
                  <div style={{
                    display: 'flex',
                    gap:     16,
                    flexWrap: 'wrap'
                  }}>
                    {trend.map((t, i) => (
                      <div key={i} style={{
                        background:   'rgba(255,255,255,0.04)',
                        border:       '1px solid rgba(103,232,249,0.15)',
                        borderRadius: 12,
                        padding:      '10px 16px',
                        textAlign:    'center'
                      }}>
                        <p style={{
                          color:    'rgba(186,230,253,0.5)',
                          fontSize: 11,
                          margin:   '0 0 4px'
                        }}>
                          {t.month} {t.year}
                        </p>
                        <p style={{
                          color:      '#22d3ee',
                          fontSize:   18,
                          fontWeight: 700,
                          margin:     0
                        }}>
                          {t.avg_score}%
                        </p>
                        <p style={{
                          color:    'rgba(186,230,253,0.4)',
                          fontSize: 10,
                          margin:   '2px 0 0'
                        }}>
                          {t.attempts} attempts
                        </p>
                      </div>
                    ))}
                  </div>
                </GlassCard>
              )}
            </>
          )}
        </div>
      </div>
    </div>
  )
}