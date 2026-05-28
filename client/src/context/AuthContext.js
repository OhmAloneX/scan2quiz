import { createContext, useContext, useState, useEffect } from 'react'
import api from '../services/api'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [token, setToken] = useState(() => localStorage.getItem('s2q_token'))
  // Keep loading=true until we finish bootstrapping auth at least once.
  const [loading, setLoading] = useState(true)
  const [isAuth, setIsAuth] = useState(false)

  const clearAuth = () => {
    localStorage.removeItem('s2q_token')
    setToken(null)
    setUser(null)
    setIsAuth(false)
  }

  // Validate token on app startup (server is source of truth).
  // Important: run whenever `token` changes, but ensure we *always* resolve `loading`.
  useEffect(() => {
    let isMounted = true

    async function bootstrapAuth() {
      // While validating, block protected routes.
      setLoading(true)

      if (!token) {
        if (!isMounted) return
        setIsAuth(false)
        setUser(null)
        setLoading(false)
        return
      }

      try {
        const res = await api.get('/auth/me')
        if (!isMounted) return
        setUser(res.data.user || null)
        setIsAuth(true)
      } catch (err) {
        if (!isMounted) return
        clearAuth()
      } finally {
        if (!isMounted) return
        setLoading(false)
      }
    }

    bootstrapAuth()

    return () => {
      isMounted = false
    }
  }, [token])

  const login = (jwt) => {
    localStorage.setItem('s2q_token', jwt)
    setToken(jwt)
    // bootstrapAuth will re-check /auth/me and set loading=false.
    setLoading(true)
  }

  const logout = () => {
    clearAuth()
  }

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        login,
        logout,
        loading,
        isAuth
      }}
    >
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)

