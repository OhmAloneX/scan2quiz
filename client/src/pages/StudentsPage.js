import { useState, useEffect } from 'react'
import { useValidation, rules } from '../hooks/useValidation'
import Sidebar   from '../components/layout/Sidebar'
import GlassCard from '../components/ui/GlassCard'
import api       from '../services/api'
import useResponsive from '../hooks/useResponsive'

export default function StudentsPage() {
  const { isMobile, isTablet } = useResponsive()
  const [students, setStudents] = useState([])


  const [loading,  setLoading]  = useState(true)
  const [search,   setSearch]   = useState('')
  const [showForm, setShowForm] = useState(false)
  const [deleting, setDeleting] = useState(null)
  const [form, setForm] = useState({
    student_id: '', name: '',
    section: '', year_level: '', barcode: ''
  })

  const studentSchema = {
  student_id: [
    rules.required('Student ID'),
    rules.minLength(5, 'Student ID'),
    rules.maxLength(30, 'Student ID')
  ],

  name: [
    rules.required('Full name'),
    rules.minLength(2, 'Full name'),
    rules.maxLength(100, 'Full name')
  ],

  barcode: [
    rules.required('Barcode'),
    rules.noSpaces(),
    rules.minLength(3, 'Barcode')
  ]
}

const {
  getError: getStuError,
  isValid:  isStuValid,
  handleBlur:   stuBlur,
  handleChange: stuChange,
  validateAll:  validateStu,
  reset:        resetStu
} = useValidation(studentSchema)

  useEffect(() => { loadStudents() }, [])

  async function loadStudents() {
    try {
      const res = await api.get('/students')
      setStudents(res.data.data)
    } catch (err) {
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  async function handleCreate(e) {
    e.preventDefault()

    if (!validateStu(form)) return

    try {
      await api.post('/students', {
        ...form,
        year_level: form.year_level
          ? +form.year_level
          : null
      })

      setShowForm(false)

      resetStu()

      setForm({
        student_id: '',
        name: '',
        section: '',
        year_level: '',
        barcode: ''
      })

      loadStudents()

    } catch (err) {
      alert(
        err.response?.data?.message ||
        'Failed to add student'
      )
    }
  }

  async function handleDelete(id, name) {
    if (!window.confirm(
      `Delete student "${name}"? This cannot be undone.`))
      return
    setDeleting(id)
    try {
      await api.delete(`/students/${id}`)
      loadStudents()
    } catch (err) {
      alert('Failed to delete student')
    } finally {
      setDeleting(null)
    }
  }

  const filtered = students.filter(s =>
    s.name.toLowerCase().includes(search.toLowerCase())     ||
    s.student_id.includes(search)                           ||
    (s.section || '').toLowerCase()
      .includes(search.toLowerCase())                       ||
    s.barcode.includes(search)
  )

  const inputStyle = {
    width:        '100%',
    padding:      '10px 14px',
    background:   'rgba(255,255,255,0.06)',
    border:       '1px solid rgba(103,232,249,0.25)',
    borderRadius: 10,
    color:        '#e0f7ff',
    fontSize:     13,
    outline:      'none',
    fontFamily:   'inherit',
    boxSizing:    'border-box'
  }

  const labelStyle = {
    display:      'block',
    fontSize:     12,
    color:        'rgba(186,230,253,0.6)',
    marginBottom: 4
  }

  const btnStyle = {
    padding:      isMobile ? '9px 16px' : '10px 20px',

    background:   'linear-gradient(135deg,' +
      'rgba(34,211,238,0.2),rgba(99,102,241,0.2))',
    border:       '1px solid rgba(34,211,238,0.45)',
    borderRadius: 12,
    color:        '#22d3ee',
    fontSize:     isMobile ? 13 : 14,

    fontWeight:   600,
    cursor:       'pointer',
    fontFamily:   'inherit'
  }

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
          padding:        isMobile
            ? '12px 14px'
            : isTablet
              ? '16px 18px'
              : '16px 28px',
          background:     'rgba(255,255,255,0.03)',
          backdropFilter: 'blur(16px)',
          borderBottom:   '1px solid rgba(103,232,249,0.08)',
          display:        'flex',
          alignItems:     'center',
          justifyContent: 'space-between',
          gap:            isMobile ? 12 : 16,
          flexDirection: isMobile ? 'column' : 'row'
        }}>
          <div>
            <h1 style={{
              color: '#e0f7ff',
              fontSize: isMobile ? 18 : 20,
              fontWeight: 600,
              margin: 0
            }}>
              Students
            </h1>
            <p style={{
              color: 'rgba(186,230,253,0.5)',
              fontSize: 13, margin: '2px 0 0'
            }}>
              Manage student roster and barcode IDs
            </p>
          </div>
          <div style={{ display: 'flex', gap: 10 }}>
              <input
              type="text"
              placeholder="Search name, ID, section..."
              value={search}
              onChange={e => setSearch(e.target.value)}
              style={{
                ...inputStyle,
                width: isMobile ? '100%' : 260,
                height: 40,
                fontSize: isMobile ? 13 : 13
              }}
            />
            <button
              onClick={() => setShowForm(f => !f)}
              style={btnStyle}>
              + Add Student
            </button>
          </div>
        </div>

        <div style={{
          padding: isMobile
            ? '16px 14px'
            : isTablet
              ? '20px 18px'
              : '24px 28px'
        }}>


          {/* Stats */}
          {!loading && (
            <div style={{
              display: 'grid',
              gridTemplateColumns: isMobile
                ? '1fr'
                : isTablet
                  ? 'repeat(2, 1fr)'
                  : 'repeat(4, 1fr)',
              gap: isMobile ? 12 : 16,
              marginBottom: isMobile ? 16 : 24
            }}>

              {[
                {
                  label: 'Total Students',
                  value: students.length,
                  color: '#22d3ee',
                },
                {
                  label: 'Sections',
                  value: [...new Set(
                    students.map(s => s.section)
                      .filter(Boolean)
                  )].length,
                  color: '#a78bfa',
                },
                {
                  label: 'Active',
                  value: students.filter(s => s.is_active).length,
                  color: '#4ade80',
                },
                {
                  label: 'Search Results',
                  value: filtered.length,
                  color: '#fbbf24',
                }
              ].map(stat => (
                <GlassCard key={stat.label} style={{ padding: 18 }}>
                  <div style={{
                    display:        'flex',
                    justifyContent: 'space-between',
                    marginBottom:   8
                  }}>
                    <span style={{
                      fontSize:      11,
                      color:         'rgba(186,230,253,0.5)',
                      textTransform: 'uppercase',
                      letterSpacing: '0.8px'
                    }}>
                      {stat.label}
                    </span>
                    <span style={{ fontSize: 18 }}>{stat.icon}</span>
                  </div>
                  <p style={{
                    fontSize:   isMobile ? 22 : 28,
                    fontWeight: 700,
                    color:      stat.color,
                    margin:     0
                  }}>
                    {stat.value}
                  </p>
                </GlassCard>
              ))}
            </div>
          )}

          {/* Add Student Form */}
          {showForm && (
            <GlassCard glow style={{ marginBottom: 24 }}>
              <h2 style={{
                color: '#e0f7ff', fontSize: 16,
                fontWeight: 600, margin: '0 0 20px'
              }}>
                Add New Student
              </h2>
              <form onSubmit={handleCreate}>
                <div style={{
                  display: 'grid',
                  gridTemplateColumns: isMobile
                    ? '1fr'
                    : isTablet
                      ? 'repeat(2, 1fr)'
                      : '1fr 1fr',
                  gap: isMobile ? 12 : 16,
                  marginBottom: isMobile ? 12 : 16
                }}>

                  <div>
                    <label style={labelStyle}>Student ID *</label>

                    <input
                      style={{
                        ...inputStyle,
                        borderColor: getStuError('student_id')
                          ? 'rgba(248,113,113,0.7)'
                          : isStuValid('student_id')
                          ? 'rgba(74,222,128,0.6)'
                          : 'rgba(103,232,249,0.25)'
                      }}
                      required
                      value={form.student_id}
                      onChange={e => {
                        setForm({
                          ...form,
                          student_id: e.target.value
                        })

                        stuChange('student_id', e.target.value)
                      }}
                      onBlur={e =>
                        stuBlur('student_id', e.target.value)
                      }
                      placeholder="e.g. 2024-00006"
                    />

                    {getStuError('student_id') && (
                      <p style={{
                        color: '#f87171',
                        fontSize: 11,
                        margin: '4px 0 0',
                        display: 'flex',
                        alignItems: 'center',
                        gap: 4
                      }}>
                        ⚠ {getStuError('student_id')}
                      </p>
                    )}
                  </div>
                  <div>
                    <label style={labelStyle}>Full Name *</label>

                    <input
                      style={{
                        ...inputStyle,
                        borderColor: getStuError('name')
                          ? 'rgba(248,113,113,0.7)'
                          : isStuValid('name')
                          ? 'rgba(74,222,128,0.6)'
                          : 'rgba(103,232,249,0.25)'
                      }}
                      required
                      value={form.name}
                      onChange={e => {
                        setForm({
                          ...form,
                          name: e.target.value
                        })

                        stuChange('name', e.target.value)
                      }}
                      onBlur={e =>
                        stuBlur('name', e.target.value)
                      }
                      placeholder="e.g. Juan Dela Cruz"
                    />

                    {getStuError('name') && (
                      <p style={{
                        color: '#f87171',
                        fontSize: 11,
                        margin: '4px 0 0',
                        display: 'flex',
                        alignItems: 'center',
                        gap: 4
                      }}>
                        ⚠ {getStuError('name')}
                      </p>
                    )}
                  </div>
                  <div>
                    <label style={labelStyle}>Section</label>
                    <input
                      style={inputStyle}
                      value={form.section}
                      onChange={e => setForm({
                        ...form, section: e.target.value
                      })}
                      placeholder="e.g. BSCS 3-A"
                    />
                  </div>
                  <div>
                    <label style={labelStyle}>Year Level</label>
                    <select
                      style={inputStyle}
                      value={form.year_level}
                      onChange={e => setForm({
                        ...form, year_level: e.target.value
                      })}>
                      <option value="">-- Select --</option>
                      {[1, 2, 3, 4].map(y => (
                        <option
                          key={y} value={y}
                          style={{ background: '#0a1628' }}>
                          Year {y}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label style={labelStyle}>Barcode *</label>

                    <input
                      style={{
                        ...inputStyle,
                        borderColor: getStuError('barcode')
                          ? 'rgba(248,113,113,0.7)'
                          : isStuValid('barcode')
                          ? 'rgba(74,222,128,0.6)'
                          : 'rgba(103,232,249,0.25)'
                      }}
                      required
                      value={form.barcode}
                      onChange={e => {
                        setForm({
                          ...form,
                          barcode: e.target.value
                        })

                        stuChange('barcode', e.target.value)
                      }}
                      onBlur={e =>
                        stuBlur('barcode', e.target.value)
                      }
                      placeholder="e.g. STU-001"
                    />

                    {getStuError('barcode') && (
                      <p style={{
                        color: '#f87171',
                        fontSize: 11,
                        margin: '4px 0 0',
                        display: 'flex',
                        alignItems: 'center',
                        gap: 4
                      }}>
                        ⚠ {getStuError('barcode')}
                      </p>
                    )}
                  </div>
                </div>

                <div style={{ display: 'flex', gap: 10 }}>
                  <button type="submit" style={btnStyle}>
                    Add Student
                  </button>
                  <button
                    type="button"
                    onClick={() => setShowForm(false)}
                    style={{
                      padding:      '10px 20px',
                      background:   'transparent',
                      border:       '1px solid rgba(103,232,249,0.2)',
                      borderRadius: 12,
                      color:        'rgba(186,230,253,0.6)',
                      cursor:       'pointer',
                      fontFamily:   'inherit'
                    }}>
                    Cancel
                  </button>
                </div>
              </form>
            </GlassCard>
          )}

          {/* Students table */}
          {loading ? (
            <div style={{
              display:        'flex',
              alignItems:     'center',
              justifyContent: 'center',
              height:         300
            }}>
              <p style={{ color: 'rgba(186,230,253,0.5)' }}>
                Loading students...
              </p>
            </div>
          ) : filtered.length === 0 ? (
            <GlassCard style={{ textAlign: 'center', padding: 48 }}>
              <p style={{
                color: '#e0f7ff', fontSize: 16,
                fontWeight: 600, margin: '0 0 8px'
              }}>
                {search ? 'No students found' : 'No students yet'}
              </p>
              <p style={{
                color: 'rgba(186,230,253,0.4)', fontSize: 13
              }}>
                {search
                  ? `No results for "${search}"`
                  : 'Click "+ Add Student" to register students'}
              </p>
            </GlassCard>
          ) : (
            <GlassCard>
              <div style={{
                display:        'flex',
                justifyContent: 'space-between',
                alignItems:     'center',
                marginBottom:   18
              }}>
                <h2 style={{
                  color: '#e0f7ff', fontSize: 16,
                  fontWeight: 600, margin: 0
                }}>
                  Student Roster
                </h2>
                <span style={{
                  fontSize: 12,
                  color:    'rgba(186,230,253,0.4)'
                }}>
                  {filtered.length} of {students.length} students
                </span>
              </div>

              <div style={{ overflowX: 'auto' }}>
                <table style={{
                  width: '100%', borderCollapse: 'collapse',
                  minWidth: isMobile ? 640 : undefined
                }}>


                <thead>
                  <tr>
                    {['Student ID', 'Name', 'Section',
                      'Year', 'Barcode', 'Status',
                      'Actions'].map(h => (
                      <th key={h} style={{
                        textAlign:     'left',
                        padding:       '8px 12px',
                        fontSize:      11,
                        color:         'rgba(186,230,253,0.45)',
                        fontWeight:    500,
                        textTransform: 'uppercase',
                        letterSpacing: '0.7px',
                        borderBottom:
                          '1px solid rgba(103,232,249,0.1)'
                      }}>
                        {h}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {filtered.map((student, i) => (
                    <tr key={student.id} style={{
                      borderBottom: i < filtered.length - 1
                        ? '1px solid rgba(103,232,249,0.06)'
                        : 'none'
                    }}>
                      <td style={{ padding: '12px' }}>
                        <span style={{
                          fontFamily: 'monospace',
                          color:      '#22d3ee',
                          fontSize:   13
                        }}>
                          {student.student_id}
                        </span>
                      </td>
                      <td style={{ padding: '12px' }}>
                        <div style={{
                          display:    'flex',
                          alignItems: 'center',
                          gap:        10
                        }}>
                          <div style={{
                            width:          32,
                            height:         32,
                            borderRadius:   '50%',
                            background:     'linear-gradient(' +
                              '135deg,#22d3ee,#6366f1)',
                            display:        'flex',
                            alignItems:     'center',
                            justifyContent: 'center',
                            fontSize:       12,
                            fontWeight:     700,
                            color:          '#0f172a',
                            flexShrink:     0
                          }}>
                            {student.name.charAt(0).toUpperCase()}
                          </div>
                          <span style={{
                            color:      '#e0f7ff',
                            fontWeight: 500,
                            fontSize:   13
                          }}>
                            {student.name}
                          </span>
                        </div>
                      </td>
                      <td style={{ padding: '12px' }}>
                        {student.section ? (
                          <span style={{
                            fontSize:     11,
                            fontWeight:   600,
                            padding:      '3px 10px',
                            borderRadius: 20,
                            background:   'rgba(165,180,252,0.15)',
                            border:       '1px solid rgba(165,180,252,0.3)',
                            color:        '#a5b4fc'
                          }}>
                            {student.section}
                          </span>
                        ) : (
                          <span style={{
                            color: 'rgba(186,230,253,0.3)',
                            fontSize: 12
                          }}>
                            —
                          </span>
                        )}
                      </td>
                      <td style={{
                        padding:  '12px',
                        color:    'rgba(186,230,253,0.6)',
                        fontSize: 13
                      }}>
                        {student.year_level
                          ? `Year ${student.year_level}`
                          : '—'}
                      </td>
                      <td style={{ padding: '12px' }}>
                        <span style={{
                          fontFamily:   'monospace',
                          fontSize:     12,
                          color:        'rgba(186,230,253,0.6)',
                          background:   'rgba(255,255,255,0.04)',
                          border:       '1px solid rgba(103,232,249,0.15)',
                          borderRadius: 6,
                          padding:      '2px 8px'
                        }}>
                          {student.barcode}
                        </span>
                      </td>
                      <td style={{ padding: '12px' }}>
                        <span style={{
                          fontSize:     11,
                          fontWeight:   600,
                          padding:      '3px 10px',
                          borderRadius: 20,
                          background:   student.is_active
                            ? 'rgba(74,222,128,0.15)'
                            : 'rgba(248,113,113,0.15)',
                          border: `1px solid ${student.is_active
                            ? 'rgba(74,222,128,0.3)'
                            : 'rgba(248,113,113,0.3)'}`,
                          color: student.is_active
                            ? '#4ade80' : '#f87171'
                        }}>
                          {student.is_active ? 'Active' : 'Inactive'}
                        </span>
                      </td>
                      <td style={{ padding: '12px' }}>
                        <button
                          onClick={() => handleDelete(
                            student.id, student.name
                          )}
                          disabled={deleting === student.id}
                          style={{
                            padding:      '5px 12px',
                            background:   'rgba(248,113,113,0.1)',
                            border:       '1px solid rgba(248,113,113,0.3)',
                            borderRadius: 8,
                            color:        '#f87171',
                            fontSize:     11,
                            cursor:       'pointer',
                            fontFamily:   'inherit'
                          }}>
                          {deleting === student.id
                            ? '...' : '🗑 Delete'}
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
                </table>
              </div>

            </GlassCard>
          )}
        </div>
      </div>
    </div>
  )
}