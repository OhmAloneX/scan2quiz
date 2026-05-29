import Modal from './Modal'

const contentInner = {
  padding: 24,
}

const headingStyle = {
  margin: 0,
  color: '#e0f7ff',
  fontSize: 20,
  fontWeight: 700,
}

const messageStyle = {
  margin: '14px 0 0',
  color: 'rgba(226,241,255,0.82)',
  fontSize: 15,
  lineHeight: 1.7,
}

const buttonStyle = {
  marginTop: 24,
  width: '100%',
  minWidth: 120,
  borderRadius: 12,
  padding: '12px 18px',
  border: 'none',
  cursor: 'pointer',
  fontSize: 14,
  fontWeight: 600,
  fontFamily: 'inherit',
}

const iconStyle = {
  width: 50,
  height: 50,
  borderRadius: 16,
  display: 'grid',
  placeItems: 'center',
  marginBottom: 16,
  background: 'rgba(34, 211, 238, 0.12)',
  color: '#22d3ee',
  fontSize: 24,
}

const iconMap = {
  success: '✅',
  error: '❌',
  warning: '⚠️',
  info: 'ℹ️',
}

export default function AlertModal({
  open,
  title = 'Notification',
  message,
  type = 'info',
  buttonLabel = 'OK',
  onClose,
}) {
  return (
    <Modal open={open} onClose={onClose} titleId="alert-modal-title" descriptionId="alert-modal-description">
      <div style={contentInner}>
        <div style={iconStyle}>{iconMap[type] ?? iconMap.info}</div>
        <h2 id="alert-modal-title" style={headingStyle}>{title}</h2>
        <p id="alert-modal-description" style={messageStyle}>{message}</p>
        <button
          type="button"
          onClick={onClose}
          style={{
            ...buttonStyle,
            background: 'linear-gradient(135deg, rgba(34, 211, 238, 0.2), rgba(59, 130, 246, 0.28))',
            color: '#22d3ee',
            border: '1px solid rgba(34, 211, 238, 0.45)',
          }}
        >
          {buttonLabel}
        </button>
      </div>
    </Modal>
  )
}
