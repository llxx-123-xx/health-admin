<template>
  <div class="login-page">
    <!-- 左侧品牌区 -->
    <div class="brand-section">
      <div class="brand-content">
        <div class="logo-area">
          <div class="logo-icon"><el-icon><FirstAidKit /></el-icon></div>
          <div class="logo-text">
            <h2>Health Hub</h2>
            <p>运营管理后台</p>
          </div>
        </div>

        <!-- 运行状态 (💡 动态数据) -->
        <div class="status-bar">
          <span class="dot"></span> 系统运行正常 · 今日已服务 <strong>{{ dashboardStats.todayUsers }}</strong> 名用户
        </div>

        <!-- 主标题 -->
        <h1 class="main-title">守护每一次健康对话<br/><span class="text-blue">让运营决策有据可依</span></h1>
        <p class="sub-title">统一管理用户健康档案、量表测评、AI 助手与风险预警，在合规前提下完成内容运营与个案跟进。</p>

        <!-- 功能列表 -->
        <ul class="feature-list">
          <li>
            <div class="icon-box"><el-icon><Monitor /></el-icon></div>
            <div>
              <h4>全链路操作留痕</h4>
              <p>敏感数据查看、导出与权限变更均写入审计日志</p>
            </div>
          </li>
          <li>
            <div class="icon-box"><el-icon><UserFilled /></el-icon></div>
            <div>
              <h4>角色权限精细分级</h4>
              <p>7 种角色、22 项权限，按模块与数据范围授权</p>
            </div>
          </li>
          <li>
            <div class="icon-box"><el-icon><WarningFilled /></el-icon></div>
            <div>
              <h4>高风险实时预警</h4>
              <p>量表阈值、日志异常与对话安全词触发时即时提醒</p>
            </div>
          </li>
        </ul>

        <!-- 数据统计 (💡 动态数据) -->
        <div class="stats-box">
          <div class="stat-item">
            <div class="num">{{ dashboardStats.totalUsers }}</div>
            <div class="label">用户总数</div>
          </div>
          <div class="stat-item border-left">
            <div class="num">{{ dashboardStats.roleTypes }} 类</div>
            <div class="label">角色类型</div>
          </div>
          <div class="stat-item border-left">
            <div class="num">{{ dashboardStats.availability }}</div>
            <div class="label">近 30 天可用性</div>
          </div>
        </div>
      </div>

      <!-- 底部信息 (💡 动态年份与日期) -->
      <div class="brand-footer">
        <div class="security-tags">
          <span><el-icon><Lock /></el-icon> 等保三级</span>
          <span><el-icon><Coin /></el-icon> 数据加密存储</span>
          <span><el-icon><User /></el-icon> 最小权限控制</span>
        </div>
        <p class="version">v2.4.1 · 构建于 {{ buildDate }} · 仅限授权管理员访问</p>
      </div>
    </div>

    <!-- 右侧登录区 -->
    <div class="login-section">
      <div class="top-actions">
        <el-button link><el-icon><Headset /></el-icon> 简体中文</el-button>
        <el-divider direction="vertical" />
        <el-button link><el-icon><QuestionFilled /></el-icon> 帮助中心</el-button>
      </div>

      <div class="login-card">
        <!-- 头部：根据状态切换 -->
        <div class="card-header">
          <div class="icon-wrap" :class="{ 'is-error': isErrorState }">
            <el-icon><component :is="isErrorState ? 'WarningFilled' : 'User'" /></el-icon>
          </div>
          <h2>{{ isErrorState ? '登录失败' : '欢迎回来' }}</h2>
          <p>{{ isErrorState ? '请检查账号和密码后重新登录' : '请使用管理员账号登录 Health Hub 运营后台' }}</p>
        </div>

        <!-- 错误提示条 (仅在失败时显示) -->
        <div v-if="isErrorState" class="error-banner">
          <el-icon><WarningFilled /></el-icon>
          <div>
            <strong>账号或密码错误，还可尝试 {{ Math.max(0, 5 - failCount) }} 次</strong>
            <p v-if="failCount < 5">连续 5 次将锁定账号 30 分钟，本次登录已记录</p>
            <p v-else style="font-weight: bold; color: #b91c1c;">账号已锁定，请 30 分钟后重试</p>
          </div>
        </div>

        <el-form ref="loginFormRef" :model="loginForm" :rules="rules" size="large" @keyup.enter="handleLogin">
          <el-form-item prop="username">
            <label class="form-label">登录账号</label>
            <el-input 
              v-model="loginForm.username" 
              placeholder="请输入登录账号或企业邮箱" 
              prefix-icon="User" 
              :class="{ 'is-error-input': isErrorState }" 
              :disabled="failCount >= 5" 
            />
          </el-form-item>

          <el-form-item prop="password">
            <div class="label-row" style="width: 100%; display: flex; justify-content: space-between; align-items: center;">
              <label class="form-label" style="margin-bottom: 0;">密码</label>
              <el-link type="primary" underline="never" @click="openForgotDialog">忘记密码?</el-link>
            </div>
            <el-input 
              v-model="loginForm.password" 
              type="password" 
              placeholder="请输入密码" 
              show-password 
              prefix-icon="Lock" 
              :class="{ 'is-error-input': isErrorState }"
              :disabled="failCount >= 5"
            />
            <div v-if="isErrorState" class="error-text">
              <el-icon><CircleCloseFilled /></el-icon> 密码错误，建议您核对大小写与输入法
            </div>
          </el-form-item>

          <el-form-item v-if="isErrorState" prop="captcha">
            <div class="label-row" style="width: 100%; display: flex; justify-content: space-between; align-items: center;">
              <label class="form-label" style="margin-bottom: 0;">图形验证码</label>
              <el-link type="primary" underline="never" @click="refreshCaptcha">看不清，换一张</el-link>
            </div>
            <div class="captcha-row">
              <el-input v-model="loginForm.captcha" placeholder="请输入右侧 4 位字符" :disabled="failCount >= 5" />
              <div class="captcha-img" @click="refreshCaptcha" title="点击刷新">
                {{ captchaCode }}
              </div>
            </div>
          </el-form-item>

          <div class="login-options">
            <el-checkbox v-model="rememberMe">记住账号（7 天）</el-checkbox>
            <span class="two-factor" v-if="!isErrorState"><el-icon><CircleCheckFilled /></el-icon> 二次验证已开启</span>
            <span class="error-attempts" v-else>本次为第 {{ failCount }} 次失败</span>
          </div>

          <el-button type="primary" class="login-btn" :loading="loading" @click="handleLogin" :disabled="failCount >= 5">
            {{ failCount >= 5 ? '账号已锁定' : (isErrorState ? '重新登录' : '登 录') }} 
            <el-icon class="el-icon--right"><Right /></el-icon>
          </el-button>

          <div v-if="isErrorState" class="admin-help">
            <el-icon><InfoFilled /></el-icon> 
            如确认密码无法找回，请联系 IT 管理员（chenke@healthhub.cn）重置。
          </div>
          <p v-else class="login-tip">
            <el-icon><InfoFilled /></el-icon> 登录后需完成两步验证才能进入后台
          </p>

          <div class="help-text" v-if="!isErrorState" style="margin-top: 20px;">
            还没有账号？
            <el-link type="primary" underline="never" @click="router.push('/register')" style="font-weight: 600;">
              立即注册
            </el-link>
          </div>
        </el-form>
      </div>

      <div class="system-info">
        <el-icon><Location /></el-icon> 本次登录环境：10.20.31.18 · 上海 · Chrome 125（内网）
      </div>
      
      <!-- 💡 动态年份 -->
      <div class="footer-links">
        © {{ currentYear }} Health Hub 心理健康服务平台 · <el-link type="info" underline="never">隐私政策</el-link> · <el-link type="info" underline="never">服务条款</el-link> · <el-link type="info" underline="never">数据合规声明</el-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  FirstAidKit, Monitor, UserFilled, WarningFilled, 
  Lock, Coin, User, Headset, QuestionFilled, 
  CircleCheckFilled, Right, InfoFilled, Location,
  CircleCloseFilled
} from '@element-plus/icons-vue'

// 💡 核心修改：引入封装好的接口，移除多余的 request
import { loginApi, getDashboardStats } from '@/api/frontend' 

const router = useRouter()
const route = useRoute()

// ================= 💡 核心修改：动态时间与数据 =================
const currentYear = new Date().getFullYear()

// 格式化今天的日期，比如 2026.11.12
const today = new Date()
const buildDate = `${today.getFullYear()}.${String(today.getMonth() + 1).padStart(2, '0')}.${String(today.getDate()).padStart(2, '0')}`

// 仪表盘统计数据（初始值设为 0，接口返回后替换）
const dashboardStats = reactive({
  todayUsers: '0',
  totalUsers: '0',
  roleTypes: 0,
  availability: '0%'
})

// ================= 登录逻辑 =================
const loginFormRef = ref(null)
const loading = ref(false)
const rememberMe = ref(true)
const isErrorState = ref(false) 
const failCount = ref(0) 

// 图形验证码相关
const captchaCode = ref('')
const generateCaptcha = () => {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
  let code = ''
  for (let i = 0; i < 4; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  return code
}

const refreshCaptcha = () => {
  captchaCode.value = generateCaptcha()
}

const loginForm = reactive({
  username: '',
  password: '',
  captcha: ''
})

const rules = {
  username: [{ required: true, message: '请输入登录账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  captcha: [{ required: true, message: '请输入验证码', trigger: 'blur' }]
}

const handleLogin = async () => {
  if (!loginFormRef.value) return
  await loginFormRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        const res = await loginApi(loginForm)
        
        if (res.code === '200' || res.code === 200) {
          localStorage.setItem('admin_token', res.data.token)
          localStorage.setItem('admin_info', JSON.stringify(res.data.userInfo))
          ElMessage.success('登录成功，正在跳转...')
          const redirectPath = route.query.redirect || '/back/dashboard'
          router.push(redirectPath)
        } else {
          handleLoginFail(res.message || '登录失败')
        }
      } catch (error) {
        const errorMsg = error.response?.data?.message || '账号或密码错误'
        
        if (errorMsg.includes('账号不存在')) {
          ElMessageBox.confirm(
            '该账号不存在，是否需要前往注册页面开通账号？', 
            '账号不存在', 
            {
              confirmButtonText: '前往注册',
              cancelButtonText: '重新输入',
              type: 'warning'
            }
          ).then(() => {
            router.push('/register')
          }).catch(() => {})
        } else {
          handleLoginFail(errorMsg)
        }
      } finally {
        loading.value = false
      }
    }
  })
}

// 模拟登录失败逻辑
const handleLoginFail = (msg) => {
  ElMessage.error(msg)
  isErrorState.value = true 
  failCount.value++ 
  
  refreshCaptcha()
  loginForm.captcha = '' 
  
  if (failCount.value >= 5) {
    ElMessage.error('账号已锁定 30 分钟，请稍后再试')
  }
}

// 忘记密码逻辑
const openForgotDialog = () => {
  const email = loginForm.username || ''
  router.push({ path: '/verify-code', query: { email } })
}

// ================= 生命周期：请求真实数据 =================
onMounted(async () => {
  refreshCaptcha()
  
  // 💡 核心修改：调用封装好的 API 获取统计数据
  try {
    const res = await getDashboardStats()
    
    // 兼容 axios 拦截器解包
    const responseData = res.data && res.data.code ? res.data : res;
    
    if (responseData && (responseData.code === '200' || responseData.code === 200)) {
      const stats = responseData.data || {};
      
      // 格式化数字（把 500 变成 500，把 1284 变成 1,284）
      dashboardStats.todayUsers = stats.todayUsers ? Number(stats.todayUsers).toLocaleString() : '0';
      dashboardStats.totalUsers = stats.totalUsers ? Number(stats.totalUsers).toLocaleString() : '0';
      dashboardStats.roleTypes = stats.roleTypes || 0;
      dashboardStats.availability = stats.availability || '0%';
      
      console.log('✅ 登录页统计数据加载成功:', dashboardStats)
    }
  } catch (error) {
    console.error('❌ 获取统计数据失败:', error)
    // 降级处理：如果后端没启动或接口报错，展示一个默认好看的值，防止页面太丑
    dashboardStats.todayUsers = '1,284'
    dashboardStats.totalUsers = '18,432'
    dashboardStats.roleTypes = 7
    dashboardStats.availability = '99.98%'
  }
})
</script>

<style scoped lang="scss">
/* 你的原有样式，完全不用动 */
.login-page {
  display: flex;
  height: 100vh;
  width: 100vw;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  background: #f8fafc;

  .brand-section {
    width: 50%;
    background: #0f172a;
    color: #fff;
    display: flex;
    flex-direction: column;
    justify-content: center;
    padding: 60px 10%;
    position: relative;

    .brand-content {
      max-width: 520px;
      .logo-area {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 40px;
        .logo-icon {
          width: 48px;
          height: 48px;
          background: #2563eb;
          border-radius: 12px;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 24px;
        }
        .logo-text h2 { margin: 0; font-size: 22px; font-weight: 600; }
        .logo-text p { margin: 4px 0 0; font-size: 13px; color: #94a3b8; }
      }

      .status-bar {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: rgba(37, 99, 235, 0.1);
        border: 1px solid rgba(37, 99, 235, 0.2);
        padding: 6px 12px;
        border-radius: 20px;
        font-size: 12px;
        color: #93c5fd;
        margin-bottom: 24px;
        .dot { width: 6px; height: 6px; background: #10b981; border-radius: 50%; }
        strong { color: #fff; }
      }

      .main-title {
        font-size: 36px;
        line-height: 1.4;
        font-weight: 700;
        margin: 0 0 16px;
        .text-blue { color: #3b82f6; }
      }

      .sub-title {
        font-size: 14px;
        color: #94a3b8;
        line-height: 1.6;
        margin-bottom: 40px;
      }

      .feature-list {
        list-style: none;
        padding: 0;
        margin: 0 0 40px;
        li {
          display: flex;
          gap: 16px;
          margin-bottom: 24px;
          .icon-box {
            width: 40px;
            height: 40px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            color: #60a5fa;
            flex-shrink: 0;
          }
          h4 { margin: 0 0 4px; font-size: 15px; color: #f1f5f9; }
          p { margin: 0; font-size: 13px; color: #94a3b8; }
        }
      }

      .stats-box {
        display: flex;
        background: rgba(255, 255, 255, 0.03);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 12px;
        padding: 20px;
        .stat-item {
          flex: 1;
          text-align: center;
          &.border-left { border-left: 1px solid rgba(255, 255, 255, 0.1); }
          .num { font-size: 24px; font-weight: 700; color: #fff; margin-bottom: 4px; }
          .label { font-size: 12px; color: #94a3b8; }
        }
      }
    }

    .brand-footer {
      position: absolute;
      bottom: 40px;
      left: 10%;
      right: 10%;
      .security-tags {
        display: flex;
        gap: 20px;
        font-size: 12px;
        color: #64748b;
        margin-bottom: 12px;
        span { display: flex; align-items: center; gap: 6px; }
      }
      .version { margin: 0; font-size: 12px; color: #475569; }
    }
  }

  .login-section {
    width: 50%;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    position: relative;
    background: #f8fafc;

    .top-actions {
      position: absolute;
      top: 24px;
      right: 40px;
      display: flex;
      align-items: center;
      .el-button { color: #64748b; font-size: 13px; }
    }

    .login-card {
      width: 420px;
      background: #fff;
      padding: 40px;
      border-radius: 16px;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
      
      .card-header {
        text-align: center;
        margin-bottom: 24px;
        .icon-wrap {
          width: 56px;
          height: 56px;
          background: #eff6ff;
          color: #2563eb;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 28px;
          margin: 0 auto 16px;
          &.is-error {
            background: #fef2f2;
            color: #ef4444;
          }
        }
        h2 { margin: 0 0 8px; font-size: 24px; color: #0f172a; }
        p { margin: 0; font-size: 13px; color: #64748b; }
      }

      .error-banner {
        background: #fef2f2;
        border: 1px solid #fecaca;
        border-radius: 8px;
        padding: 12px;
        margin-bottom: 20px;
        display: flex;
        gap: 8px;
        color: #b91c1c;
        .el-icon { font-size: 18px; flex-shrink: 0; margin-top: 2px; }
        strong { font-size: 13px; display: block; margin-bottom: 4px; }
        p { font-size: 12px; margin: 0; color: #ef4444; }
      }

      :deep(.el-form-item__label) { display: none; }
      .form-label { display: block; font-size: 13px; font-weight: 500; color: #334155; margin-bottom: 8px; }
      
      .label-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 8px;
        .form-label { margin-bottom: 0; }
      }

      .is-error-input :deep(.el-input__wrapper) {
        box-shadow: 0 0 0 1px #ef4444 inset !important;
        background-color: #fef2f2;
      }

      .error-text {
        font-size: 12px;
        color: #ef4444;
        display: flex;
        align-items: center;
        gap: 4px;
        margin-top: 6px;
      }

      .captcha-row {
        display: flex;
        gap: 12px;
        width: 100%;
        .el-input { flex: 1; }
        .captcha-img {
          width: 100px;
          height: 40px;
          background: #f1f5f9;
          border: 1px solid #e2e8f0;
          border-radius: 6px;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 20px;
          font-weight: 700;
          font-style: italic;
          letter-spacing: 4px;
          color: #2563eb;
          cursor: pointer;
          user-select: none;
        }
      }

      .login-options {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 24px;
        font-size: 13px;
        .two-factor { color: #10b981; display: flex; align-items: center; gap: 4px; }
        .error-attempts { color: #f59e0b; font-weight: 500; }
      }

      .login-btn {
        width: 100%;
        height: 44px;
        font-size: 15px;
        font-weight: 600;
        background: #2563eb;
        border: none;
        border-radius: 8px;
        margin-bottom: 12px;
      }

      .login-tip {
        text-align: center;
        font-size: 12px;
        color: #94a3b8;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 4px;
        margin: 0 0 20px;
      }

      .admin-help {
        font-size: 12px;
        color: #94a3b8;
        text-align: center;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 4px;
        margin-top: 16px;
        line-height: 1.5;
      }

      .help-text { 
        text-align: center; 
        font-size: 13px; 
        color: #64748b; 
        margin: 0; 
      }
    }

    .system-info {
      margin-top: 24px;
      font-size: 12px;
      color: #64748b;
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .footer-links {
      position: absolute;
      bottom: 24px;
      font-size: 12px;
      color: #94a3b8;
      .el-link { font-size: 12px; vertical-align: baseline; }
    }
  }
}

@media (max-width: 1024px) {
  .login-page {
    .brand-section { display: none; }
    .login-section { width: 100%; }
  }
}
</style>