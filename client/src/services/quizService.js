import api from './api'

export const getQuizzes     = ()         => api.get('/quizzes')
export const getQuiz        = (id)       => api.get(`/quizzes/${id}`)
export const createQuiz     = (data)     => api.post('/quizzes', data)
export const updateQuiz     = (id, data) => api.put(`/quizzes/${id}`, data)
export const deleteQuiz     = (id)       => api.delete(`/quizzes/${id}`)
export const addQuestion    = (id, data) => api.post(`/quizzes/${id}/questions`, data)
export const deleteQuestion = (qid, eid) => api.delete(`/quizzes/${qid}/questions/${eid}`)