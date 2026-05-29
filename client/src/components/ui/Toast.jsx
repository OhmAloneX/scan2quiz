import { useEffect } from 'react'

const containerStyle = {
  position: 'fixed',
  right: 20,
  bottom: 20,
  zIndex: 1300,
  display: 'flex',
  flexDirection: 'column',
  gap: 12,
  maxWidth: 340,
}

const toastStyle = {
  background: 'rgba(10, 18, 36, 0.96)',
  border: '1px solid rgba(34, 211, 238, 0.18)',
  boxShadow: '0 18px 40px rgba(0,0,0,0.24)',
  borderRadius: 18,
  padding: '14px 16px',
  display: 'flex',
  alignItems: 'flex-start',
  gap: 12,
  color: '#f8fafc',
  animation: 'toastSlide 260ms ease-out',
}

const iconStyle = {
  width: 34,
  height: 34,
  borderRadius: 12,
  display: 'grid',
  placeItems: 'center',
  flexShrink: 0,
  fontSize: 18,
  background: 'rgba(59, 130, 246, 0.16)',
}

const messageStyle = {
  flex: 1,
  fontSize: 14,
  lineHeight: 1.6,
}

const titleStyle = {
  margin: 0,
  fontSize: 14,
  fontWeight: 700,
  color: '#e0f7ff',
}

const typeIcon = {
  success: '✅',
  error: '❌',
  warning: '⚠️',
  info: 'ℹ️',
}

export default function Toast({ toasts }) {
  return (
    <div style={containerStyle}>
      {toasts.map((toast) => (
        <div key={toast.id} style={toastStyle}>
          <div style={iconStyle}>{typeIcon[toast.type] || typeIcon.info}</div>
          <div style={messageStyle}>
            {toast.title && <p style={titleStyle}>{toast.title}</p>}
            <p style={{ margin: 0 }}>{toast.message}</p>
          </div>
        </div>
      ))}
    </div>
  )
}
