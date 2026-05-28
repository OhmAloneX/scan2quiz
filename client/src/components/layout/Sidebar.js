import { useState, useEffect } from 'react'
import api from '../../services/api'
import { useNavigate, useLocation } from 'react-router-dom'
import { useAuth } from '../../context/AuthContext'
import useResponsive from '../../hooks/useResponsive'

function PendingBadge() {
  const [count, setCount] = useState(0)

  useEffect(() => {
    api.get('/auth/users/pending')
      .then(res => setCount(res.data.data.length))
      .catch(() => {})
  }, [])

  if (count === 0) return null

  return (
    <div style={{
      marginLeft:   'auto',
      background:   '#fbbf24',
      color:        '#0f172a',
      fontSize:     10,
      fontWeight:   700,
      borderRadius: 10,
      padding:      '1px 6px',
      minWidth:     18,
      textAlign:    'center'
    }}>
      {count}
    </div>
  )
}

const NAV = [
  { path: '/dashboard', label: 'Dashboard', role: null },
  { path: '/quizzes',   label: 'Quizzes', role: null },
  { path: '/sessions',  label: 'Sessions', role: null },
  { path: '/scanner',   label: 'Scanner', role: null },
  { path: '/analytics', label: 'Analytics', role: null },
  { path: '/students',  label: 'Students', role: null },
  { path: '/admin',     label: 'Admin', role: 'admin' },
]

export default function Sidebar() {
  const navigate = useNavigate()
  const location = useLocation()
  const { logout, user } = useAuth()
  const { isTablet, isMobile } = useResponsive()

  const [drawerOpen, setDrawerOpen] = useState(false)

  function closeDrawer() {
    setDrawerOpen(false)
  }

  useEffect(() => {
    if (isMobile || isTablet) return
    setDrawerOpen(false)
  }, [isMobile, isTablet])

  useEffect(() => {
    if (!(isMobile || isTablet)) return
    if (!drawerOpen) return

    function onKeyDown(e) {
      if (e.key === 'Escape') closeDrawer()
    }

    window.addEventListener('keydown', onKeyDown)
    return () => window.removeEventListener('keydown', onKeyDown)
  }, [drawerOpen, isMobile, isTablet])

  function handleNav(path) {
    navigate(path)
    closeDrawer()
  }

  const sidebarWidth = 220

  const sidebarBaseStyle = {
    width: sidebarWidth,
    flexShrink: 0,
    background: 'rgba(255,255,255,0.04)',
    backdropFilter: 'blur(24px)',
    borderRight: '1px solid rgba(103,232,249,0.1)',
    display: 'flex',
    flexDirection: 'column',
    padding: '20px 10px',
    minHeight: '100vh'
  }

  const drawerStyle = {
    position: 'fixed',
    top: 0,
    left: 0,
    zIndex: 110,
    height: '100vh',
    transform: drawerOpen
      ? 'translateX(0)'
      : `translateX(-${sidebarWidth}px)`,
    transition: 'transform 0.25s ease'
  }

  const shouldHide = isMobile || isTablet

  return (
    <>
      {(isMobile || isTablet) && (
        <button
          type="button"
          onClick={() => setDrawerOpen(true)}
          aria-label="Open navigation menu"
          style={{
            position: 'fixed',
            top: 14,
            left: 14,
            zIndex: 120,
            width: 44,
            height: 44,
            borderRadius: 14,
            background: 'rgba(255,255,255,0.04)',
            border: '1px solid rgba(103,232,249,0.15)',
            backdropFilter: 'blur(24px)',
            color: '#e0f7ff',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            boxShadow: drawerOpen
              ? '0 0 0 1px rgba(34,211,238,0.35)'
              : 'none'
          }}>
          <span
            aria-hidden="true"
            style={{
              width: 18,
              height: 14,
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between'
            }}>
            <span
              style={{
                height: 2,
                background: 'rgba(34,211,238,0.8)',
                borderRadius: 2,
                transform: drawerOpen ? 'translateY(6px) rotate(45deg)' : 'none',
                transition: 'transform 0.25s ease'
              }} />
            <span
              style={{
                height: 2,
                background: 'rgba(186,230,253,0.6)',
                borderRadius: 2,
                opacity: drawerOpen ? 0 : 1,
                transition: 'opacity 0.2s ease'
              }} />
            <span
              style={{
                height: 2,
                background: 'rgba(99,102,241,0.8)',
                borderRadius: 2,
                transform: drawerOpen ? 'translateY(-6px) rotate(-45deg)' : 'none',
                transition: 'transform 0.25s ease'
              }} />
          </span>
        </button>
      )}

      {(isMobile || isTablet) && drawerOpen && (
        <div
          onClick={closeDrawer}
          aria-label="Close navigation menu overlay"
          style={{
            position: 'fixed',
            inset: 0,
            background: 'rgba(0,0,0,0.55)',
            backdropFilter: 'blur(4px)',
            zIndex: 105
          }}
        />
      )}

      {/* Desktop sidebar (always visible) */}
      {!shouldHide && (
        <div style={sidebarBaseStyle}>
          {/* Logo */}
          <div style={{
            display: 'flex',
            alignItems: 'center',
            gap: 10,
            padding: '0 8px 20px',
            borderBottom: '1px solid rgba(103,232,249,0.1)',
            marginBottom: 16
          }}>
            <div style={{
              width: 36,
              height: 36,
              borderRadius: 10,
              background: 'linear-gradient(135deg,#22d3ee,#6366f1)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontWeight: 700,
              color: '#0f172a',
              fontSize: 16,
              boxShadow: '0 0 14px rgba(34,211,238,0.35)'
            }}>
              S
            </div>

            <span style={{
              fontFamily: 'monospace',
              fontSize: 17,
              fontWeight: 700,
              color: '#e0f7ff'
            }}>
              Scan<span style={{ color: '#22d3ee' }}>2</span>Quiz
            </span>
          </div>

          {/* Nav items */}
          <nav style={{
            display: 'flex',
            flexDirection: 'column',
            gap: 4,
            flex: 1
          }}>
            {NAV
              .filter(item => item.role === null || item.role === user?.role)
              .map(({ path, label, icon }) => {
                const active = location.pathname === path

                return (
                  <button
                    key={path}
                    onClick={() => handleNav(path)}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: 12,
                      padding: '10px 14px',
                      borderRadius: 12,
                      border: 'none',
                      cursor: 'pointer',
                      background: active
                        ? 'linear-gradient(135deg,rgba(34,211,238,0.2), rgba(99,102,241,0.16))'
                        : 'transparent',
                      boxShadow: active
                        ? '0 0 0 1px rgba(34,211,238,0.35)'
                        : 'none',
                      color: active
                        ? '#e0f7ff'
                        : 'rgba(186,230,253,0.6)',
                      fontSize: 14,
                      fontWeight: active ? 500 : 400,
                      textAlign: 'left',
                      width: '100%'
                    }}>
                    <span style={{ fontSize: 16 }}>{icon}</span>
                    <span>{label}</span>

                    {active && (
                      <div style={{
                        marginLeft: 'auto',
                        width: 6,
                        height: 6,
                        borderRadius: '50%',
                        background: '#22d3ee',
                        boxShadow: '0 0 6px #22d3ee'
                      }} />
                    )}

                    {path === '/admin' && !active && <PendingBadge />}
                  </button>
                )
              })}
          </nav>

          {/* User + logout */}
          <div style={{
            borderTop: '1px solid rgba(103,232,249,0.1)',
            paddingTop: 14,
            display: 'flex',
            alignItems: 'center',
            gap: 10
          }}>
            <div style={{
              width: 34,
              height: 34,
              borderRadius: '50%',
              background: 'linear-gradient(135deg,#22d3ee,#6366f1)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: 13,
              fontWeight: 700,
              color: '#0f172a',
              flexShrink: 0
            }}>
              {user?.email?.[0]?.toUpperCase() || 'A'}
            </div>

            <div style={{ flex: 1, minWidth: 0 }}>
              <p style={{
                color: '#e0f7ff',
                fontSize: 12,
                fontWeight: 500,
                margin: 0,
                overflow: 'hidden',
                textOverflow: 'ellipsis',
                whiteSpace: 'nowrap'
              }}>
                {user?.role || 'Teacher'}
              </p>
            </div>

            <button
              onClick={logout}
              style={{
                background: 'none',
                border: 'none',
                cursor: 'pointer',
                color: 'rgba(248,113,113,0.7)',
                fontSize: 18,
                padding: 4
              }}
              title="Logout"
            >
              ↩
            </button>
          </div>
        </div>
      )}

      {/* Mobile/Tablet drawer */}
      {shouldHide && drawerOpen && (
        <div style={{ ...sidebarBaseStyle, ...drawerStyle }}>
          {/* Logo */}
          <div style={{
            display: 'flex',
            alignItems: 'center',
            gap: 10,
            padding: '0 8px 20px',
            borderBottom: '1px solid rgba(103,232,249,0.1)',
            marginBottom: 16
          }}>
            <div style={{
              width: 36,
              height: 36,
              borderRadius: 10,
              background: 'linear-gradient(135deg,#22d3ee,#6366f1)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontWeight: 700,
              color: '#0f172a',
              fontSize: 16,
              boxShadow: '0 0 14px rgba(34,211,238,0.35)'
            }}>
              S
            </div>

            <span style={{
              fontFamily: 'monospace',
              fontSize: 17,
              fontWeight: 700,
              color: '#e0f7ff'
            }}>
              Scan<span style={{ color: '#22d3ee' }}>2</span>Quiz
            </span>
          </div>

          {/* Nav items */}
          <nav style={{
            display: 'flex',
            flexDirection: 'column',
            gap: 4,
            flex: 1
          }}>
            {NAV
              .filter(item => item.role === null || item.role === user?.role)
              .map(({ path, label, icon }) => {
                const active = location.pathname === path

                return (
                  <button
                    key={path}
                    onClick={() => handleNav(path)}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: 12,
                      padding: '10px 14px',
                      borderRadius: 12,
                      border: 'none',
                      cursor: 'pointer',
                      background: active
                        ? 'linear-gradient(135deg,rgba(34,211,238,0.2), rgba(99,102,241,0.16))'
                        : 'transparent',
                      boxShadow: active
                        ? '0 0 0 1px rgba(34,211,238,0.35)'
                        : 'none',
                      color: active
                        ? '#e0f7ff'
                        : 'rgba(186,230,253,0.6)',
                      fontSize: 14,
                      fontWeight: active ? 500 : 400,
                      textAlign: 'left',
                      width: '100%'
                    }}>
                    <span style={{ fontSize: 16 }}>{icon}</span>
                    <span>{label}</span>

                    {active && (
                      <div style={{
                        marginLeft: 'auto',
                        width: 6,
                        height: 6,
                        borderRadius: '50%',
                        background: '#22d3ee',
                        boxShadow: '0 0 6px #22d3ee'
                      }} />
                    )}

                    {path === '/admin' && !active && <PendingBadge />}
                  </button>
                )
              })}
          </nav>

          {/* User + logout */}
          <div style={{
            borderTop: '1px solid rgba(103,232,249,0.1)',
            paddingTop: 14,
            display: 'flex',
            alignItems: 'center',
            gap: 10
          }}>
            <div style={{
              width: 34,
              height: 34,
              borderRadius: '50%',
              background: 'linear-gradient(135deg,#22d3ee,#6366f1)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: 13,
              fontWeight: 700,
              color: '#0f172a',
              flexShrink: 0
            }}>
              {user?.email?.[0]?.toUpperCase() || 'A'}
            </div>

            <div style={{ flex: 1, minWidth: 0 }}>
              <p style={{
                color: '#e0f7ff',
                fontSize: 12,
                fontWeight: 500,
                margin: 0,
                overflow: 'hidden',
                textOverflow: 'ellipsis',
                whiteSpace: 'nowrap'
              }}>
                {user?.role || 'Teacher'}
              </p>
            </div>

            <button
              onClick={logout}
              style={{
                background: 'none',
                border: 'none',
                cursor: 'pointer',
                color: 'rgba(248,113,113,0.7)',
                fontSize: 18,
                padding: 4
              }}
              title="Logout"
            >
              ↩
            </button>
          </div>
        </div>
      )}
    </>
  )
}

