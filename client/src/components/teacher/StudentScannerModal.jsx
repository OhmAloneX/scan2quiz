import { useEffect, useMemo, useRef, useState } from 'react'
import GlassCard from '../ui/GlassCard'
import { handleScan, fetchParticipants } from '../../services/sessionService'

const SCANNER_ID = 's2q-teacher-scanner'

export default function StudentScannerModal({
  open,
  onClose,
  sessionId,
  sessionCode,
  onStudentAdded,
}) {
  const [mode] = useState('barcode')
  const [scanning, setScanning] = useState(false)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [participantsRefreshTick, setParticipantsRefreshTick] = useState(0)

  const scannerRef = useRef(null)
  const cooldownRef = useRef(false)

  const derivedSessionCode = useMemo(() => sessionCode || '', [sessionCode])

  useEffect(() => {
    if (!open) return
    // reset state when opening
    setError('')
    setLoading(false)
    setScanning(false)
    return () => {
      // best-effort stop on close/unmount
      stopScanner()
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open])

  async function stopScanner() {
    if (scannerRef.current) {
      try {
        await scannerRef.current.stop()
      } catch {}
      scannerRef.current = null
    }
    setScanning(false)
  }

  async function submitStudentScan(value) {
    if (cooldownRef.current) return
    cooldownRef.current = true
    setLoading(true)
    setError('')

    try {
      const payload = {
        type: 'barcode',
        value,
      }

      // Backend supports either sessionId or sessionCode for barcode scan.
      if (sessionId) payload.sessionId = sessionId
      if (!sessionId && derivedSessionCode) payload.sessionCode = derivedSessionCode
      if (!sessionId && !derivedSessionCode) {
        throw new Error('Missing sessionId/sessionCode')
      }

      // register attendance
      const res = await handleScan(payload)

      // refresh participants (optimistic)
      setParticipantsRefreshTick((t) => t + 1)
      if (typeof onStudentAdded === 'function') {
        onStudentAdded(res.data?.participants)
      } else if (sessionId) {
        const pr = await fetchParticipants(sessionId)
        if (Array.isArray(pr.data?.students)) {
          // no-op; handled by polling elsewhere
        }
      }

      setLoading(false)
      // keep scanner live; allow next scan
    } catch (err) {
      const msg = err?.response?.data?.message || err?.message || 'Scan failed'
      setError(msg)
      setLoading(false)
    } finally {
      setTimeout(() => {
        cooldownRef.current = false
      }, 2500)
    }
  }

  async function startScanner() {
    setError('')
    setLoading(false)
    setScanning(true)

    try {
      const { Html5Qrcode } = await import('html5-qrcode')

      if (scannerRef.current) {
        try {
          await scannerRef.current.stop()
        } catch {}
        scannerRef.current = null
      }

      const html5QrCode = new Html5Qrcode(SCANNER_ID)
      scannerRef.current = html5QrCode

      const config = {
        fps: 12,
        qrbox: { width: 300, height: 100 },
      }

      await html5QrCode.start(
        { facingMode: 'environment' },
        config,
        (decodedText) => submitStudentScan(decodedText),
        () => {}
      )
    } catch (err) {
      setScanning(false)
      if (err?.message?.includes('Permission')) setError('Camera access denied')
      else if (err?.message?.includes('No cameras')) setError('No camera found')
      else setError('Scanner error')
    }
  }

  if (!open) return null

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        background: 'rgba(0,0,0,0.7)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 200,
        backdropFilter: 'blur(4px)',
        padding: 16,
      }}
      onMouseDown={(e) => {
        // click outside to close
        if (e.target === e.currentTarget) onClose?.()
      }}
    >
      <div style={{ width: '100%', maxWidth: 560 }}>
        <GlassCard
          glow
          style={{
            padding: 0,
            overflow: 'hidden',
            borderRadius: 24,
          }}
        >
          <div
            style={{
              padding: '18px 22px 0',
              display: 'flex',
              alignItems: 'flex-start',
              justifyContent: 'space-between',
              gap: 12,
            }}
          >
            <div>
              <p
                style={{
                  color: 'rgba(186,230,253,0.55)',
                  fontSize: 11,
                  margin: '0 0 2px',
                  textTransform: 'uppercase',
                  letterSpacing: '0.8px',
                }}
              >
                Teacher Attendance Scanner
              </p>
              <h2
                style={{
                  color: '#e0f7ff',
                  fontSize: 15,
                  fontWeight: 600,
                  margin: 0,
                }}
              >
                Scan Student ID (Barcode)
              </h2>
              <div style={{ marginTop: 10, display: 'flex', gap: 10, flexWrap: 'wrap' }}>
                <span
                  style={{
                    fontSize: 11,
                    padding: '3px 10px',
                    borderRadius: 20,
                    background: 'rgba(34,211,238,0.08)',
                    border: '1px solid rgba(34,211,238,0.2)',
                    color: '#22d3ee',
                    fontWeight: 700,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  }}
                >
                  {sessionCode || '—'}
                </span>
              </div>
            </div>

            <button
              onClick={() => onClose?.()}
              style={{
                background: 'transparent',
                border: 'none',
                color: 'rgba(186,230,253,0.5)',
                cursor: 'pointer',
                fontSize: 18,
                padding: 4,
              }}
              aria-label="Close"
            >
              ✕
            </button>
          </div>

          <div style={{ padding: 22 }}>
            <div
              style={{
                position: 'relative',
                borderRadius: 16,
                overflow: 'hidden',
                background: 'rgba(0,0,0,0.4)',
                border: '1px solid rgba(103,232,249,0.2)',
                minHeight: 240,
                width: '100%',
              }}
            >
              <div id={SCANNER_ID} style={{ width: '100%' }} />

              {!scanning && (
                <div style={{ padding: '36px 24px', textAlign: 'center' }}>
                  <div
                    style={{
                      width: 64,
                      height: 64,
                      borderRadius: '50%',
                      background: 'rgba(34,211,238,0.08)',
                      border: '1px solid rgba(34,211,238,0.2)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      margin: '0 auto 14px',
                      fontSize: 28,
                    }}
                  >
                    📋
                  </div>
                  <p style={{ color: '#e0f7ff', fontSize: 14, fontWeight: 500, margin: '0 0 6px' }}>
                    Ready to scan student ID
                  </p>
                  <p style={{ color: 'rgba(186,230,253,0.4)', fontSize: 12, margin: 0 }}>
                    Click Start Scanner to activate camera
                  </p>
                </div>
              )}
            </div>

            {error && (
              <div
                style={{
                  marginTop: 14,
                  padding: 14,
                  background: 'rgba(248,113,113,0.08)',
                  border: '1px solid rgba(248,113,113,0.25)',
                  borderRadius: 14,
                  color: '#f87171',
                  fontSize: 13,
                  fontWeight: 600,
                }}
              >
                {error}
              </div>
            )}

            <div
              style={{
                marginTop: 16,
                display: 'flex',
                gap: 10,
                flexDirection: 'row',
              }}
            >
              {!scanning ? (
                <button
                  onClick={startScanner}
                  disabled={!sessionId && !derivedSessionCode}
                  style={{
                    flex: 1,
                    padding: 14,
                    borderRadius: 14,
                    background:
                      'linear-gradient(135deg,rgba(34,211,238,0.2),rgba(99,102,241,0.18))',
                    border: '1px solid rgba(34,211,238,0.45)',
                    color: '#22d3ee',
                    fontSize: 15,
                    fontWeight: 700,
                    cursor: 'pointer',
                    fontFamily: 'inherit',
                  }}
                >
                  📷 {loading ? 'Starting...' : 'Start Scanner'}
                </button>
              ) : (
                <button
                  onClick={stopScanner}
                  style={{
                    flex: 1,
                    padding: 14,
                    borderRadius: 14,
                    background: 'rgba(248,113,113,0.1)',
                    border: '1px solid rgba(248,113,113,0.35)',
                    color: '#f87171',
                    fontSize: 15,
                    fontWeight: 700,
                    cursor: 'pointer',
                    fontFamily: 'inherit',
                  }}
                >
                  ⏹ Stop Scanner
                </button>
              )}

              <button
                onClick={() => {
                  // soft refresh hint for UI listeners
                  setParticipantsRefreshTick((t) => t + 1)
                  onClose?.()
                }}
                style={{
                  padding: '14px 16px',
                  borderRadius: 14,
                  background: 'transparent',
                  border: '1px solid rgba(103,232,249,0.2)',
                  color: 'rgba(186,230,253,0.6)',
                  fontSize: 14,
                  fontWeight: 600,
                  cursor: 'pointer',
                  fontFamily: 'inherit',
                }}
              >
                Done
              </button>
            </div>
          </div>
        </GlassCard>

        <style>{`
          #${SCANNER_ID} video { border-radius: 12px !important; }
          #${SCANNER_ID} > div:last-child { display: none !important; }
        `}</style>
      </div>
    </div>
  )
}

