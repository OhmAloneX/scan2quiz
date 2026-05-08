import GlassCard from './GlassCard'

export default function StatCard({ label, value, sub, accent, icon }) {
  return (
    <GlassCard glow>
      <div style={{
        display:        'flex',
        justifyContent: 'space-between',
        alignItems:     'flex-start',
        marginBottom:   10
      }}>
        <span style={{
          fontSize:      11,
          color:         'rgba(186,230,253,0.55)',
          textTransform: 'uppercase',
          letterSpacing: '0.9px',
          fontWeight:    500
        }}>
          {label}
        </span>
        <div style={{
          width:          34,
          height:         34,
          borderRadius:   10,
          background:     `${accent}22`,
          border:         `1px solid ${accent}44`,
          display:        'flex',
          alignItems:     'center',
          justifyContent: 'center',
          fontSize:       16
        }}>
          {icon}
        </div>
      </div>

      <p style={{
        fontSize:   30,
        fontWeight: 700,
        color:      '#e0f7ff',
        margin:     '0 0 4px'
      }}>
        {value ?? '—'}
      </p>

      <p style={{
        fontSize: 12,
        margin:   0,
        color:    sub?.toString().startsWith('+')
          ? '#4ade80'
          : 'rgba(186,230,253,0.5)'
      }}>
        {sub}
      </p>
    </GlassCard>
  )
}