import { createRouter, createWebHistory } from 'vue-router'

// ================= 前台路由 =================
const frontendRoutes = [
  { path: '/', name: 'Home', component: () => import('../views/frontend/home.vue') },
  { path: '/chat', name: 'AiChat', component: () => import('../views/frontend/AiChat.vue') },
  { 
    path: '/login', 
    name: 'Login', 
    // 💡 修改：改成小写的 login.vue
    component: () => import('../views/frontend/login.vue'),
    meta: { title: '登录' } 
  },
  // 注册页路由
  { 
    path: '/register', 
    name: 'Register', 
    component: () => import('../views/frontend/register.vue'),
    meta: { title: '申请开通账号' } 
  } ,
  { path: '/reset-password', name: 'ResetPassword', component: () => import('../views/frontend/ResetPassword.vue'), meta: { title: '重置密码' } }
  ,{ path: '/verify-code', name: 'VerifyCode', component: () => import('../views/frontend/VerifyCode.vue') }
]

// ================= 后台路由 =================
const backendRoutes = [
  {
    path: '/back',
    component: () => import('../components/AdminLayout.vue'),
    redirect: '/back/dashboard',
    meta: { requiresAuth: true }, 
    children: [
      // --- 核心工作台 ---
      { path: 'dashboard', name: 'Dashboard', component: () => import('../views/back/dashboard.vue'), meta: { title: '运营工作台', group: '管理后台' } },
      { path: 'user-management', name: 'UserManagement', component: () => import('../views/back/user-management.vue'), meta: { title: '用户管理', group: '管理后台' } },

      // --- 内容运营 ---
      { path: 'scale-management', name: 'ScaleManagement', component: () => import('../views/back/Assessments.vue'), meta: { title: '量表管理', group: '内容运营' } },
      { path: 'food-library', name: 'FoodLibrary', component: () => import('../views/back/FoodLibrary.vue'), meta: { title: '食物库管理', group: '内容运营' } },
      { path: 'suggestion-templates', name: 'SuggestionTemplates', component: () => import('../views/back/SuggestionTemplates.vue'), meta: { title: '建议文案模板', group: '内容运营' } },
      { path: 'create-suggestion', name: 'CreateSuggestion', component: () => import('../views/back/CreateSuggestion.vue'), meta: { title: '新建建议文案', group: '内容运营' } },
      { path: 'push-templates', name: 'PushTemplates', component: () => import('../views/back/PushTemplates.vue'), meta: { title: '推送模板', group: '内容运营' } },

      // --- AI 运营 ---
      { path: 'prompt-templates', name: 'PromptTemplates', component: () => import('../views/back/PromptTemplates.vue'), meta: { title: '提示词模板', group: 'AI运营' } },
      { path: 'create-prompt', name: 'CreatePrompt', component: () => import('../views/back/CreatePrompt.vue'), meta: { title: '新建提示词', group: 'AI运营' } },
      { path: 'conversation-audit', name: 'ChatAudit', component: () => import('../views/back/ChatAudit.vue'), meta: { title: '对话审计', group: 'AI运营' } },
      { path: 'conversation-audit/rules', name: 'ChatAuditRules', component: () => import('../views/back/ChatAuditRules.vue'), meta: { title: '审计规则', group: 'AI运营' } },
      { path: 'conversation-audit/rules/create', name: 'CreateAuditRule', component: () => import('../views/back/CreateAuditRule.vue'), meta: { title: '新建审计规则', group: 'AI运营' } },

      // --- 风险管理 ---
      { path: 'warning-rules', name: 'WarningRules', component: () => import('../views/back/WarningRules.vue'), meta: { title: '预警规则', group: '风险管理' } },
      { path: 'risk-alerts', name: 'WarningList', component: () => import('../views/back/WarningList.vue'), meta: { title: '风险预警列表', group: '风险管理' } },
      { path: 'created-new-rules', name: 'CreatedNewRules', component: () => import('../views/back/CreatedNewRules.vue'), meta: { title: '新建预警规则', group: '风险管理' } },

      // --- 系统管理 ---
      { path: 'admin-accounts', name: 'AdminAccounts', component: () => import('../views/back/AdminAccounts.vue'), meta: { title: '管理员账号', group: '系统管理' } },
      { path: 'roles', name: 'Roles', component: () => import('../views/back/Roles.vue'), meta: { title: '角色权限', group: '系统管理' } },
      { path: 'audit-logs', name: 'AuditLogs', component: () => import('../views/back/AuditLogs.vue'), meta: { title: '审计日志', group: '系统管理' } }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes: [...frontendRoutes, ...backendRoutes],
})

// ================= 💡 全局路由守卫 =================
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('admin_token')

  if (to.matched.some(record => record.meta.requiresAuth)) {
    if (!token) {
      next({
        path: '/login',
        query: { redirect: to.fullPath }
      })
    } else {
      next()
    }
  } else {
    if ((to.path === '/login' || to.path === '/register') && token) {
      next('/back/dashboard')
    } else {
      next()
    }
  }
})

export default router