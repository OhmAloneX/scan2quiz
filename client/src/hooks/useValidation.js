import { useState, useCallback } from 'react'

// ── Validation rules library ───────────────────────────
export const rules = {

  required: (label = 'This field') => ({
    test:    v => v?.trim().length > 0,
    message: `${label} is required`
  }),

  minLength: (min, label = 'This field') => ({
    test:    v => v?.trim().length >= min,
    message: `${label} must be at least ${min} characters`
  }),

  maxLength: (max, label = 'This field') => ({
    test:    v => v?.trim().length <= max,
    message: `${label} must not exceed ${max} characters`
  }),

  email: () => ({
    test:    v => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v),
    message: 'Please enter a valid email address'
  }),

  password: () => ({
    test: v =>
      v?.length >= 8 &&
      /[A-Z]/.test(v) &&
      /[a-z]/.test(v) &&
      /[0-9]/.test(v),
    message:
      'Password must be at least 8 characters and include ' +
      'uppercase, lowercase, and a number'
  }),

  passwordSimple: () => ({
    test:    v => v?.length >= 8,
    message: 'Password must be at least 8 characters'
  }),

  match: (otherValue, label = 'Fields') => ({
    test:    v => v === otherValue,
    message: `${label} do not match`
  }),

  noSpaces: () => ({
    test:    v => !/\s/.test(v),
    message: 'No spaces allowed'
  }),

  alphanumeric: (label = 'This field') => ({
    test:    v => /^[a-zA-Z0-9\-_]+$/.test(v),
    message: `${label} can only contain letters, numbers, hyphens and underscores`
  }),

  numeric: (label = 'This field') => ({
    test:    v => !isNaN(+v) && v?.trim().length > 0,
    message: `${label} must be a number`
  }),

  positiveNumber: (label = 'This field') => ({
    test:    v => !isNaN(+v) && +v > 0,
    message: `${label} must be a positive number`
  }),

  range: (min, max, label = 'This field') => ({
    test:    v => !isNaN(+v) && +v >= min && +v <= max,
    message: `${label} must be between ${min} and ${max}`
  }),

}

// ── Password strength calculator ───────────────────────
export function getPasswordStrength(password) {
  if (!password) return { score: 0, label: '', color: '' }

  let score = 0
  if (password.length >= 8)  score++
  if (password.length >= 12) score++
  if (/[A-Z]/.test(password)) score++
  if (/[a-z]/.test(password)) score++
  if (/[0-9]/.test(password)) score++
  if (/[^A-Za-z0-9]/.test(password)) score++

  if (score <= 2) return { score, label: 'Weak',   color: '#f87171', pct: '25%'  }
  if (score <= 3) return { score, label: 'Fair',   color: '#fbbf24', pct: '50%'  }
  if (score <= 4) return { score, label: 'Good',   color: '#34d399', pct: '75%'  }
  return               { score, label: 'Strong', color: '#4ade80', pct: '100%' }
}

// ── Main validation hook ───────────────────────────────
export function useValidation(schema) {
  /*
    schema = {
      fieldName: [rule1, rule2, ...]
    }
  */
  const [touched,  setTouched]  = useState({})
  const [errors,   setErrors]   = useState({})

  // Validate a single field
  const validateField = useCallback((name, value) => {
    const fieldRules = schema[name] || []
    for (const rule of fieldRules) {
      if (!rule.test(value)) {
        return rule.message
      }
    }
    return null
  }, [schema])

  // Validate all fields at once
  const validateAll = useCallback((values) => {
    const newErrors = {}
    let valid = true

    for (const name of Object.keys(schema)) {
      const error = validateField(name, values[name] || '')
      if (error) {
        newErrors[name] = error
        valid = false
      }
    }

    setErrors(newErrors)
    // Mark all as touched on submit
    const allTouched = Object.fromEntries(
      Object.keys(schema).map(k => [k, true])
    )
    setTouched(allTouched)
    return valid
  }, [schema, validateField])

  // Handle blur — validate on leave
  const handleBlur = useCallback((name, value) => {
    setTouched(prev => ({ ...prev, [name]: true }))
    const error = validateField(name, value || '')
    setErrors(prev => ({ ...prev, [name]: error }))
  }, [validateField])

  // Handle change — clear error when user starts typing
  const handleChange = useCallback((name, value) => {
    if (touched[name]) {
      const error = validateField(name, value || '')
      setErrors(prev => ({ ...prev, [name]: error }))
    }
  }, [touched, validateField])

  // Get error for a field (only show if touched)
  const getError = useCallback((name) => {
    return touched[name] ? errors[name] : null
  }, [touched, errors])

  // Check if a field is valid and touched
  const isValid = useCallback((name) => {
    return touched[name] && !errors[name]
  }, [touched, errors])

  const reset = useCallback(() => {
    setTouched({})
    setErrors({})
  }, [])

  return {
    errors,
    touched,
    validateAll,
    handleBlur,
    handleChange,
    getError,
    isValid,
    reset
  }
}