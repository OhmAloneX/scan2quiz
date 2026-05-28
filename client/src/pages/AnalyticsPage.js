import { useState, useEffect } from 'react'
import Sidebar       from '../components/layout/Sidebar'
import GlassCard     from '../components/ui/GlassCard'
import StatCard      from '../components/ui/StatCard'
import useResponsive  from '../hooks/useResponsive'

import {
  LineChart, Line, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer, PieChart, Pie,
  Cell, 
} from 'recharts'
import {
  getDashboard, getTrend,
  getDistribution, getTopStudents
} from '../services/analyticsService'

const PIE_COLORS = ['#22d3ee', '#6366f1', '#a78bfa', '#f87171']

function CustomLineTooltip({ active, payload, label }) {
  if (!active || !payload?.length) return null
  return (
    <div style={{
      background:   'rgba(10,22,40,0.95)',
      border:       '1px solid rgba(103,232,249,0.2)',
      borderRadius: 12,
      padding:      '10px 14px'
    }}>
      <p style={{
        color: 'rgba(186,230,253,0.5)',
        fontSize: 11, margin: '0 0 6px'
      }}>
        {label}
      </p>
      {payload.map((p, i) => (
        <div key={i} style={{
          display: 'flex', gap: 8,
          alignItems: 'center', marginBottom: 2
        }}>
          <div style={{
            width: 8, height: 8,
            borderRadius: '50%', background: p.color
          }}/>
          <span style={{
            color: '#e0f7ff', fontSize: 13, fontWeight: 600
          }}>
            {p.value}%
          </span>
          <span style={{
            color: 'rgba(186,230,253,0.5)', fontSize: 11
          }}>
            {p.name}
          </span>
        </div>
      ))}
    </div>
  )
}

function CustomPieTooltip({ active, payload }) {
  if (!active || !payload?.length) return null
  return (
    <div style={{
      background:   'rgba(10,22,40,0.95)',
      border:       '1px solid rgba(103,232,249,0.2)',
      borderRadius: 12,
      padding:      '8px 14px'
    }}>
      <p style={{
        color: '#e0f7ff', fontSize: 13,
        fontWeight: 600, margin: 0
      }}>
        {payload[0].name}: {payload[0].value}
      </p>
    </div>
  )
}

export default function AnalyticsPage() {
  const [stats,    setStats]    = useState(null)
  const [trend,    setTrend]    = useState([])
  const [dist,     setDist]     = useState(null)
  const [topStuds, setTopStuds] = useState([])
  const [loading,  setLoading]  = useState(true)

  const { isMobile, isTablet } = useResponsive()


  useEffect(() => {
    async function load() {
      try {
        const [s, t, d, ts] = await Promise.all([
          getDashboard(),
          getTrend(),
          getDistribution(),
          getTopStudents()
        ])
        setStats(s.data.data)
        setTrend(t.data.data)
        setDist(d.data.data)
        setTopStuds(ts.data.data)
      } catch (err) {
        console.error(err)
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [])

  // Format distribution data for pie chart
  const pieData = dist ? [
    { name: '90–100', value: +dist.score_90_100  || 0 },
    { name: '75–89',  value: +dist.score_75_89   || 0 },
    { name: '60–74',  value: +dist.score_60_74   || 0 },
    { name: 'Below 60', value: +dist.score_below_60 || 0 },
  ] : []

  const totalAttempts = pieData.reduce((a, b) => a + b.value, 0)

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
          padding:        isMobile ? '12px 14px' : isTablet ? '14px 20px' : '16px 28px',

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
              Analytics
            </h1>
            <p style={{
              color: 'rgba(186,230,253,0.5)',
              fontSize: 13, margin: '2px 0 0'
            }}>
              Track performance and student progress
            </p>
          </div>
        </div>

        <div style={{ padding: isMobile ? '16px 14px' : isTablet ? '20px 20px' : '24px 28px' }}>

          {loading ? (
            <div style={{
              display:        'flex',
              alignItems:     'center',
              justifyContent: 'center',
              height:         300
            }}>
              <p style={{ color: 'rgba(186,230,253,0.5)' }}>
                Loading analytics...
              </p>
            </div>
          ) : (
            <>
              {/* Stat cards */}
              <div style={{
                display:             'grid',
                gridTemplateColumns: isMobile ? 'repeat(2,1fr)' : isTablet ? 'repeat(2,1fr)' : 'repeat(4,1fr)',
                gap:                 isMobile ? 12 : 16,
                marginBottom:        isMobile ? 18 : 24
              }}>


                <StatCard
                  label="Total Attempts"
                  value={stats?.total_attempts ?? 0}
                  sub="All sessions"
                  
                />
                <StatCard
                  label="Average Score"
                  value={stats?.avg_score
                    ? `${stats.avg_score}%` : '—'}
                  sub="Across all quizzes"
                  
                />
                <StatCard
                  label="Highest Score"
                  value={stats?.highest_score
                    ? `${stats.highest_score}%` : '—'}
                  sub="Best performance"
                  
                />
                <StatCard
                  label="Unique Students"
                  value={stats?.unique_students ?? 0}
                  sub="Participated"
                  
                />
              </div>

              {/* Charts row */}
              <div style={{
                display:             'grid',
                gridTemplateColumns: isMobile ? '1fr' : isTablet ? '1fr 280px' : '1fr 340px',
                gap:                 isMobile ? 14 : 20,
                marginBottom:        isMobile ? 18 : 24
              }}>

                {/* Line chart */}
                <GlassCard glow>
                  <div style={{
                    display:        'flex',
                    justifyContent: 'space-between',
                    alignItems:     'center',
                    marginBottom:   20
                  }}>
                    <div>
                      <p style={{
                        color:         'rgba(186,230,253,0.55)',
                        fontSize:      11,
                        margin:        '0 0 2px',
                        textTransform: 'uppercase',
                        letterSpacing: '0.8px'
                      }}>
                        Performance Trend
                      </p>
                      <h2 style={{
                        color: '#e0f7ff', fontSize: 16,
                        fontWeight: 600, margin: 0
                      }}>
                        Monthly Score Overview
                      </h2>
                    </div>
                    <div style={{
                      display: 'flex', gap: 12
                    }}>
                      {[
                        { color: '#22d3ee', label: 'Avg' },
                        { color: '#a78bfa', label: 'High' }
                      ].map(({ color, label }) => (
                        <div key={label} style={{
                          display: 'flex',
                          alignItems: 'center', gap: 5
                        }}>
                          <div style={{
                            width: 10, height: 3,
                            borderRadius: 2, background: color
                          }}/>
                          <span style={{
                            fontSize: 11,
                            color: 'rgba(186,230,253,0.5)'
                          }}>
                            {label}
                          </span>
                        </div>
                      ))}
                    </div>
                  </div>

                  {trend.length === 0 ? (
                    <div style={{
                      height:         220,
                      display:        'flex',
                      alignItems:     'center',
                      justifyContent: 'center'
                    }}>
                      <p style={{
                        color: 'rgba(186,230,253,0.3)',
                        fontSize: 13
                      }}>
                        No trend data yet — complete some quiz
                        sessions first
                      </p>
                    </div>
                  ) : (
                    <ResponsiveContainer width="100%" height={220}>
                      <LineChart data={trend}
                        margin={{
                          top: 4, right: 4, bottom: 0, left: -20
                        }}>
                        <CartesianGrid
                          strokeDasharray="3 3"
                          stroke="rgba(103,232,249,0.08)"
                        />
                        <XAxis dataKey="month"
                          tick={{
                            fill: 'rgba(186,230,253,0.35)',
                            fontSize: 11
                          }}
                          axisLine={false} tickLine={false}
                        />
                        <YAxis
                          tick={{
                            fill: 'rgba(186,230,253,0.35)',
                            fontSize: 11
                          }}
                          axisLine={false} tickLine={false}
                          domain={[0, 100]}
                        />
                        <Tooltip content={<CustomLineTooltip />}/>
                        <Line type="monotone" dataKey="avg_score"
                          name="Avg" stroke="#22d3ee"
                          strokeWidth={2.5} dot={false}
                          activeDot={{
                            r: 5, fill: '#22d3ee',
                            stroke: '#0a1628', strokeWidth: 2
                          }}
                        />
                        <Line type="monotone" dataKey="high_score"
                          name="High" stroke="#a78bfa"
                          strokeWidth={2} dot={false}
                          strokeDasharray="5 3"
                          activeDot={{
                            r: 5, fill: '#a78bfa',
                            stroke: '#0a1628', strokeWidth: 2
                          }}
                        />
                      </LineChart>
                    </ResponsiveContainer>
                  )}
                </GlassCard>

                {/* Pie chart */}
                <GlassCard glow style={{
                  display: 'flex', flexDirection: 'column'
                }}>
                  <p style={{
                    color:         'rgba(186,230,253,0.55)',
                    fontSize:      11,
                    margin:        '0 0 2px',
                    textTransform: 'uppercase',
                    letterSpacing: '0.8px'
                  }}>
                    Score Distribution
                  </p>
                  <h2 style={{
                    color: '#e0f7ff', fontSize: 16,
                    fontWeight: 600, margin: '0 0 12px'
                  }}>
                    Grade Breakdown
                  </h2>

                  {totalAttempts === 0 ? (
                    <div style={{
                      flex:           1,
                      display:        'flex',
                      alignItems:     'center',
                      justifyContent: 'center'
                    }}>
                      <p style={{
                        color: 'rgba(186,230,253,0.3)',
                        fontSize: 13, textAlign: 'center'
                      }}>
                        No attempts yet
                      </p>
                    </div>
                  ) : (
                    <>
                      <ResponsiveContainer width="100%" height={180}>
                        <PieChart>
                          <Pie data={pieData} cx="50%" cy="50%"
                            innerRadius={52} outerRadius={78}
                            paddingAngle={3} dataKey="value">
                            {pieData.map((_, i) => (
                              <Cell key={i}
                                fill={PIE_COLORS[i]}
                                opacity={0.88}
                                stroke="rgba(10,22,40,0.6)"
                                strokeWidth={2}
                              />
                            ))}
                          </Pie>
                          <Tooltip content={<CustomPieTooltip />}/>
                        </PieChart>
                      </ResponsiveContainer>

                      <div style={{
                        display:       'flex',
                        flexDirection: 'column',
                        gap:           8,
                        marginTop:     8
                      }}>
                        {pieData.map((d, i) => (
                          <div key={i} style={{
                            display:        'flex',
                            alignItems:     'center',
                            justifyContent: 'space-between'
                          }}>
                            <div style={{
                              display:    'flex',
                              alignItems: 'center',
                              gap:        8
                            }}>
                              <div style={{
                                width:        10,
                                height:       10,
                                borderRadius: 3,
                                background:   PIE_COLORS[i]
                              }}/>
                              <span style={{
                                fontSize: 12,
                                color: 'rgba(186,230,253,0.7)'
                              }}>
                                {d.name}
                              </span>
                            </div>
                            <span style={{
                              fontSize:   13,
                              fontWeight: 600,
                              color:      '#e0f7ff'
                            }}>
                              {d.value}
                            </span>
                          </div>
                        ))}
                      </div>
                    </>
                  )}
                </GlassCard>
              </div>

              {/* Top Students table */}
              <GlassCard>
                <h2 style={{
                  color: '#e0f7ff', fontSize: 16,
                  fontWeight: 600, margin: '0 0 18px'
                }}>
                  Top Students
                </h2>

                {topStuds.length === 0 ? (

                  <div style={{
                    textAlign: 'center', padding: '32px 0'
                  }}>
                    <p style={{
                      color: 'rgba(186,230,253,0.4)',
                      fontSize: 14
                    }}>
                      No student data yet
                    </p>
                  </div>
                ) : (
                  <div style={{ overflowX: 'auto' }}>
                    <table style={{
                      width:           '100%',
                      borderCollapse:  'collapse',
                      minWidth:        650
                    }}>

                    <thead>
                      <tr>
                        {['#', 'Student', 'Section',
                          'Attempts', 'Avg Score',
                          'Best Score'].map(h => (
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
                      {topStuds.map((s, i) => (
                        <tr key={s.student_id} style={{
                          borderBottom:
                            i < topStuds.length - 1
                              ? '1px solid rgba(103,232,249,0.06)'
                              : 'none'
                        }}>
                          <td style={{
                            padding: '12px',
                            color:   i === 0 ? '#fbbf24'
                                   : i === 1 ? '#94a3b8'
                                   : i === 2 ? '#cd7c4a'
                                   : 'rgba(186,230,253,0.4)',
                            fontSize:   13,
                            fontWeight: 600
                          }}>
                            {i === 0 ? '🥇'
                           : i === 1 ? '🥈'
                           : i === 2 ? '🥉'
                           : `#${i + 1}`}
                          </td>
                          <td style={{ padding: '12px' }}>
                            <p style={{
                              color: '#e0f7ff', fontSize: 13,
                              fontWeight: 500, margin: 0
                            }}>
                              {s.name}
                            </p>
                            <p style={{
                              color: 'rgba(186,230,253,0.4)',
                              fontSize: 11, margin: '2px 0 0',
                              fontFamily: 'monospace'
                            }}>
                              {s.student_id}
                            </p>
                          </td>
                          <td style={{
                            padding:  '12px',
                            color:    'rgba(186,230,253,0.6)',
                            fontSize: 13
                          }}>
                            {s.section || '—'}
                          </td>
                          <td style={{
                            padding:  '12px',
                            color:    'rgba(186,230,253,0.6)',
                            fontSize: 13
                          }}>
                            {s.attempts}
                          </td>
                          <td style={{ padding: '12px' }}>
                            <span style={{
                              color:      '#22d3ee',
                              fontSize:   13,
                              fontWeight: 600
                            }}>
                              {s.avg_score}%
                            </span>
                          </td>
                          <td style={{ padding: '12px' }}>
                            <span style={{
                              fontSize:     11,
                              fontWeight:   600,
                              padding:      '3px 10px',
                              borderRadius: 20,
                              background:
                                s.best_score >= 90
                                  ? 'rgba(74,222,128,0.15)'
                                  : 'rgba(251,191,36,0.15)',
                              color:
                                s.best_score >= 90
                                  ? '#4ade80'
                                  : '#fbbf24',
                              border: `1px solid ${
                                s.best_score >= 90
                                  ? 'rgba(74,222,128,0.3)'
                                  : 'rgba(251,191,36,0.3)'}`
                            }}>
                              {s.best_score}%
                            </span>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                    </table>
                  </div>
                )}

              </GlassCard>
            </>
          )}
        </div>
      </div>
    </div>
  )
}