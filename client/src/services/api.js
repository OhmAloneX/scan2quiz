import axios from 'axios'

// Automatically use the correct server URL
// Works from both localhost AND phone on same WiFi
const getBaseURL = () => {
  const hostname = window.location.hostname
  // If accessing from phone on local network use the same host
  // If on localhost use localhost
  if (hostname === 'localhost' || hostname === '127.0.0.1') {
    return 'http://localhost:5000/api'
  }
  // Phone accessing via IP — use same IP but port 5000
  return `http://${hostname}:5000/api`
}

const api = axios.create({
  baseURL: getBaseURL(),
  headers: { 'Content-Type': 'application/json' }
})

// Attach token to every request automatically
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('s2q_token')
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// Redirect to login on 401
api.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) {
      localStorage.removeItem('s2q_token')
      window.location.href = '/login'
    }
    return Promise.reject(err)
  }
)

export default api