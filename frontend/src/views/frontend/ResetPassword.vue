<template>
  <div class="reset-page">
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

        <h1 class="main-title">给账号换一把新锁<br/><span class="text-blue">健康数据只属于你</span></h1>
        <p class="sub-title">身份核验已通过，为保护用户健康数据，密码重置成功后所有设备将强制退出登录，重置记录会写入审计日志并通知超级管理员。</p>

        <!-- 步骤条 -->
        <ul class="feature-list">
          <li>
            <div class="icon-box" style="background: rgba(16, 185, 129, 0.1); color: #10b981;"><el-icon><CircleCheckFilled /></el-icon></div>
            <div>
              <h4>1 · 验证身份 (已完成)</h4>
              <p>{{ currentAccount }} · 邮箱验证码校验通过 · 14:12</p>
            </div>
          </li>
          <li>
            <div class="icon-box" style="background: rgba(37, 99, 235, 0.1); color: #3b82f6;"><el-icon><Right /></el-icon></div>
            <div>
              <h4>2 · 设置新密码</h4>
              <!-- 💡 修改：改为只需字母和数字 -->
              <p>至少 8 位，包含字母与数字</p>
            </div>
          </li>
          <li>
            <div class="icon-box" style="background: rgba(255, 255, 255, 0.05); color: #94a3b8;"><el-icon><Right /></el-icon></div>
            <div>
              <h4>3 · 完成并重新登录</h4>
              <p>所有设备强制下线，需使用新密码登录</p>
            </div>
          </li>
        </ul>

        <div class="stats-box" style="display: block;">
          <div class="box-title" style="font-size: 13px; color: #f1f5f9; margin-bottom: 8px; display: flex; align-items: center; gap: 6px;">
            <el-icon><InfoFilled /></el-icon> 设置安全密码的建议
          </div>
          <ul style="padding-left: 16px; margin: 0; font-size: 12px; color: #94a3b8; line-height: 1.8;">
            <li>不要与其他平台密码相同，避免撞库风险</li>
            <li>避免使用生日、手机号、工号等容易猜测的组合</li>
            <li>建议使用 8 位以上的字母与数字混合组合</li>
          </ul>
        </div>
      </div>

      <div class="brand-footer">
        <div class="security-tags">
          <span><el-icon><Lock /></el-icon> 等保三级</span>
          <span><el-icon><Coin /></el-icon> 数据加密存储</span>
        </div>
        <p class="version">v2.4.1 · 构建于 2024.06.12 · 仅限授权管理员访问</p>
      </div>
    </div>

    <!-- 右侧设置区 -->
    <div class="login-section">
      <div class="login-card">
        <!-- 返回按钮 -->
        <div class="back-row">
          <el-button link @click="router.push('/login')"><el-icon><Back /></el-icon> 返回上一步</el-button>
        </div>

        <div class="card-header">
          <div class="icon-wrap"><el-icon><Lock /></el-icon></div>
          <h2>设置新密码</h2>
          <p>密码不可与最近 5 次使用过的密码相同，设置后立即生效</p>
        </div>

        <!-- 身份信息 -->
        <div class="identity-info">
          <el-icon><User /></el-icon>
          <div class="info-text">
            <div class="name">{{ currentAccount }}</div>
            <div class="role">账号 · 超级管理员 · 运营中心</div>
          </div>
          <el-link type="primary" underline="never" style="margin-left: auto;" @click="router.push('/login')">更换账号</el-link>
        </div>

        <el-form ref="formRef" :model="formData" :rules="rules" size="large">
          <!-- 新密码 -->
          <el-form-item prop="password">
            <div class="label-row">
              <label class="form-label">新密码 <span class="required">*</span></label>
              <span class="word-count">{{ formData.password.length }} / 32 字符</span>
            </div>
            <el-input 
              v-model="formData.password" 
              type="password" 
              placeholder="请输入新密码" 
              show-password 
              prefix-icon="Lock" 
            />
            
            <!-- 强度进度条 -->
            <div class="strength-bar" v-if="formData.password">
              <div class="bar-track">
                <div class="bar-fill" :class="strengthColor" :style="{ width: (strengthPercent / 75 * 100) + '%' }"></div>
              </div>
              <span class="strength-text" :class="strengthColor">{{ strengthText }}</span>
            </div>
            
            <!-- 校验规则 -->
            <div class="rule-list">
              <div class="rule-item" :class="{ passed: isLengthValid }"><el-icon><CircleCheckFilled v-if="isLengthValid" /><CircleCloseFilled v-else /></el-icon> 不少于 8 位</div>
              <!-- 💡 修改：改为“含字母” -->
              <div class="rule-item" :class="{ passed: isLetterValid }"><el-icon><CircleCheckFilled v-if="isLetterValid" /><CircleCloseFilled v-else /></el-icon> 含字母</div>
              <div class="rule-item" :class="{ passed: isNumValid }"><el-icon><CircleCheckFilled v-if="isNumValid" /><CircleCloseFilled v-else /></el-icon> 含数字</div>
            </div>
          </el-form-item>

          <!-- 确认密码 -->
          <el-form-item prop="confirmPassword">
            <label class="form-label">确认新密码 <span class="required">*</span></label>
            <el-input 
              v-model="formData.confirmPassword" 
              type="password" 
              placeholder="请再次输入新密码" 
              show-password 
              prefix-icon="Lock" 
            />
          </el-form-item>

          <!-- 勾选项 -->
          <div class="checkbox-list">
            <el-checkbox v-model="formData.logoutAll" disabled>
              <div class="cb-text">
                <strong>重置后强制所有设备退出登录</strong>
                <span>包含 3 台设备（Chrome 125 · 上海、Safari · iPhone、App · Android）</span>
              </div>
            </el-checkbox>
            <el-checkbox v-model="formData.notifyAdmin" disabled>
              <div class="cb-text">
                <strong>重置成功后邮件通知我</strong>
                <span>发送至 {{ currentAccount }}，并抄送超级管理员</span>
              </div>
            </el-checkbox>
          </div>

          <el-button type="primary" class="submit-btn" :loading="loading" @click="handleSubmit">
            确认重置密码 <el-icon class="el-icon--right"><Right /></el-icon>
          </el-button>

          <div class="help-text" style="margin-bottom: 12px;">
            <el-link type="primary" underline="never" @click="router.push('/login')">放弃重置？返回登录</el-link>
          </div>
          
          <div class="admin-help">
            <el-icon><InfoFilled /></el-icon> 
            邮箱已停用或无法接收验证码？请联系超级管理员 (chenke@healthhub.cn) 协助重置。
          </div>
        </el-form>
      </div>

      <div class="footer-links">
        © 2024 Health Hub 心理健康服务平台 · <el-link type="info" underline="never">隐私政策</el-link> · <el-link type="info" underline="never">服务条款</el-link> · <el-link type="info" underline="never">数据合规声明</el-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { 
  FirstAidKit, Lock, Coin, User, InfoFilled, Right, 
  CircleCheckFilled, CircleCloseFilled, Back 
} from '@element-plus/icons-vue'
import { resetPasswordApi } from '@/api/frontend'

const router = useRouter()
const route = useRoute()

const currentAccount = ref(route.query.email || 'admin')

const formRef = ref(null)
const loading = ref(false)

const formData = reactive({
  password: '',
  confirmPassword: '',
  logoutAll: true,
  notifyAdmin: true
})

// 实时校验规则
const isLengthValid = computed(() => formData.password.length >= 8)
// 💡 修改：只要求包含字母（不再要求大小写）
const isLetterValid = computed(() => /[a-zA-Z]/.test(formData.password))
const isNumValid = computed(() => /[0-9]/.test(formData.password))

// 密码强度计算 (满分 75)
const strengthPercent = computed(() => {
  if (!formData.password) return 0
  let score = 0
  if (isLengthValid.value) score += 25
  if (isLetterValid.value) score += 25
  if (isNumValid.value) score += 25
  return score
})

const strengthText = computed(() => {
  const s = strengthPercent.value
  if (s <= 25) return '弱'
  if (s <= 50) return '中'
  return '强'
})

const strengthColor = computed(() => {
  const s = strengthPercent.value
  if (s <= 25) return 'bg-red'
  if (s <= 50) return 'bg-orange'
  return 'bg-green'
})

// 表单校验
const validatePass2 = (rule, value, callback) => {
  if (value === '') {
    callback(new Error('请再次输入新密码'))
  } else if (value !== formData.password) {
    callback(new Error('两次输入密码不一致'))
  } else {
    callback()
  }
}

const rules = {
  password: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 8, message: '密码长度不能少于 8 位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, validator: validatePass2, trigger: 'blur' }
  ]
}

const handleSubmit = async () => {
  if (!formRef.value) return
  
  if (strengthPercent.value < 75) {
    return ElMessage.warning('请确保密码满足所有安全要求（长度、字母、数字）')
  }

  await formRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        const res = await resetPasswordApi({
          email: currentAccount.value,
          password: formData.password
        })
        
        if (res.code === '200' || res.code === 200) {
          ElMessage.success('密码重置成功！请查收通知邮件')
          setTimeout(() => {
            router.push('/login')
          }, 1500)
        } else {
          ElMessage.error(res.message || '重置失败')
        }
      } catch (error) {
        console.error(error)
        ElMessage.error(error.response?.data?.message || '网络异常，请稍后重试')
      } finally {
        loading.value = false
      }
    }
  })
}
</script>

<style scoped lang="scss">
/* 样式保持原样不变 */
.reset-page {
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

      .main-title {
        font-size: 32px;
        line-height: 1.4;
        font-weight: 700;
        margin: 0 0 16px;
        .text-blue { color: #3b82f6; }
      }

      .sub-title {
        font-size: 13px;
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
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            flex-shrink: 0;
          }
          h4 { margin: 0 0 4px; font-size: 14px; color: #f1f5f9; }
          p { margin: 0; font-size: 12px; color: #94a3b8; }
        }
      }

      .stats-box {
        background: rgba(255, 255, 255, 0.03);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 12px;
        padding: 20px;
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

    .login-card {
      width: 460px;
      background: #fff;
      padding: 32px 40px;
      border-radius: 16px;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
      
      .back-row {
        margin-bottom: 16px;
      }

      .card-header {
        margin-bottom: 24px;
        .icon-wrap {
          width: 48px;
          height: 48px;
          background: #eff6ff;
          color: #2563eb;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 24px;
          margin-bottom: 16px;
        }
        h2 { margin: 0 0 8px; font-size: 24px; color: #0f172a; }
        p { margin: 0; font-size: 13px; color: #64748b; }
      }

      .identity-info {
        display: flex;
        align-items: center;
        gap: 12px;
        background: #f8fafc;
        padding: 12px 16px;
        border-radius: 8px;
        border: 1px solid #e2e8f0;
        margin-bottom: 24px;
        .el-icon { font-size: 24px; color: #94a3b8; }
        .info-text {
          .name { font-size: 14px; font-weight: 600; color: #0f172a; }
          .role { font-size: 12px; color: #64748b; }
        }
      }

      :deep(.el-form-item__label) { display: none; }
      .form-label { display: block; font-size: 13px; font-weight: 500; color: #334155; margin-bottom: 8px; }
      .required { color: #ef4444; }
      
      .label-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        width: 100%;
        margin-bottom: 8px;
        .form-label { margin-bottom: 0; }
        .word-count { font-size: 12px; color: #94a3b8; }
      }

      .strength-bar {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-top: 8px;
        margin-bottom: 12px;
        .bar-track {
          flex: 1;
          height: 4px;
          background: #e2e8f0;
          border-radius: 2px;
          overflow: hidden;
          .bar-fill { height: 100%; transition: all 0.3s; }
          .bg-red { background: #ef4444; }
          .bg-orange { background: #f59e0b; }
          .bg-green { background: #10b981; }
        }
        .strength-text { font-size: 12px; font-weight: 600; }
        .text-red { color: #ef4444; }
        .text-orange { color: #f59e0b; }
        .text-green { color: #10b981; }
      }

      .rule-list {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 8px;
        background: #f8fafc;
        padding: 12px;
        border-radius: 8px;
        .rule-item {
          display: flex;
          align-items: center;
          gap: 4px;
          font-size: 12px;
          color: #94a3b8;
          &.passed { color: #10b981; }
        }
      }

      .checkbox-list {
        margin-bottom: 24px;
        .el-checkbox {
          display: flex;
          align-items: flex-start;
          margin-bottom: 12px;
          :deep(.el-checkbox__label) { margin-left: 8px; }
          .cb-text {
            display: flex;
            flex-direction: column;
            strong { font-size: 13px; font-weight: 500; color: #0f172a; }
            span { font-size: 12px; color: #94a3b8; margin-top: 2px; }
          }
        }
      }

      .submit-btn {
        width: 100%;
        height: 44px;
        font-size: 15px;
        font-weight: 600;
        background: #2563eb;
        border: none;
        border-radius: 8px;
        margin-bottom: 16px;
      }

      .help-text {
        text-align: center;
        font-size: 13px;
      }

      .admin-help {
        font-size: 12px;
        color: #94a3b8;
        text-align: center;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 4px;
        line-height: 1.5;
      }
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
  .reset-page {
    .brand-section { display: none; }
    .login-section { width: 100%; }
  }
}
</style>