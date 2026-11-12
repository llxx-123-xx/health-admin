<template>
  <div class="register-page">
    <div class="register-card">
      <div class="card-header">
        <div class="icon-wrap"><el-icon><UserFilled /></el-icon></div>
        <h2>申请开通账号</h2>
        <p>请填写以下信息提交申请，审核通过后将发送至您的企业邮箱</p>
      </div>

      <!-- 步骤条 -->
      <el-steps :active="1" align-center finish-status="success" class="step-bar">
        <el-step title="填写信息" />
        <el-step title="邮箱验证" />
        <el-step title="提交审核" />
      </el-steps>

      <el-form ref="formRef" :model="formData" :rules="rules" size="large">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item prop="realName">
              <label class="form-label">真实姓名 <span class="required">*</span></label>
              <el-input v-model="formData.realName" placeholder="请输入身份证上的姓名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item prop="phone">
              <label class="form-label">手机号 <span class="required">*</span></label>
              <el-input v-model="formData.phone" placeholder="11位手机号，用于接收安全验证">
                <template #prepend>+86</template>
              </el-input>
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item prop="email">
          <label class="form-label">企业邮箱 <span class="required">*</span></label>
          <div class="email-row">
            <el-input v-model="formData.email" placeholder="name@healthhub.cn" />
            <el-button type="primary" plain :disabled="countdown > 0" @click="sendCode">
              {{ countdown > 0 ? `${countdown}s 后重发` : '获取验证码' }}
            </el-button>
          </div>
          <div class="form-tip">5 分钟内有效</div>
        </el-form-item>

        <el-form-item prop="code">
          <label class="form-label">邮箱验证码 <span class="required">*</span></label>
          <el-input v-model="formData.code" placeholder="请输入验证码" maxlength="6" />
        </el-form-item>

        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item prop="org">
              <label class="form-label">所属机构 <span class="required">*</span></label>
              <el-select v-model="formData.org" placeholder="请选择机构" style="width: 100%">
                <el-option label="研发科技总部" value="研发科技总部" />
                <el-option label="运营中心" value="运营中心" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item prop="department">
              <label class="form-label">所属部门 <span class="required">*</span></label>
              <el-select v-model="formData.department" placeholder="请选择部门" style="width: 100%">
                <el-option label="内容运营" value="内容运营" />
                <el-option label="技术部" value="技术部" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item prop="role">
          <label class="form-label">申请角色 <span class="required">*</span></label>
          <el-select v-model="formData.role" placeholder="请选择角色" style="width: 100%">
            <el-option label="运营专员" value="content_ops" />
            <el-option label="数据分析" value="data_analyst" />
          </el-select>
          <div class="form-tip">角色决定可见功能与数据范围，最终权限需管理员审核确认。</div>
        </el-form-item>

        <el-form-item prop="reason">
          <label class="form-label">申请理由</label>
          <el-input v-model="formData.reason" type="textarea" :rows="2" placeholder="简要说明您需要权限的业务场景，例如：负责量表测评内容与推送文案管理" maxlength="200" show-word-limit />
        </el-form-item>

        <el-form-item prop="password">
          <label class="form-label">设置密码 <span class="required">*</span></label>
          <el-input v-model="formData.password" type="password" placeholder="请输入密码" show-password />
          <div class="strength-bar">
            <span v-if="formData.password" :class="strengthClass">{{ strengthText }}</span>
          </div>
        </el-form-item>

        <el-form-item prop="confirmPassword">
          <label class="form-label">确认密码 <span class="required">*</span></label>
          <el-input v-model="formData.confirmPassword" type="password" placeholder="请再次输入密码" show-password />
        </el-form-item>

        <el-checkbox v-model="agreed" class="agreement">
          我已阅读并同意 
          <el-link type="primary" underline="never">《服务条款》</el-link> 
          与 
          <el-link type="primary" underline="never">《隐私政策》</el-link>
        </el-checkbox>

        <el-button type="primary" class="submit-btn" :loading="loading" @click="handleRegister">
          提交开通申请
        </el-button>

        <div class="help-text">
          已有账号？ 
          <el-link type="primary" underline="never" @click="router.push('/login')">返回登录</el-link>
        </div>
        <p class="footer-tip">申请将同步至审批工作台，可在通知中心查看进度，审核结果 1 天内反馈</p>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { UserFilled } from '@element-plus/icons-vue'
import { registerApi, sendEmailCode } from '@/api/frontend' 

const router = useRouter()
const formRef = ref(null)
const loading = ref(false)
const agreed = ref(false)
const countdown = ref(0)

const formData = reactive({
  realName: '',
  phone: '',
  email: '',
  code: '',
  org: '',
  department: '',
  role: 'content_ops',
  reason: '',
  password: '',
  confirmPassword: ''
})

// 验证规则
const rules = {
  realName: [{ required: true, message: '请输入真实姓名', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入企业邮箱', trigger: 'blur' },
    { type: 'email', message: '邮箱格式不正确', trigger: 'blur' }
  ],
  code: [{ required: true, message: '请输入验证码', trigger: 'blur' }],
  org: [{ required: true, message: '请选择所属机构', trigger: 'change' }],
  department: [{ required: true, message: '请选择所属部门', trigger: 'change' }],
  role: [{ required: true, message: '请选择角色', trigger: 'change' }],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度至少 6 位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== formData.password) {
          callback(new Error('两次输入密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ]
}

// 密码强度计算
const strengthText = computed(() => {
  const pwd = formData.password
  if (!pwd) return ''
  let score = 0
  if (pwd.length >= 8) score++
  if (/[A-Z]/.test(pwd)) score++
  if (/[0-9]/.test(pwd)) score++
  if (/[^A-Za-z0-9]/.test(pwd)) score++
  if (score <= 1) return '弱：建议增加字母和数字'
  if (score === 2) return '中：可以加上特殊字符'
  return '强：符合安全要求'
})

const strengthClass = computed(() => {
  if (strengthText.value.startsWith('弱')) return 'text-red'
  if (strengthText.value.startsWith('中')) return 'text-orange'
  return 'text-green'
})

// 发送验证码逻辑 (真实请求)
const sendCode = async () => {
  if (!formData.email) {
    ElMessage.warning('请先填写企业邮箱')
    return
  }

  try {
    const res = await sendEmailCode(formData.email)
    
    if (res.code === '200' || res.code === 200) {
      ElMessage.success('验证码已发送，请查收邮箱')
      countdown.value = 60
      const timer = setInterval(() => {
        countdown.value--
        if (countdown.value <= 0) clearInterval(timer)
      }, 1000)
    } else {
      ElMessage.error(res.message || '发送失败')
    }
  } catch (error) {
    console.error(error)
    ElMessage.error('发送失败，请检查后端服务')
  }
}

// 提交注册
const handleRegister = async () => {
  if (!formRef.value) return
  if (!agreed.value) {
    ElMessage.warning('请先勾选同意服务条款与隐私政策')
    return
  }
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        const res = await registerApi(formData)
        if (res.code === '200' || res.code === 200) {
          ElMessage.success('申请提交成功，请等待管理员审核')
          router.push('/login')
        } else {
          ElMessage.error(res.message || '申请失败')
        }
      } catch (error) {
        ElMessage.error(error.response?.data?.message || '网络异常，请稍后重试')
      } finally {
        loading.value = false
      }
    } else {
      // 💡 核心修改：如果校验失败，明确告诉用户！
      ElMessage.error('请检查上方带 * 号的必填项是否都已填写完整！')
    }
  })
}
</script>

<style scoped lang="scss">
.register-page {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: #f8fafc;
  padding: 40px 0;
  
  .register-card {
    width: 600px;
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
      }
      h2 { margin: 0 0 8px; font-size: 24px; color: #0f172a; }
      p { margin: 0; font-size: 13px; color: #64748b; }
    }

    .step-bar {
      margin-bottom: 30px;
      :deep(.el-step__title) { font-size: 13px; }
    }

    :deep(.el-form-item__label) { display: none; }
    .form-label { 
      display: block; 
      font-size: 13px; 
      font-weight: 500; 
      color: #334155; 
      margin-bottom: 8px; 
      .required { color: #ef4444; }
    }

    .email-row {
      display: flex;
      gap: 12px;
      width: 100%;
      .el-input { flex: 1; }
    }

    .form-tip {
      font-size: 12px;
      color: #94a3b8;
      margin-top: 6px;
      line-height: 1.4;
    }

    .strength-bar {
      margin-top: 6px;
      font-size: 12px;
      .text-red { color: #ef4444; }
      .text-orange { color: #f59e0b; }
      .text-green { color: #10b981; }
    }

    .agreement {
      margin-bottom: 24px;
      font-size: 13px;
    }

    .submit-btn {
      width: 100%;
      height: 44px;
      font-size: 15px;
      font-weight: 600;
      background: #2563eb;
      border: none;
      border-radius: 8px;
    }

    .help-text {
      text-align: center;
      font-size: 13px;
      color: #64748b;
      margin-top: 16px;
    }

    .footer-tip {
      text-align: center;
      font-size: 12px;
      color: #94a3b8;
      margin-top: 20px;
    }
  }
}
</style>