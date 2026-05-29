import Modal from './Modal'

const headerStyle = {
  display: 'flex',
  alignItems: 'center',
  gap: 14,
  padding: '24px 24px 0',
}

const titleStyle = {
  margin: 0,
  color: '#e0f7ff',
  fontSize: 20,
  fontWeight: 700,
}

const messageStyle = {
  margin: '12px 0 0',
  color: 'rgba(226, 241, 255, 0.82)',
  fontSize: 15,
  lineHeight: 1.65,
}

const actionsStyle = {
  display: 'flex',
  justifyContent: 'flex-end',
  gap: 12,
  padding: '24px',
  borderTop: '1px solid rgba(103, 232, 249, 0.12)',
}

const buttonStyle = {
  minWidth: 120,
  borderRadius: 12,
  padding: '12px 18px',
  fontSize: 14,
  fontWeight: 600,
  cursor: 'pointer',
  fontFamily: 'inherit',
  border: '1px solid transparent',
}

const iconMap = {
  warning: '⚠️',
  error: '❌',
  success: '✅',
  info: 'ℹ️',
}

export default function ConfirmModal({
  open,
  title = 'Confirm action',
  message,
  type = 'warning',
  confirmLabel = 'Confirm',
  cancelLabel = 'Cancel',
  confirmLoading = false,
  onConfirm,
  onCancel,
}) {
  return (
    <Modal open={open} onClose={onCancel} titleId="confirm-modal-title" descriptionId="confirm-modal-description">
      <div style={headerStyle}>
        <div style={{
          width: 50,
          height: 50,
          borderRadius: 16,
          display: 'grid',
          placeItems: 'center',
          background: 'rgba(34, 211, 238, 0.12)',
          color: '#22d3ee',
          fontSize: 24,
        }}>
          {iconMap[type] || iconMap.info}
        </div>
        <div>
          <h2 id="confirm-modal-title" style={titleStyle}>{title}</h2>
          <p id="confirm-modal-description" style={messageStyle}>{message}</p>
        </div>
      </div>

      <div style={actionsStyle}>
        <button
          type="button"
          onClick={onCancel}
          style={{
            ...buttonStyle,
            background: 'rgba(255,255,255,0.06)',
            color: '#dbeafe',
            borderColor: 'rgba(255,255,255,0.08)',
          }}
          disabled={confirmLoading}
        >
          {cancelLabel}
        </button>
        <button
          type="button"
          onClick={onConfirm}
          style={{
            ...buttonStyle,
            background: 'linear-gradient(135deg, rgba(34, 211, 238, 0.2), rgba(59, 130, 246, 0.3))',
            color: '#22d3ee',
            borderColor: 'rgba(34, 211, 238, 0.45)',
          }}
          disabled={confirmLoading}
        >
          {confirmLoading ? 'Working…' : confirmLabel}
        </button>
      </div>
    </Modal>
  )
}
