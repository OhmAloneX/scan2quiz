import { useEffect, useRef } from 'react'

const overlayStyle = {
  position: 'fixed',
  inset: 0,
  zIndex: 1200,
  background: 'rgba(5, 12, 30, 0.78)',
  backdropFilter: 'blur(18px)',
  WebkitBackdropFilter: 'blur(18px)',
  display: 'flex',
  justifyContent: 'center',
  alignItems: 'center',
  padding: 20,
}

const panelStyle = {
  width: '100%',
  maxWidth: 560,
  background: 'rgba(10, 18, 36, 0.96)',
  border: '1px solid rgba(34, 211, 238, 0.18)',
  borderRadius: 24,
  boxShadow: '0 28px 96px rgba(0,0,0,0.35)',
  overflow: 'hidden',
  transform: 'translateY(0px) scale(1)',
  animation: 'modalFadeIn 220ms ease-out',
}

export default function Modal({ open, onClose, children, titleId, descriptionId, closeOnOverlay = true }) {
  const panelRef = useRef(null)

  useEffect(() => {
    if (!open) return undefined

    const previousOverflow = document.body.style.overflow
    document.body.style.overflow = 'hidden'

    const handleKeyDown = (event) => {
      if (event.key === 'Escape') {
        event.preventDefault()
        onClose?.()
      }
    }

    document.addEventListener('keydown', handleKeyDown)
    panelRef.current?.focus()

    return () => {
      document.body.style.overflow = previousOverflow
      document.removeEventListener('keydown', handleKeyDown)
    }
  }, [open, onClose])

  if (!open) return null

  return (
    <div
      role="dialog"
      aria-labelledby={titleId}
      aria-describedby={descriptionId}
      aria-modal="true"
      style={overlayStyle}
      onClick={() => closeOnOverlay && onClose?.()}
    >
      <div
        ref={panelRef}
        tabIndex={-1}
        style={panelStyle}
        onClick={(event) => event.stopPropagation()}
      >
        {children}
      </div>
    </div>
  )
}
