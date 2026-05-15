import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { useAuth }    from './context/AuthContext'
import LoginPage      from './pages/LoginPage'
import DashboardPage  from './pages/DashboardPage'
import QuizzesPage    from './pages/QuizzesPage'
import AnalyticsPage  from './pages/AnalyticsPage'
import ScannerPage    from './pages/ScannerPage'
import QuizPage       from './pages/QuizPage'
import SessionsPage   from './pages/SessionsPage'
import StudentsPage   from './pages/StudentsPage'
import RegisterPage   from './pages/RegisterPage'
import JoinPage       from './pages/JoinPage'
import TakeQuizPage   from './pages/TakeQuizPage'

function ProtectedRoute({ children }) {
  const { isAuth, loading } = useAuth()
  if (loading) return (
    <div style={{
      minHeight:      '100vh',
      display:        'flex',
      alignItems:     'center',
      justifyContent: 'center',
      background:     '#0a1628'
    }}>
      <p style={{ color: '#22d3ee' }}>Loading...</p>
    </div>
  )
  return isAuth ? children : <Navigate to="/login" replace />
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/dashboard" element={
          <ProtectedRoute><DashboardPage /></ProtectedRoute>
        }/>
        <Route path="/register" element={<RegisterPage />} />
        <Route path="/join"      element={<JoinPage />} />
        <Route path="/take-quiz/:attemptId" element={<TakeQuizPage />} />
        <Route path="/quizzes" element={
          <ProtectedRoute><QuizzesPage /></ProtectedRoute>
        }/>
        <Route path="/analytics" element={
          <ProtectedRoute><AnalyticsPage /></ProtectedRoute>
        }/>
        <Route path="/scanner" element={
          <ProtectedRoute><ScannerPage /></ProtectedRoute>
        }/>
        <Route path="/quiz/:attemptId" element={
          <ProtectedRoute><QuizPage /></ProtectedRoute>
        }/>
        <Route path="/sessions" element={
          <ProtectedRoute><SessionsPage /></ProtectedRoute>
        }/>
        <Route path="/students" element={
          <ProtectedRoute><StudentsPage /></ProtectedRoute>
        }/>
        <Route path="*"
          element={<Navigate to="/dashboard" replace />}
        />
      </Routes>
    </BrowserRouter>
  )
}