import { createContext, useCallback, useContext, useMemo, useState } from 'react'
import ConfirmModal from './ConfirmModal'
import AlertModal from './AlertModal'
import Toast from './Toast'

const ModalContext = createContext(null)

export function ModalProvider({ children }) {
  const [modal, setModal] = useState(null)
  const [toasts, setToasts] = useState([])

  const closeModal = useCallback(() => {
    setModal(null)
  }, [])

  const openConfirmModal = useCallback((options) => {
    return new Promise((resolve) => {
      setModal({
        variant: 'confirm',
        ...options,
        onResolve: (confirmed) => {
          closeModal()
          resolve(confirmed)
        },
      })
    })
  }, [closeModal])

  const openAlertModal = useCallback((options) => {
    return new Promise((resolve) => {
      setModal({
        variant: 'alert',
        ...options,
        onClose: () => {
          closeModal()
          resolve(false)
        },
      })
    })
  }, [closeModal])

  const openSuccessModal = useCallback((options) => {
    return openAlertModal({ ...options, type: 'success' })
  }, [openAlertModal])

  const openToast = useCallback(({ type = 'info', title, message, duration = 3600 }) => {
    const id = Date.now() + Math.random()
    setToasts((current) => [...current, { id, type, title, message }])

    window.setTimeout(() => {
      setToasts((current) => current.filter((toast) => toast.id !== id))
    }, duration)
  }, [])

  const modalElement = useMemo(() => {
    if (!modal) return null

    if (modal.variant === 'confirm') {
      return (
        <ConfirmModal
          open={true}
          title={modal.title}
          message={modal.message}
          type={modal.type}
          confirmLabel={modal.confirmLabel}
          cancelLabel={modal.cancelLabel}
          confirmLoading={modal.confirmLoading}
          onConfirm={() => modal.onResolve?.(true)}
          onCancel={() => modal.onResolve?.(false)}
        />
      )
    }

    return (
      <AlertModal
        open={true}
        title={modal.title}
        message={modal.message}
        type={modal.type}
        buttonLabel={modal.buttonLabel}
        onClose={modal.onClose}
      />
    )
  }, [modal])

  const value = useMemo(() => ({
    openConfirmModal,
    openAlertModal,
    openSuccessModal,
    openToast,
    closeModal,
  }), [openAlertModal, openConfirmModal, openSuccessModal, openToast, closeModal])

  return (
    <ModalContext.Provider value={value}>
      {children}
      {modalElement}
      <Toast toasts={toasts} />
    </ModalContext.Provider>
  )
}

export function useModal() {
  const context = useContext(ModalContext)
  if (!context) {
    throw new Error('useModal must be used inside ModalProvider')
  }
  return context
}
