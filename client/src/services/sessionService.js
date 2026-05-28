import api from './api'

export const createSession = (quizId)      => api.post('/sessions', { quizId })
export const getSessions   = ()            => api.get('/sessions')
export const closeSession  = (id)          => api.patch(`/sessions/${id}/close`)
export const handleScan    = (data)        => api.post('/scan', data)
export const joinSession   = (id)          => api.post(`/sessions/${id}/join`)
export const getQuestions  = (id)          => api.get(`/attempts/${id}/questions`)
export const submitAttempt = (id, answers) => api.post(`/attempts/${id}/submit`, { answers })
export const getResult     = (id)          => api.get(`/attempts/${id}/result`)
export const fetchParticipants = (sessionId) => api.get(`/session/${sessionId}/students`)

