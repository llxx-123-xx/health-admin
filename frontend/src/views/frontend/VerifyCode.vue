<template>
  <div class="verify-page">
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

        <h1 class="main-title">验证您的身份<br/><span class="text-blue">守护每一次健康对话</span></h1>
        <p class="sub-title">为了保障您的账号安全，我们需要验证您的注册邮箱。验证通过后即可设置新密码。</p>

        <ul class="feature-list">
          <li>
            <div class="icon-box" style="background: rgba(37, 99, 235, 0.1); color: #3b82f6;"><el-icon><Message /></el-icon></div>
            <div>
              <h4>1 · 验证身份</h4>
              <p>向您的注册邮箱发送 6 位验证码</p>
            </div>
          </li>
          <li>
            <div class="icon-box" style="background: rgba(255, 255, 255, 0.05); color: #94a3b8;"><el-icon><Right /></el-icon></div>
            <div>
              <h4>2 · 设置新密码</h4>
              <p>输入符合安全要求的新密码</p>
            </div>
          </li>
          <li>
            <div class="icon-box" style="background: rgba(255, 255, 255, 0.05); color: #94a3b8;"><el-icon><Right /></el-icon></div>
            <div>
              <h4>3 · 完成重置</h4>
              <p>所有设备强制下线，使用新密码登录</p>
            </div>
          </li>
        </ul>
      </div>

      <div class="brand-footer">
        <div class="security-tags">
          <span><el-icon><Lock /></el-icon> 等保三级</span>
          <span><el-icon><Coin /></el-icon> 数据加密存储</span>
        </div>
        <p class="version">v2.4.1 · 构建于 2024.06.12 · 仅限授权管理员访问</p>
      </div>
    </div>

    <!-- 右侧验证区 -->
    <div class="login-section">
      <div class="verify-card">
        <div class="back-row">
          <el-button link @click="router.push('/login')"><el-icon><Back /></el-icon> 返回上一步</el-button>
        </div>

        <div class="card-header">
          <div class="icon-wrap"><el-icon><Message /></el-icon></div>
          <h2>验证身份</h2>
          <p>为了保障您的账号安全，请验证您的注册邮箱</p>
        </div>

        <el-form label-position="top" size="large">
          <el-form-item label="注册邮箱">
            <el-input v-model="email" placeholder="请输入您的注册邮箱" prefix-icon="Message" />
          </el-form-item>

          <el-form-item label="邮箱验证码">
            <div class="code-row">
              <el-input v-model="code" placeholder="请输入 6 位验证码" maxlength="6" />
              <!-- 💡 增加 :loading="sending" 解决点击延迟感 -->
              <el-button 
                type="primary" 
                plain 
                :loading="sending" 
                :disabled="countdown > 0" 
                @click="sendCode"
              >
                {{ countdown > 0 ? `${countdown}s 后重发` : '获取验证码' }}
              </el-button>
            </div>
          </el-form-item>

          <el-button type="primary" class="submit-btn" :loading="loading" @click="handleVerify">
            验证并继续 <el-icon class="el-icon--right"><Right /></el-icon>
          </el-button>

          <div class="help-text">
            <el-icon><InfoFilled /></el-icon> 验证码 5 分钟内有效，请勿泄露给他人。
          </div>
        </el-form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { 
  FirstAidKit, Lock, Coin, Message, Right, Back, InfoFilled 
} from '@element-plus/icons-vue'
import { sendEmailCode, verifyCodeApi, checkAccountApi } from '@/api/frontend'

const router = useRouter()
const route = useRoute()

const email = ref(route.query.email || '')
const code = ref('')
const loading = ref(false)
const sending = ref(false) // 💡 新增：发送按钮的 loading 状态
const countdown = ref(0)

// 发送验证码（先校验账号）
const sendCode = async () => {
  if (!email.value) {
    return ElMessage.warning('请输入您的注册邮箱')
  }
  
  sending.value = true // 💡 点击立刻进入加载状态，防止重复点击
  
  try {
    // 1. 校验账号是否存在
    const checkRes = await checkAccountApi(email.value)
    if (checkRes.code !== '200' && checkRes.code !== 200) {
      sending.value = false
      return ElMessage.error('该账号不存在，请确认后重试')
    }
    
    // 2. 发送验证码
    const res = await sendEmailCode(email.value)
    if (res.code === '200' || res.code === 200) {
      ElMessage.success('验证码已发送，请查收邮箱')
      countdown.value = 60
      const timer = setInterval(() => {
        countdown.value--
        if (countdown.value <= 0) clearInterval(timer)
      }, 1000)
    }
  } catch (error) {
    ElMessage.error(error.response?.data?.message || '账号不存在，请确认后重试')
  } finally {
    sending.value = false // 💡 请求结束，关闭加载状态
  }
}

// 校验验证码
const handleVerify = async () => {
  if (!email.value) return ElMessage.warning('请输入邮箱')
  if (!code.value) return ElMessage.warning('请输入验证码')
  
  loading.value = true
  try {
    const res = await verifyCodeApi({ email: email.value, code: code.value })
    if (res.code === '200' || res.code === 200) {
      ElMessage.success('验证通过，即将设置新密码')
      router.push({ path: '/reset-password', query: { email: email.value } })
    }
  } catch (error) {
    ElMessage.error(error.response?.data?.message || '验证码错误或已过期')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  if (route.query.email) {
    email.value = route.query.email
  }
})
</script>

<style scoped lang="scss">
.verify-page {
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
          width: 48px; height: 48px; background: #2563eb; border-radius: 12px;
          display: flex; align-items: center; justify-content: center; font-size: 24px;
        }
        .logo-text h2 { margin: 0; font-size: 22px; font-weight: 600; }
        .logo-text p { margin: 4px 0 0; font-size: 13px; color: #94a3b8; }
      }

      .main-title {
        font-size: 32px; line-height: 1.4; font-weight: 700; margin: 0 0 16px;
        .text-blue { color: #3b82f6; }
      }

      .sub-title {
        font-size: 13px; color: #94a3b8; line-height: 1.6; margin-bottom: 40px;
      }

      .feature-list {
        list-style: none; padding: 0; margin: 0 0 40px;
        li {
          display: flex; gap: 16px; margin-bottom: 24px;
          .icon-box {
            width: 32px; height: 32px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 18px; flex-shrink: 0;
          }
          h4 { margin: 0 0 4px; font-size: 14px; color: #f1f5f9; }
          p { margin: 0; font-size: 12px; color: #94a3b8; }
        }
      }
    }

    .brand-footer {
      position: absolute; bottom: 40px; left: 10%; right: 10%;
      .security-tags {
        display: flex; gap: 20px; font-size: 12px; color: #64748b; margin-bottom: 12px;
        span { display: flex; align-items: center; gap: 6px; }
      }
      .version { margin: 0; font-size: 12px; color: #475569; }
    }
  }

  .login-section {
    width: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    background: #f8fafc;

    .verify-card {
      width: 420px;
      background: #fff;
      padding: 32px 40px;
      border-radius: 16px;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);

      .back-row { margin-bottom: 16px; }

      .card-header {
        text-align: center;
        margin-bottom: 24px;
        .icon-wrap {
          width: 48px; height: 48px; background: #eff6ff; color: #2563eb;
          border-radius: 50%; display: flex; align-items: center; justify-content: center;
          font-size: 24px; margin: 0 auto 16px;
        }
        h2 { margin: 0 0 8px; font-size: 24px; color: #0f172a; }
        p { margin: 0; font-size: 13px; color: #64748b; }
      }

      :deep(.el-form-item__label) {
        font-size: 13px; color: #334155; font-weight: 500; padding-bottom: 4px;
      }

      .code-row {
        display: flex; gap: 12px; width: 100%;
        .el-input { flex: 1; }
        .el-button { width: 120px; }
      }

      .submit-btn {
        width: 100%; height: 44px; font-size: 15px; font-weight: 600;
        background: #2563eb; border: none; border-radius: 8px; margin-top: 10px;
      }

      .help-text {
        text-align: center; font-size: 12px; color: #94a3b8; margin-top: 16px;
        display: flex; align-items: center; justify-content: center; gap: 4px;
      }
    }
  }
}

@media (max-width: 1024px) {
  .verify-page {
    .brand-section { display: none; }
    .login-section { width: 100%; }
  }
}
</style>