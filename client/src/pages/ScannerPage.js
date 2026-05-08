import { useState, useEffect, useRef } from 'react'
import Sidebar   from '../components/layout/Sidebar'
import GlassCard from '../components/ui/GlassCard'
import { handleScan } from '../services/sessionService'

const SCANNER_ID = 'scan2quiz-reader'

export default function ScannerPage() {
  const [mode,      setMode]      = useState('qr')
  const [scanning,  setScanning]  = useState(false)
  const [result,    setResult]    = useState(null)
  const [error,     setError]     = useState(null)
  const [loading,   setLoading]   = useState(false)
  const [manualVal, setManualVal] = useState('')
  const [history,   setHistory]   = useState([])
  const scannerRef  = useRef(null)
  const cooldownRef = useRef(false)

  // Cleanup on unmount
  useEffect(() => {
    return () => { stopScanner() }
  }, [])

  // Stop scanner when switching modes
  useEffect(() => {
    if (scanning) stopScanner()
  }, [mode])

  async function submitScan(value, type) {
    if (cooldownRef.current) return
    cooldownRef.current = true
    setLoading(true)
    setResult(null)
    setError(null)

    try {
      const res = await handleScan({ type, value })
      setResult(res.data)
      setHistory(prev => [{
        value, type,
        success: res.data.success,
        time: new Date().toLocaleTimeString()
      }, ...prev].slice(0, 10))
    } catch (err) {
      setResult({
        success: false,
        message: err.response?.data?.message || 'Scan failed'
      })
    } finally {
      setLoading(false)
      setTimeout(() => { cooldownRef.current = false }, 2500)
    }
  }

  async function startScanner() {
    setError(null)
    setResult(null)
    setScanning(true)

    try {
      const { Html5Qrcode } = await import('html5-qrcode')

      if (scannerRef.current) {
        try { await scannerRef.current.stop() } catch {}
        scannerRef.current = null
      }

      const html5QrCode = new Html5Qrcode(SCANNER_ID)
      scannerRef.current = html5QrCode

      const config = {
        fps: 12,
        qrbox: mode === 'qr'
          ? { width: 220, height: 220 }
          : { width: 300, height: 100 },
      }

      await html5QrCode.start(
        { facingMode: 'environment' },
        config,
        (decodedText) => {
          submitScan(
            decodedText,
            mode === 'qr' ? 'QR_CODE' : 'barcode'
          )
        },
        () => {}
      )
    } catch (err) {
      setScanning(false)
      if (err?.message?.includes('Permission')) {
        setError('camera_denied')
      } else if (err?.message?.includes('No cameras')) {
        setError('no_camera')
      } else {
        setError('generic')
      }
    }
  }

  async function stopScanner() {
    if (scannerRef.current) {
      try { await scannerRef.current.stop() } catch {}
      scannerRef.current = null
    }
    setScanning(false)
  }

  const errorMessages = {
    camera_denied: {
      title: 'Camera Access Denied',
      body:  'Allow camera permission in your browser then retry.',
      icon:  '🚫'
    },
    no_camera: {
      title: 'No Camera Found',
      body:  'No camera detected. Use manual entry below.',
      icon:  '📷'
    },
    generic: {
      title: 'Scanner Error',
      body:  'Make sure you are on localhost and using Chrome.',
      icon:  '⚠️'
    }
  }

  const btnStyle = (active) => ({
    display:        'flex',
    alignItems:     'center',
    justifyContent: 'center',
    gap:            8,
    flex:           1,
    padding:        '11px 16px',
    borderRadius:   18,
    border:         'none',
    cursor:         'pointer',
    background:     active
      ? 'linear-gradient(135deg,rgba(34,211,238,0.2),' +
        'rgba(99,102,241,0.16))'
      : 'transparent',
    boxShadow:  active
      ? '0 0 0 1px rgba(34,211,238,0.4)'
      : 'none',
    color:      active
      ? '#e0f7ff'
      : 'rgba(186,230,253,0.6)',
    fontSize:   14,
    fontWeight: active ? 600 : 400,
    fontFamily: 'inherit',
    transition: 'all 0.2s'
  })

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
          padding:        '16px 28px',
          background:     'rgba(255,255,255,0.03)',
          backdropFilter: 'blur(16px)',
          borderBottom:   '1px solid rgba(103,232,249,0.08)'
        }}>
          <h1 style={{
            color: '#e0f7ff', fontSize: 20,
            fontWeight: 600, margin: 0
          }}>
            Scanner
          </h1>
          <p style={{
            color: 'rgba(186,230,253,0.5)',
            fontSize: 13, margin: '2px 0 0'
          }}>
            Scan QR codes and student ID barcodes
          </p>
        </div>

        <div style={{
          padding:   '24px 28px',
          maxWidth:  580,
          margin:    '0 auto'
        }}>

          {/* Mode tabs */}
          <GlassCard style={{ padding: 6, marginBottom: 20 }}>
            <div style={{ display: 'flex', gap: 4 }}>
              <button
                style={btnStyle(mode === 'qr')}
                onClick={() => setMode('qr')}
              >
                🔳 QR Code
              </button>
              <button
                style={btnStyle(mode === 'barcode')}
                onClick={() => setMode('barcode')}
              >
                📋 Barcode
              </button>
            </div>
          </GlassCard>

          {/* Scanner card */}
          <GlassCard glow style={{
            padding: 0, overflow: 'hidden',
            marginBottom: 20
          }}>
            {/* Header */}
            <div style={{
              padding:        '18px 22px 0',
              display:        'flex',
              justifyContent: 'space-between',
              alignItems:     'center'
            }}>
              <div>
                <p style={{
                  color:         'rgba(186,230,253,0.55)',
                  fontSize:      11,
                  margin:        '0 0 2px',
                  textTransform: 'uppercase',
                  letterSpacing: '0.8px'
                }}>
                  {mode === 'qr' ? 'QR Code' : 'Barcode'} Scanner
                </p>
                <h2 style={{
                  color: '#e0f7ff', fontSize: 15,
                  fontWeight: 600, margin: 0
                }}>
                  {mode === 'qr'
                    ? 'Scan QR for Quiz Session'
                    : 'Scan Student ID Barcode'}
                </h2>
              </div>
              {scanning && (
                <div style={{
                  display:      'flex',
                  alignItems:   'center',
                  gap:          6,
                  background:   'rgba(34,211,238,0.1)',
                  border:       '1px solid rgba(34,211,238,0.25)',
                  borderRadius: 20,
                  padding:      '4px 12px'
                }}>
                  <div style={{
                    width:        7,
                    height:       7,
                    borderRadius: '50%',
                    background:   '#22d3ee',
                    boxShadow:    '0 0 6px #22d3ee'
                  }}/>
                  <span style={{
                    fontSize: 11,
                    color:    '#22d3ee',
                    fontWeight: 600
                  }}>
                    Live
                  </span>
                </div>
              )}
            </div>

            {/* Camera viewport */}
            <div style={{ padding: '16px 22px' }}>
              <div style={{
                position:     'relative',
                borderRadius: 16,
                overflow:     'hidden',
                background:   'rgba(0,0,0,0.4)',
                border:       '1px solid rgba(103,232,249,0.2)',
                minHeight:    scanning ? 280 : 0
              }}>
                <div id={SCANNER_ID} style={{ width: '100%' }} />

                {/* Idle state */}
                {!scanning && !error && (
                  <div style={{
                    padding:        '32px 24px',
                    textAlign:      'center'
                  }}>
                    <div style={{
                      width:          64,
                      height:         64,
                      borderRadius:   '50%',
                      background:     'rgba(34,211,238,0.08)',
                      border:         '1px solid rgba(34,211,238,0.2)',
                      display:        'flex',
                      alignItems:     'center',
                      justifyContent: 'center',
                      margin:         '0 auto 14px',
                      fontSize:       28
                    }}>
                      {mode === 'qr' ? '🔳' : '📋'}
                    </div>
                    <p style={{
                      color: '#e0f7ff', fontSize: 14,
                      fontWeight: 500, margin: '0 0 6px'
                    }}>
                      {mode === 'qr'
                        ? 'Ready to scan QR code'
                        : 'Ready to scan barcode'}
                    </p>
                    <p style={{
                      color: 'rgba(186,230,253,0.4)',
                      fontSize: 12, margin: 0
                    }}>
                      Click Start Scanner to activate camera
                    </p>
                  </div>
                )}
              </div>
            </div>

            {/* Error display */}
            {error && (() => {
              const e = errorMessages[error]
              return (
                <div style={{
                  margin:     '0 22px 16px',
                  padding:    16,
                  background: 'rgba(248,113,113,0.08)',
                  border:     '1px solid rgba(248,113,113,0.25)',
                  borderRadius: 14,
                  display:    'flex',
                  gap:        12,
                  alignItems: 'flex-start'
                }}>
                  <span style={{ fontSize: 20 }}>{e.icon}</span>
                  <div>
                    <p style={{
                      color: '#f87171', fontSize: 13,
                      fontWeight: 600, margin: '0 0 3px'
                    }}>
                      {e.title}
                    </p>
                    <p style={{
                      color: 'rgba(186,230,253,0.5)',
                      fontSize: 12, margin: 0
                    }}>
                      {e.body}
                    </p>
                  </div>
                </div>
              )
            })()}

            {/* Action buttons */}
            <div style={{
              padding: '0 22px 22px',
              display: 'flex', gap: 10
            }}>
              {!scanning ? (
                <button onClick={startScanner} style={{
                  flex:         1,
                  padding:      14,
                  borderRadius: 14,
                  background:   'linear-gradient(135deg,' +
                    'rgba(34,211,238,0.2),rgba(99,102,241,0.18))',
                  border:       '1px solid rgba(34,211,238,0.45)',
                  color:        '#22d3ee',
                  fontSize:     15,
                  fontWeight:   600,
                  cursor:       'pointer',
                  fontFamily:   'inherit'
                }}>
                  📷 {error ? 'Retry Camera' : 'Start Scanner'}
                </button>
              ) : (
                <button onClick={stopScanner} style={{
                  flex:         1,
                  padding:      14,
                  borderRadius: 14,
                  background:   'rgba(248,113,113,0.1)',
                  border:       '1px solid rgba(248,113,113,0.35)',
                  color:        '#f87171',
                  fontSize:     15,
                  fontWeight:   600,
                  cursor:       'pointer',
                  fontFamily:   'inherit'
                }}>
                  ⏹ Stop Scanner
                </button>
              )}
            </div>
          </GlassCard>

          {/* Result banner */}
          {(result || loading) && (
            <GlassCard style={{ marginBottom: 20 }}>
              {loading ? (
                <div style={{
                  display:    'flex',
                  alignItems: 'center',
                  gap:        12
                }}>
                  <div style={{
                    width:        18,
                    height:       18,
                    border:       '2px solid rgba(34,211,238,0.2)',
                    borderTop:    '2px solid #22d3ee',
                    borderRadius: '50%',
                    animation:    'spin 0.75s linear infinite'
                  }}/>
                  <p style={{
                    color: 'rgba(186,230,253,0.6)',
                    fontSize: 14, margin: 0
                  }}>
                    Verifying with server...
                  </p>
                </div>
              ) : (
                <div style={{
                  display:    'flex',
                  alignItems: 'flex-start',
                  gap:        12
                }}>
                  <span style={{ fontSize: 20 }}>
                    {result?.success ? '✅' : '❌'}
                  </span>
                  <div style={{ flex: 1 }}>
                    <p style={{
                      color:      result?.success
                        ? '#4ade80' : '#f87171',
                      fontSize:   14,
                      fontWeight: 600,
                      margin:     '0 0 4px'
                    }}>
                      {result?.success
                        ? 'Scan Successful'
                        : 'Scan Failed'}
                    </p>
                    <p style={{
                      color: 'rgba(186,230,253,0.6)',
                      fontSize: 12, margin: 0
                    }}>
                      {result?.message}
                    </p>

                    {/* Student info */}
                    {result?.student && (
                      <div style={{
                        marginTop:    10,
                        padding:      '10px 14px',
                        background:   'rgba(34,211,238,0.06)',
                        border:       '1px solid rgba(34,211,238,0.2)',
                        borderRadius: 10
                      }}>
                        <p style={{
                          color: '#e0f7ff', fontSize: 14,
                          fontWeight: 600, margin: '0 0 2px'
                        }}>
                          {result.student.name}
                        </p>
                        <p style={{
                          color: 'rgba(186,230,253,0.5)',
                          fontSize: 12, margin: 0
                        }}>
                          {result.student.student_id} ·{' '}
                          {result.student.section}
                        </p>
                      </div>
                    )}

                    {/* Session info */}
                    {result?.session && (
                      <div style={{
                        marginTop:    10,
                        padding:      '10px 14px',
                        background:   'rgba(99,102,241,0.06)',
                        border:       '1px solid rgba(99,102,241,0.2)',
                        borderRadius: 10
                      }}>
                        <p style={{
                          color: '#e0f7ff', fontSize: 14,
                          fontWeight: 600, margin: '0 0 2px'
                        }}>
                          {result.session.quiz_title}
                        </p>
                        <p style={{
                          color: 'rgba(186,230,253,0.5)',
                          fontSize: 12, margin: 0
                        }}>
                          Code: {result.session.session_code} ·{' '}
                          Status: {result.session.status}
                        </p>
                      </div>
                    )}
                  </div>
                  <button
                    onClick={() => setResult(null)}
                    style={{
                      background: 'none',
                      border:     'none',
                      cursor:     'pointer',
                      color:      'rgba(186,230,253,0.4)',
                      fontSize:   16,
                      padding:    4
                    }}>
                    ✕
                  </button>
                </div>
              )}
            </GlassCard>
          )}

          {/* Manual entry */}
          <GlassCard style={{ marginBottom: 20 }}>
            <p style={{
              color:         'rgba(186,230,253,0.55)',
              fontSize:      11,
              margin:        '0 0 12px',
              textTransform: 'uppercase',
              letterSpacing: '0.8px'
            }}>
              Manual Entry
            </p>
            <div style={{ display: 'flex', gap: 10 }}>
              <input
                type="text"
                placeholder={mode === 'qr'
                  ? 'Paste QR token...'
                  : 'Type student barcode...'}
                value={manualVal}
                onChange={e => setManualVal(e.target.value)}
                onKeyDown={e => {
                  if (e.key === 'Enter' && manualVal.trim()) {
                    submitScan(
                      manualVal.trim(),
                      mode === 'qr' ? 'QR_CODE' : 'barcode'
                    )
                    setManualVal('')
                  }
                }}
                style={{
                  flex:         1,
                  padding:      '11px 14px',
                  background:   'rgba(255,255,255,0.05)',
                  border:       '1px solid rgba(103,232,249,0.2)',
                  borderRadius: 12,
                  color:        '#e0f7ff',
                  fontSize:     13,
                  outline:      'none',
                  fontFamily:   'inherit'
                }}
              />
              <button
                onClick={() => {
                  if (manualVal.trim()) {
                    submitScan(
                      manualVal.trim(),
                      mode === 'qr' ? 'QR_CODE' : 'barcode'
                    )
                    setManualVal('')
                  }
                }}
                disabled={!manualVal.trim() || loading}
                style={{
                  padding:      '11px 20px',
                  borderRadius: 12,
                  background:   manualVal.trim()
                    ? 'rgba(34,211,238,0.15)'
                    : 'rgba(255,255,255,0.04)',
                  border: `1px solid ${manualVal.trim()
                    ? 'rgba(34,211,238,0.4)'
                    : 'rgba(103,232,249,0.15)'}`,
                  color:      manualVal.trim()
                    ? '#22d3ee'
                    : 'rgba(186,230,253,0.3)',
                  fontSize:   13,
                  fontWeight: 600,
                  cursor:     manualVal.trim()
                    ? 'pointer' : 'default',
                  fontFamily: 'inherit'
                }}>
                Submit
              </button>
            </div>
            <p style={{
              color: 'rgba(186,230,253,0.3)',
              fontSize: 11, margin: '8px 0 0'
            }}>
              Press Enter or click Submit · Works without camera
            </p>
          </GlassCard>

          {/* Scan history */}
          {history.length > 0 && (
            <GlassCard>
              <div style={{
                display:        'flex',
                justifyContent: 'space-between',
                alignItems:     'center',
                marginBottom:   14
              }}>
                <p style={{
                  color:         'rgba(186,230,253,0.55)',
                  fontSize:      11,
                  margin:        0,
                  textTransform: 'uppercase',
                  letterSpacing: '0.8px'
                }}>
                  Scan History
                </p>
                <button
                  onClick={() => setHistory([])}
                  style={{
                    background: 'none',
                    border:     'none',
                    color:      'rgba(186,230,253,0.4)',
                    fontSize:   11,
                    cursor:     'pointer',
                    fontFamily: 'inherit'
                  }}>
                  Clear
                </button>
              </div>
              <div style={{
                display:       'flex',
                flexDirection: 'column',
                gap:           8
              }}>
                {history.map((item, i) => (
                  <div key={i} style={{
                    display:      'flex',
                    alignItems:   'center',
                    gap:          10,
                    padding:      '9px 12px',
                    background:   'rgba(255,255,255,0.03)',
                    borderRadius: 10,
                    border:       '1px solid rgba(103,232,249,0.1)'
                  }}>
                    <div style={{
                      width:        8,
                      height:       8,
                      borderRadius: '50%',
                      flexShrink:   0,
                      background:   item.success
                        ? '#4ade80' : '#f87171'
                    }}/>
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <p style={{
                        color:        '#e0f7ff',
                        fontSize:     12,
                        fontWeight:   500,
                        margin:       0,
                        overflow:     'hidden',
                        textOverflow: 'ellipsis',
                        whiteSpace:   'nowrap'
                      }}>
                        {item.value}
                      </p>
                      <p style={{
                        color:    'rgba(186,230,253,0.4)',
                        fontSize: 10,
                        margin:   '2px 0 0'
                      }}>
                        {item.type} · {item.time}
                      </p>
                    </div>
                    <span style={{
                      fontSize:   10,
                      fontWeight: 600,
                      color:      item.success
                        ? '#4ade80' : '#f87171',
                      flexShrink: 0
                    }}>
                      {item.success ? '✓ OK' : '✗ Fail'}
                    </span>
                  </div>
                ))}
              </div>
            </GlassCard>
          )}
        </div>
      </div>

      <style>{`
        @keyframes spin {
          to { transform: rotate(360deg) }
        }
        #${SCANNER_ID} video {
          border-radius: 12px !important;
        }
        #${SCANNER_ID} > div:last-child {
          display: none !important;
        }
      `}</style>
    </div>
  )
}