<template>
  <div class="rule-config-page">
    <!-- 1. 顶部操作栏 -->
    <div class="top-bar">
      <div class="title-area">
        <el-icon class="back-icon" @click="goBack"><i class="ri-arrow-left-line"></i></el-icon>
        <h2>新建预警规则</h2>
        <span class="sub-title">配置触发条件、风险分级与通知策略，保存后 5 分钟内生效</span>
      </div>
      <div class="action-area">
        <el-button class="btn-export">保存草稿</el-button>
        <el-button class="btn-export">规则预览</el-button>
        <el-button type="primary" class="btn-add" @click="submitAll">保存并启用</el-button>
      </div>
    </div>

    <!-- 2. 步骤条 -->
    <div class="step-bar">
      <el-steps :active="currentStep" align-center>
        <el-step title="基本信息" :status="currentStep > 0 ? 'success' : 'process'" />
        <el-step title="触发条件" :status="currentStep > 1 ? 'success' : (currentStep === 1 ? 'process' : 'wait')" />
        <el-step title="风险分级与时效" :status="currentStep > 2 ? 'success' : (currentStep === 2 ? 'process' : 'wait')" />
        <el-step title="通知策略" :status="currentStep === 3 ? 'process' : 'wait'" />
      </el-steps>
    </div>

    <!-- 3. 主体内容区 -->
    <div class="main-content">
      
      <!-- ============ 左侧表单区 ============ -->
      <div class="left-form">
        
        <!-- 面板1：基本信息 -->
        <el-card v-show="currentStep === 0" shadow="never" class="form-card">
          <template #header>
            <div class="card-header">
              <span class="card-title"><i class="ri-checkbox-circle-fill text-green"></i> 基本信息</span>
            </div>
          </template>

          <el-form :model="formData" label-position="top">
            <el-form-item label="规则名称" required>
              <el-input v-model="formData.name" placeholder="例如：高危焦虑评分连续升高" />
            </el-form-item>
            <el-form-item label="规则描述">
              <el-input v-model="formData.description" type="textarea" :rows="2" placeholder="请输入规则描述..." maxlength="100" show-word-limit />
            </el-form-item>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="所属分类">
                  <el-select v-model="formData.category" style="width: 100%">
                    <el-option label="心理情绪" value="psychology" />
                    <el-option label="体征数据" value="physical" />
                    <el-option label="饮食营养" value="diet" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="规则优先级">
                  <el-radio-group v-model="formData.priority">
                    <el-radio-button value="P0">P0</el-radio-button>
                    <el-radio-button value="P1">P1</el-radio-button>
                    <el-radio-button value="P2">P2</el-radio-button>
                  </el-radio-group>
                </el-form-item>
              </el-col>
            </el-row>
          </el-form>
        </el-card>

        <!-- 面板2：触发条件 -->
        <el-card v-show="currentStep === 1" shadow="never" class="form-card">
          <template #header>
            <div class="card-header">
              <span class="card-title"><i class="ri-flashlight-fill text-orange"></i> 触发条件</span>
              <el-radio-group v-model="formData.logic" size="small">
                <el-radio-button value="AND">满足全部 (且)</el-radio-button>
                <el-radio-button value="OR">任一 (或)</el-radio-button>
              </el-radio-group>
            </div>
          </template>

          <!-- 动态条件行 -->
          <div v-for="(cond, index) in formData.conditions" :key="index" class="condition-row">
            <span class="index-num">{{ index + 1 }}</span>
            <el-select v-model="cond.field" placeholder="选择指标" style="width: 180px">
              <el-option label="GAD-7 总分" value="gad7.total" />
              <el-option label="评分环比变化" value="gad7.delta" />
              <el-option label="睡眠时长" value="sleep.duration" />
            </el-select>
            <el-select v-model="cond.operator" placeholder="大于等于" style="width: 120px">
              <el-option label="大于等于" value="gte" />
              <el-option label="小于等于" value="lte" />
            </el-select>
            <el-input v-model="cond.value" placeholder="数值" style="width: 100px" />
            <span>分</span>
            <el-button link type="danger" class="del-btn" @click="removeCondition(index)"><el-icon><i class="ri-delete-bin-line"></i></el-icon></el-button>
          </div>
          
          <el-button class="add-btn" plain style="width: 100%" @click="addCondition">
            <el-icon><i class="ri-add-line"></i></el-icon> 添加条件
          </el-button>

          <div class="stats-settings">
            <div class="setting-row">
              <span class="label">统计周期</span>
              <el-select v-model="formData.window.stat_period" size="small" style="width: 100px"><el-option label="近 14 天" value="14d" /></el-select>
              <span class="label" style="margin-left: 20px;">检查频率</span>
              <el-select v-model="formData.window.check_freq" size="small" style="width: 100px"><el-option label="实时检查" value="realtime" /></el-select>
              <span class="label" style="margin-left: 20px;">需连续满足</span>
              <el-select v-model="formData.window.consecutive" size="small" style="width: 80px"><el-option label="2 次" :value="2" /></el-select>
            </div>
          </div>
          
          <div class="warning-tip">
            <el-icon><i class="ri-error-warning-line"></i></el-icon>
            与「P0 高危焦虑评分连续升高」规则条件重复度较高，建议合并或调整阈值以避免重复预警。
          </div>
        </el-card>

        <!-- 面板3：风险分级与处理时效 -->
        <el-card v-show="currentStep === 2" shadow="never" class="form-card">
          <template #header>
            <div class="card-header">
              <span class="card-title"><i class="ri-alarm-warning-fill text-orange"></i> 风险分级与处理时效</span>
            </div>
          </template>

          <el-form :model="formData.grading" label-position="top">
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="风险等级" required>
                  <el-select v-model="formData.grading.level" style="width: 100%">
                    <el-option label="高风险 (高危)" value="high" />
                    <el-option label="中风险 (中危)" value="mid" />
                    <el-option label="低风险 (低危)" value="low" />
                  </el-select>
                  <div class="form-tip">默认跟随优先级：P0->高, P1->中, P2->低</div>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="首次跟进时限" required>
                  <el-select v-model="formData.grading.first_followup_hours" style="width: 100%">
                    <el-option label="4 小时内" :value="4" />
                    <el-option label="24 小时内" :value="24" />
                    <el-option label="48 小时内" :value="48" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="超时升级规则">
                  <el-switch v-model="formData.grading.escalate" active-text="超时通知组长" inactive-text="不升级" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="计时规则">
                  <el-radio-group v-model="formData.grading.timer_rule">
                    <el-radio value="all_day">全天计时</el-radio>
                    <el-radio value="work_time">仅工作时段</el-radio>
                  </el-radio-group>
                </el-form-item>
              </el-col>
            </el-row>
          </el-form>
        </el-card>

        <!-- 面板4：通知策略 -->
        <el-card v-show="currentStep === 3" shadow="never" class="form-card">
          <template #header>
            <div class="card-header">
              <span class="card-title"><i class="ri-notification-3-fill text-blue"></i> 通知策略</span>
            </div>
          </template>

          <el-form :model="formData.notify" label-position="top">
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="接收人" required>
                  <el-select v-model="formData.notify.receiver" style="width: 100%">
                    <el-option label="用户归属顾问 (默认)" value="owner" />
                    <el-option label="指定顾问" value="specific" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="通知渠道" required>
                  <el-checkbox-group v-model="formData.notify.channels">
                    <el-checkbox label="站内信" value="inner" />
                    <el-checkbox label="企业微信" value="wechat" />
                    <el-checkbox label="短信" value="sms" />
                  </el-checkbox-group>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="发送时机">
                  <el-select v-model="formData.notify.send_time" style="width: 100%">
                    <el-option label="即时发送" value="immediate" />
                    <el-option label="每日汇总" value="daily" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="免打扰设置">
                  <el-switch v-model="formData.notify.quiet_hours" active-text="22:00 - 08:00 延迟" inactive-text="关闭" />
                </el-form-item>
              </el-col>
            </el-row>
          </el-form>
        </el-card>
      </div>

      <!-- ============ 右侧预览区 ============ -->
      <div class="right-preview">
        <el-card shadow="never" class="preview-card">
          <template #header>
            <div class="card-header">
              <span class="card-title">规则摘要</span>
              <el-button link type="primary" size="small">实时更新</el-button>
            </div>
          </template>
          <div class="summary-content">
            <p>{{ generateSummaryText() }}</p>
            <p class="sub-text">在近 {{ formData.window.stat_period === '14d' ? '14' : '7' }} 天内连续 {{ formData.window.consecutive }} 次满足。</p>
            <div class="tag-row">
              <el-tag :type="formData.grading.level === 'high' ? 'danger' : 'info'" size="small">
                {{ formData.grading.level === 'high' ? '高风险' : '中风险' }}
              </el-tag>
              <span class="small-text">要求 {{ formData.grading.first_followup_hours }} 小时内跟进</span>
            </div>
          </div>
        </el-card>

        <el-card shadow="never" class="preview-card">
          <template #header><div class="card-header"><span class="card-title">预计影响测算</span></div></template>
          <div class="calc-row">
            <div class="calc-item"><div class="num">42</div><div class="desc">预计命中用户</div></div>
            <div class="calc-item"><div class="num">58</div><div class="desc">预计预警条数</div></div>
          </div>
        </el-card>

        <!-- 💡 核心修改：发布前检查严格跟随 currentStep -->
        <el-card shadow="never" class="preview-card">
          <template #header><div class="card-header"><span class="card-title">发布前检查</span></div></template>
          <ul class="check-list">
            <!-- 第1步 -->
            <li :class="formData.name.trim() !== '' ? 'checked' : 'warning'">
              <i :class="formData.name.trim() !== '' ? 'ri-checkbox-circle-fill' : 'ri-error-warning-fill'"></i> 规则名称{{ formData.name.trim() !== '' ? '已填写' : '未填写' }}
            </li>
            <!-- 第2步 -->
            <li :class="formData.conditions.length > 0 ? 'checked' : 'warning'">
              <i :class="formData.conditions.length > 0 ? 'ri-checkbox-circle-fill' : 'ri-error-warning-fill'"></i> 触发条件已配置
            </li>
            <!-- 第3步：必须走到 currentStep >= 2 并且选了等级才算完成 -->
            <li :class="(currentStep >= 2 && formData.grading.level) ? 'checked' : 'warning'">
              <i :class="(currentStep >= 2 && formData.grading.level) ? 'ri-checkbox-circle-fill' : 'ri-error-warning-fill'"></i> 风险分级已设置
            </li>
            <!-- 第4步：必须走到 currentStep >= 3 并且选了接收人和渠道才算完成 -->
            <li :class="(currentStep >= 3 && formData.notify.receiver && formData.notify.channels.length > 0) ? 'checked' : 'warning'">
              <i :class="(currentStep >= 3 && formData.notify.receiver && formData.notify.channels.length > 0) ? 'ri-checkbox-circle-fill' : 'ri-error-warning-fill'"></i> 
              通知策略已配置 
              <span v-if="currentStep >= 3 && !formData.notify.receiver" style="color:#EF4444; margin-left: 4px;">(缺接收人)</span>
            </li>
          </ul>
        </el-card>
      </div>
    </div>

    <!-- 4. 底部固定操作栏 -->
    <div class="bottom-bar">
      <span class="save-tip"><i class="ri-time-line"></i> 自动保存中...</span>
      <div class="btns">
        <el-button @click="goBack">取消</el-button>
        <!-- 动态按钮 -->
        <el-button v-if="currentStep < 3" type="primary" @click="nextStep">
          下一步：{{ nextStepTitle }} <el-icon><i class="ri-arrow-right-line"></i></el-icon>
        </el-button>
        <el-button v-else type="primary" @click="submitAll">
          保存并启用 <el-icon><i class="ri-check-line"></i></el-icon>
        </el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { saveWarningRule } from '@/api/admin'


const router = useRouter()
const currentStep = ref(0)

const formData = reactive({
  name: '', 
  description: '',
  category: 'psychology',
  priority: 'P0',
  logic: 'AND',
  conditions: [],
  window: { stat_period: '14d', check_freq: 'realtime', consecutive: 2 },
  grading: { 
    level: '', 
    first_followup_hours: 4, 
    escalate: true, 
    timer_rule: 'all_day' 
  },
  notify: { 
    receiver: '', 
    channels: [], 
    send_time: 'immediate', 
    quiet_hours: true 
  }
})

const nextStepTitle = computed(() => {
  if (currentStep.value === 0) return '触发条件'
  if (currentStep.value === 1) return '风险分级'
  if (currentStep.value === 2) return '通知策略'
  return ''
})

const addCondition = () => {
  formData.conditions.push({ field: '', operator: 'gte', value: '' })
}

const removeCondition = (index) => {
  formData.conditions.splice(index, 1)
}

const goBack = () => {
  router.back()
}

const nextStep = () => {
  if (currentStep.value === 0 && !formData.name.trim()) {
    ElMessage.warning('请填写规则名称')
    return
  }
  if (currentStep.value === 1 && formData.conditions.length === 0) {
    ElMessage.warning('请至少添加一个触发条件')
    return
  }
  if (currentStep.value === 2 && !formData.grading.level) {
    ElMessage.warning('请选择风险等级')
    return
  }
  if (currentStep.value < 3) {
    currentStep.value++
  }
}

// 💡 核心修改：保存提交逻辑
const submitAll = async () => {
  if (!formData.notify.receiver) return ElMessage.warning('请指定通知接收人')
  if (formData.notify.channels.length === 0) return ElMessage.warning('请至少选择一个通知渠道')

  try {
    // 💡 真实调用后端接口，把 formData 传过去
    await saveWarningRule(formData)
    ElMessage.success('保存成功！')
    router.push('/back/risk-alerts') // 或者回到规则列表
  } catch (error) {
    ElMessage.error('保存失败，请检查后端')
    console.error(error)
  }
}
  
 


const generateSummaryText = () => {
  if (formData.conditions.length === 0) return '请添加条件'
  
  const logicText = formData.logic === 'AND' ? ' 且 ' : ' 或 '
  
  const fieldMap = {
    'gad7.total': 'GAD-7 总分',
    'gad7.delta': '评分环比变化',
    'sleep.duration': '睡眠时长'
  }
  const opMap = {
    'gte': '≥',
    'lte': '≤'
  }

  return '当 ' + formData.conditions.map(c => 
    `【${fieldMap[c.field] || c.field} ${opMap[c.operator] || c.operator} ${c.value} 分】`
  ).join(logicText)
}
</script>

<style scoped lang="scss">
/* 样式保持你原来的不变，这里只做简写 */
.rule-config-page {
  display: flex; flex-direction: column; background-color: #F5F7F9; min-height: 100vh; padding-bottom: 80px;
  .top-bar { display: flex; justify-content: space-between; align-items: center; padding: 16px 24px; background: #FFF; border-bottom: 1px solid #E2E8F0; }
  .step-bar { background: #FFF; padding: 20px 40px; border-bottom: 1px solid #E2E8F0; margin-bottom: 20px; }
  .main-content { display: flex; gap: 20px; padding: 0 24px; max-width: 1400px; margin: 0 auto; width: 100%; }
  .left-form { flex: 1; }
  .right-preview { width: 320px; }
  .form-card { border-radius: 8px; border: none; }
  .form-tip { font-size: 12px; color: #94A3B8; margin-top: 4px; }
  .condition-row { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; background: #F8FAFC; padding: 12px; border-radius: 6px; }
  .stats-settings { background: #F8FAFC; padding: 16px; border-radius: 6px; margin-top: 16px; }
  .warning-tip { margin-top: 16px; padding: 12px; background: #FEF3C7; color: #D97706; border-radius: 6px; font-size: 13px; }
  .preview-card { border-radius: 8px; border: none; margin-bottom: 16px; }
  .calc-row { display: flex; gap: 20px; text-align: center; .num { font-size: 24px; font-weight: 600; color: #2563EB; } }
  .check-list { list-style: none; padding: 0; margin: 0; li { font-size: 13px; display: flex; align-items: center; gap: 8px; margin-bottom: 12px; } .checked { color: #10B981; } .warning { color: #F59E0B; } }
  .bottom-bar { position: fixed; bottom: 0; left: 0; right: 0; height: 64px; background: #FFF; border-top: 1px solid #E2E8F0; display: flex; justify-content: space-between; align-items: center; padding: 0 24px; z-index: 10; }
}

.text-green { color: #10B981; }
.text-orange { color: #F59E0B; }
.text-blue { color: #2563EB; }
</style>