import { useState } from 'react'
import { getPasswordStrength } from '../../hooks/useValidation'

export default function FormInput({
  label,
  name,
  type        = 'text',
  value,
  placeholder = '',
  required    = false,
  error       = null,
  isValid     = false,
  onChange,
  onBlur,
  showStrength = false,  // password strength bar
  disabled    = false,
  hint        = null,    // helper text below input
  autoComplete,
}) {
  const [showPass, setShowPass] = useState(false)
  const isPassword = type === 'password'
  const inputType  = isPassword
    ? (showPass ? 'text' : 'password')
    : type

  const strength = showStrength && isPassword
    ? getPasswordStrength(value)
    : null

  const borderColor = error
    ? 'rgba(248,113,113,0.7)'
    : isValid
    ? 'rgba(74,222,128,0.6)'
    : 'rgba(103,232,249,0.25)'

  const boxShadow = error
    ? '0 0 0 3px rgba(248,113,113,0.1)'
    : isValid
    ? '0 0 0 3px rgba(74,222,128,0.1)'
    : 'none'

  const focusBorder = error
    ? 'rgba(248,113,113,0.8)'
    : 'rgba(34,211,238,0.7)'

  const focusShadow = error
    ? '0 0 0 3px rgba(248,113,113,0.12)'
    : '0 0 0 3px rgba(34,211,238,0.12)'

  return (
    <div style={{ display: 'flex', flexDirection: 'column' }}>
      {/* Label */}
      {label && (
        <label style={{
          display:      'block',
          fontSize:     12,
          fontWeight:   500,
          color:        'rgba(186,230,253,0.7)',
          marginBottom: 6
        }}>
          {label}
          {required && (
            <span style={{ color: '#f87171', marginLeft: 3 }}>*</span>
          )}
        </label>
      )}

      {/* Input wrapper */}
      <div style={{ position: 'relative' }}>
        <input
          name={name}
          type={inputType}
          value={value}
          placeholder={placeholder}
          disabled={disabled}
          autoComplete={autoComplete}
          onChange={e => onChange && onChange(e.target.value)}
          onBlur={e  => onBlur  && onBlur(e.target.value)}
          onFocus={e => {
            e.target.style.borderColor = focusBorder
            e.target.style.boxShadow   = focusShadow
          }}
          style={{
            width:        '100%',
            padding:      isPassword
              ? '12px 44px 12px 14px'
              : '12px 14px',
            background:   disabled
              ? 'rgba(255,255,255,0.03)'
              : 'rgba(255,255,255,0.06)',
            border:       `1px solid ${borderColor}`,
            borderRadius: 12,
            color:        disabled ? 'rgba(186,230,253,0.4)' : '#e0f7ff',
            fontSize:     14,
            outline:      'none',
            fontFamily:   'inherit',
            boxSizing:    'border-box',
            boxShadow,
            transition:   'border-color 0.2s, box-shadow 0.2s',
            cursor:       disabled ? 'not-allowed' : 'text'
          }}
        />

        {/* Right icon — show/hide password OR valid check */}
        {isPassword ? (
          <button
            type="button"
            onClick={() => setShowPass(s => !s)}
            style={{
              position:       'absolute',
              right:          12,
              top:            '50%',
              transform:      'translateY(-50%)',
              background:     'none',
              border:         'none',
              cursor:         'pointer',
              color:          'rgba(103,232,249,0.5)',
              padding:        4,
              display:        'flex',
              alignItems:     'center',
              justifyContent: 'center'
            }}>
            {showPass ? (
              // Eye off
              <svg width="16" height="16" viewBox="0 0 24 24"
                fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20
                  c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/>
                <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4
                  c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/>
                <line x1="1" y1="1" x2="23" y2="23"/>
              </svg>
            ) : (
              // Eye
              <svg width="16" height="16" viewBox="0 0 24 24"
                fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                <circle cx="12" cy="12" r="3"/>
              </svg>
            )}
          </button>
        ) : isValid ? (
          // Valid checkmark
          <div style={{
            position:       'absolute',
            right:          12,
            top:            '50%',
            transform:      'translateY(-50%)',
            color:          '#4ade80',
            display:        'flex',
            alignItems:     'center',
            justifyContent: 'center'
          }}>
            <svg width="16" height="16" viewBox="0 0 24 24"
              fill="none" stroke="currentColor" strokeWidth="2.5">
              <polyline points="20 6 9 17 4 12"/>
            </svg>
          </div>
        ) : null}
      </div>

      {/* Password strength bar */}
      {showStrength && strength && value && (
        <div style={{ marginTop: 8 }}>
          <div style={{
            height:       4,
            borderRadius: 2,
            background:   'rgba(255,255,255,0.08)',
            overflow:     'hidden'
          }}>
            <div style={{
              height:     '100%',
              borderRadius: 2,
              width:      strength.pct,
              background: strength.color,
              transition: 'width 0.3s, background 0.3s'
            }}/>
          </div>
          <div style={{
            display:        'flex',
            justifyContent: 'space-between',
            alignItems:     'center',
            marginTop:      4
          }}>
            <span style={{
              fontSize: 11,
              color:    strength.color
            }}>
              {strength.label} password
            </span>
            <span style={{
              fontSize: 10,
              color:    'rgba(186,230,253,0.35)'
            }}>
              {strength.score}/6
            </span>
          </div>
          {/* Password requirements checklist */}
          <div style={{
            marginTop:   8,
            display:     'flex',
            flexWrap:    'wrap',
            gap:         6
          }}>
            {[
              { test: value.length >= 8,      label: '8+ chars'   },
              { test: /[A-Z]/.test(value),    label: 'Uppercase'  },
              { test: /[a-z]/.test(value),    label: 'Lowercase'  },
              { test: /[0-9]/.test(value),    label: 'Number'     },
              { test: /[^A-Za-z0-9]/.test(value), label: 'Symbol' },
            ].map(req => (
              <span key={req.label} style={{
                fontSize:     10,
                padding:      '2px 8px',
                borderRadius: 20,
                background:   req.test
                  ? 'rgba(74,222,128,0.12)'
                  : 'rgba(255,255,255,0.05)',
                border: `1px solid ${req.test
                  ? 'rgba(74,222,128,0.3)'
                  : 'rgba(255,255,255,0.1)'}`,
                color: req.test
                  ? '#4ade80'
                  : 'rgba(186,230,253,0.35)',
                transition: 'all 0.2s'
              }}>
                {req.test ? '✓' : '○'} {req.label}
              </span>
            ))}
          </div>
        </div>
      )}

      {/* Error message */}
      {error && (
        <div style={{
          display:    'flex',
          alignItems: 'flex-start',
          gap:        5,
          marginTop:  5
        }}>
          <svg width="13" height="13" viewBox="0 0 24 24"
            fill="none" stroke="#f87171" strokeWidth="2.5"
            style={{ flexShrink: 0, marginTop: 1 }}>
            <circle cx="12" cy="12" r="10"/>
            <line x1="12" y1="8" x2="12" y2="12"/>
            <line x1="12" y1="16" x2="12.01" y2="16"/>
          </svg>
          <span style={{
            color:    '#f87171',
            fontSize: 12,
            lineHeight: 1.4
          }}>
            {error}
          </span>
        </div>
      )}

      {/* Valid message */}
      {isValid && !error && (
        <div style={{
          display:    'flex',
          alignItems: 'center',
          gap:        5,
          marginTop:  5
        }}>
          <svg width="12" height="12" viewBox="0 0 24 24"
            fill="none" stroke="#4ade80" strokeWidth="2.5">
            <polyline points="20 6 9 17 4 12"/>
          </svg>
          <span style={{ color: '#4ade80', fontSize: 12 }}>
            Looks good!
          </span>
        </div>
      )}

      {/* Hint text */}
      {hint && !error && (
        <p style={{
          color:    'rgba(186,230,253,0.35)',
          fontSize: 11,
          margin:   '5px 0 0'
        }}>
          {hint}
        </p>
      )}
    </div>
  )
}