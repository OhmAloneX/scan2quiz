import { useNavigate, useLocation } from 'react-router-dom'
import { useAuth } from '../../context/AuthContext'

const NAV = [
  { path: '/dashboard',  label: 'Dashboard'},
  { path: '/quizzes',    label: 'Quizzes'},
  { path: '/sessions',   label: 'Sessions'},
  { path: '/scanner',    label: 'Scanner'},
  { path: '/analytics',  label: 'Analytics'},
  { path: '/students',   label: 'Students'},
]

export default function Sidebar() {
  const navigate  = useNavigate()
  const location  = useLocation()
  const { logout, user } = useAuth()

  return (
    <div style={{
      width:            220,
      flexShrink:       0,
      background:       'rgba(255,255,255,0.04)',
      backdropFilter:   'blur(24px)',
      borderRight:      '1px solid rgba(103,232,249,0.1)',
      display:          'flex',
      flexDirection:    'column',
      padding:          '20px 10px',
      minHeight:        '100vh'
    }}>
      {/* Logo */}
      <div style={{
        display:       'flex',
        alignItems:    'center',
        gap:           10,
        padding:       '0 8px 20px',
        borderBottom:  '1px solid rgba(103,232,249,0.1)',
        marginBottom:  16
      }}>
        <div style={{
          width:        36,
          height:       36,
          borderRadius: 10,
          background:   'linear-gradient(135deg,#22d3ee,#6366f1)',
          display:      'flex',
          alignItems:   'center',
          justifyContent: 'center',
          fontWeight:   700,
          color:        '#0f172a',
          fontSize:     16,
          boxShadow:    '0 0 14px rgba(34,211,238,0.35)'
        }}>S</div>
        <span style={{
          fontFamily: 'monospace',
          fontSize:   17,
          fontWeight: 700,
          color:      '#e0f7ff'
        }}>
          Scan<span style={{ color: '#22d3ee' }}>2</span>Quiz
        </span>
      </div>

      {/* Nav items */}
      <nav style={{
        display:       'flex',
        flexDirection: 'column',
        gap:           4,
        flex:          1
      }}>
        {NAV.map(({ path, label, icon }) => {
          const active = location.pathname === path
          return (
            <button key={path}
              onClick={() => navigate(path)}
              style={{
                display:    'flex',
                alignItems: 'center',
                gap:        12,
                padding:    '10px 14px',
                borderRadius: 12,
                border:     'none',
                cursor:     'pointer',
                background: active
                  ? 'linear-gradient(135deg,rgba(34,211,238,0.2),' +
                    'rgba(99,102,241,0.16))'
                  : 'transparent',
                boxShadow:  active
                  ? '0 0 0 1px rgba(34,211,238,0.35)'
                  : 'none',
                color:      active
                  ? '#e0f7ff'
                  : 'rgba(186,230,253,0.6)',
                fontSize:   14,
                fontWeight: active ? 500 : 400,
                textAlign:  'left',
                width:      '100%'
              }}>
              <span style={{ fontSize: 16 }}>{icon}</span>
              <span>{label}</span>
              {active && (
                <div style={{
                  marginLeft:   'auto',
                  width:        6,
                  height:       6,
                  borderRadius: '50%',
                  background:   '#22d3ee',
                  boxShadow:    '0 0 6px #22d3ee'
                }}/>
              )}
            </button>
          )
        })}
      </nav>

      {/* User + logout */}
      <div style={{
        borderTop:  '1px solid rgba(103,232,249,0.1)',
        paddingTop: 14,
        display:    'flex',
        alignItems: 'center',
        gap:        10
      }}>
        <div style={{
          width:          34,
          height:         34,
          borderRadius:   '50%',
          background:     'linear-gradient(135deg,#22d3ee,#6366f1)',
          display:        'flex',
          alignItems:     'center',
          justifyContent: 'center',
          fontSize:       13,
          fontWeight:     700,
          color:          '#0f172a',
          flexShrink:     0
        }}>
          {user?.email?.[0]?.toUpperCase() || 'A'}
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <p style={{
            color:     '#e0f7ff',
            fontSize:  12,
            fontWeight: 500,
            margin:    0,
            overflow:  'hidden',
            textOverflow: 'ellipsis',
            whiteSpace: 'nowrap'
          }}>
            {user?.role || 'Teacher'}
          </p>
        </div>
        <button onClick={logout} style={{
          background: 'none',
          border:     'none',
          cursor:     'pointer',
          color:      'rgba(248,113,113,0.7)',
          fontSize:   18,
          padding:    4
        }} title="Logout">
          ↩
        </button>
      </div>
    </div>
  )
}