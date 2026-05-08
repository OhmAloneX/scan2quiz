export default function GlassCard({ children, style = {}, glow = false }) {
  return (
    <div style={{
      background:           'rgba(255,255,255,0.06)',
      backdropFilter:       'blur(20px)',
      WebkitBackdropFilter: 'blur(20px)',
      border:               `1px solid ${glow
        ? 'rgba(34,211,238,0.3)'
        : 'rgba(103,232,249,0.18)'}`,
      borderRadius: 20,
      boxShadow:    '0 4px 32px rgba(0,0,0,0.25)',
      padding:      22,
      ...style
    }}>
      {children}
    </div>
  )
}