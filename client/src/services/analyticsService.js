import api from './api'

export const getDashboard    = () => api.get('/analytics/dashboard')
export const getTrend        = () => api.get('/analytics/trend')
export const getDistribution = () => api.get('/analytics/distribution')
export const getTopStudents  = () => api.get('/analytics/top-students')