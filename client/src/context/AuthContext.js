import { createContext, useContext, useState, useEffect } from 'react'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user,    setUser]    = useState(null)
  const [token,   setToken]   = useState(
    () => localStorage.getItem('s2q_token')
  )
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (token) {
      try {
        const payload = JSON.parse(atob(token.split('.')[1]))
        setUser(payload)
      } catch {
        logout()
      }
    }
    setLoading(false)
  }, [token])

  const login = (jwt) => {
    localStorage.setItem('s2q_token', jwt)
    setToken(jwt)
  }

  const logout = () => {
    localStorage.removeItem('s2q_token')
    setToken(null)
    setUser(null)
  }

  return (
    <AuthContext.Provider value={{
      user, token, login, logout, loading,
      isAuth: !!token
    }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)