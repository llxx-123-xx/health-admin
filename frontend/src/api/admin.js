import service from '@/utils/request'

// 获取仪表盘统计数据
export function getDashboardStats() {
  return service.get('/admin/dashboard/stats')
}

// 保存预警规则
export function saveWarningRule(data) {
  return service.post('/admin/warning-rules', data)
}

// 获取预警规则列表
export function getWarningRules() {
  return service.get('/admin/warning-rules')
}

// 修改预警规则状态
export function updateRuleStatus(id, status) {
  return service.put(`/admin/warning-rules/${id}/status`, null, {
    params: { status }
  })
}

// 获取预警列表
export function getWarningOrders() {
  return service.get('/admin/warning-orders')
}

// 获取量表列表
export function getAssessments() {
  return service.get('/admin/assessments')
}

// 修改量表状态
export function updateAssessmentStatus(id, status) {
  return service.put(`/admin/assessments/${id}/status`, null, { params: { status } })
}

// 新建量表
export function saveAssessment(data) {
  return service.post('/admin/assessments', data)
}

// 修改量表
export function updateAssessment(data) {
  return service.put(`/admin/assessments/${data.id}`, data)
}

// 获取食物列表（带分页）
export function getFoods(params) {
  return service.get('/admin/foods', { params })
}

// 新建食物
export function saveFood(data) {
  return service.post('/admin/foods', data)
}

// 修改食物
export function updateFood(data) {
  return service.put(`/admin/foods/${data.id}`, data)
}

// 修改食物状态
export function updateFoodStatus(id, status) {
  return service.put(`/admin/foods/${id}/status`, null, { params: { status } })
}

// 批量修改食物状态
export function batchUpdateFoodStatus(ids, status) {
  return service.put('/admin/foods/batch-status', ids, { 
    params: { status } 
  })
}

// ==========================================
// 7. 建议文案模板 相关 API
// ==========================================

// 获取建议文案列表（带分页）
export function getSuggestionTemplates(params) {
  return service.get('/admin/suggestion-templates', { params })
}

// 新建建议文案
export function saveSuggestionTemplate(data) {
  return service.post('/admin/suggestion-templates', data)
}

// 修改建议文案
export function updateSuggestionTemplate(data) {
  return service.put(`/admin/suggestion-templates/${data.id}`, data)
}

// 修改建议文案状态（启用/停用/审核）
export function updateSuggestionStatus(id, status) {
  return service.put(`/admin/suggestion-templates/${id}/status`, null, { 
    params: { status } 
  })
}

// 获取推送模板列表
export function getPushTemplates(params) {
  return service.get('/admin/push-templates', { params })
}

// 新建推送模板
export function savePushTemplate(data) {
  return service.post('/admin/push-templates', data)
}

// 修改推送模板
export function updatePushTemplate(data) {
  return service.put(`/admin/push-templates/${data.id}`, data)
}

// 修改推送模板状态
export function updatePushStatus(id, status) {
  return service.put(`/admin/push-templates/${id}/status`, null, { params: { status } })
}

export function getPromptTemplates(params) {
  return service.get('/admin/prompt-templates', { params })
}

export function savePromptTemplate(data) {
  return service.post('/admin/prompt-templates', data)
}

export function updatePromptTemplate(data) {
  return service.put(`/admin/prompt-templates/${data.id}`, data)
}

export function updatePromptStatus(id, status) {
  return service.put(`/admin/prompt-templates/${id}/status`, null, { params: { status } })
}

// 获取对话审计列表
export function getChatAudits(params) {
  return service.get('/admin/chat-audits', { params })
}

// 修改对话审计状态
export function updateChatAuditStatus(id, status) {
  return service.put(`/admin/chat-audits/${id}/status`, null, { params: { status } })
}

// 获取审计规则列表 (复用 prompt-templates 接口)
export function getAuditRules(params) {
  return service.get('/admin/prompt-templates/audit-rules', { params })
}

// 修改审计规则状态
export function updateAuditRuleStatus(id, status) {
  return service.put(`/admin/prompt-templates/audit-rules/${id}/status`, null, { params: { status } })
}

// ==========================================
// 8. 审计规则扩展 API（复用 prompt-templates）
// ==========================================

// 自动生成审计规则编码
export function generateAuditRuleCode() {
  return service.get('/admin/prompt-templates/audit-rules/generate-code')
}

// 新建审计规则（复用 savePromptTemplate，但单独封装一个语义清晰的方法）
export function saveAuditRule(data) {
  return service.post('/admin/prompt-templates/audit-rules', data)
}

// ==========================================
// 管理员账号相关 API
// ==========================================

// 获取管理员列表
export function getAdminAccounts(params) {
  return service.get('/admin/accounts', { params })
}

// 修改管理员状态
export function updateAdminAccountStatus(id, status) {
  return service.put(`/admin/accounts/${id}/status`, null, { 
    params: { status } 
  })
}

// 新增管理员
export function saveAdminAccount(data) {
  return service.post('/admin/accounts', data)
}
// 校验验证码
export function verifyCodeApi(data) {
  return service.post('/auth/verify-code', data)
}
// ==========================================
// 角色权限相关 API
// ==========================================

// 获取所有角色
export function getAllRoles() {
  return service.get('/admin/roles')
}

// 获取某个角色的权限配置
export function getRolePermissions(roleCode) {
  return service.get(`/admin/roles/${roleCode}/permissions`)
}

// 保存某个角色的权限配置
export function saveRolePermissions(roleCode, permissions) {
  return service.post(`/admin/roles/${roleCode}/permissions`, permissions)
}

// 获取某个角色下的真实成员列表
export function getRoleMembers(roleCode) {
  return service.get(`/admin/roles/${roleCode}/members`)
}

// 新增角色
export function createRole(data) {
  return service.post('/admin/roles', data)
}

// 更新角色（用于编辑名称、停用/启用）
export function updateRole(data) {
  return service.put('/admin/roles', data)
}

// ==========================================
// 审计日志相关 API
// ==========================================

// 获取审计日志列表（带分页）
export function getAuditLogs(params) {
  return service.get('/admin/audit-logs', { params })
}
// ==========================================
// 用户管理相关 API
// ==========================================

// 获取用户列表（带分页）
export function getUserList(params) {
  return service.get('/admin/users/list', { params })
}

// 批量修改用户状态（禁用/解禁）
export function updateUserStatus(data) {
  return service.post('/admin/users/batch-status', data)
}
// 新建用户
export function createUser(data) {
  return service.post('/admin/users', data)
}
