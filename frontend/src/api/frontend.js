import service from '@/utils/request'

// 登录
export function loginApi(data) {
  return service.post('/auth/login', data) 
}

// 注册
export function registerApi(data) {
  return service.post('/auth/register', data)
}

// 发送邮箱验证码
export function sendEmailCode(email) {
  return service.get('/auth/send-code', { params: { email } })
}
export function checkAccountApi(username) {
  return service.get('/auth/check-account', { params: { username } })
}
export function verifyCodeApi(data) {
  return service.post('/auth/verify-code', data)
}
// 重置密码
export function resetPasswordApi(data) {
  return service.post('/auth/reset-password', data)
}
export function getDashboardStats() {
  return service.get('/dashboard/stats')
}
