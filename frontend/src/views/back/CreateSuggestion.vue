<template>
  <div class="create-suggestion-page">
    <!-- 1. 顶部操作栏 -->
    <div class="top-bar">
      <div class="title-area">
        <el-icon class="back-icon" @click="goBack"><i class="ri-arrow-left-line"></i></el-icon>
        <h2>新建建议文案</h2>
        <span class="sub-title">为指定量表与风险等级创建建议文案，支持变量占位与多语言</span>
      </div>
      <div class="action-area">
        <el-button @click="goBack">取消</el-button>
        <!-- 💡 核心修改：绑定 saveDraft 事件 -->
        <el-button class="btn-export" @click="saveDraft">保存草稿</el-button>
        <el-button type="primary" class="btn-add" @click="submitForm">提交审核</el-button>
      </div>
    </div>

    <!-- 2. 步骤条（💡 已修复：动态显示绿色打勾） -->
    <div class="step-bar">
      <el-steps :active="currentStep" align-center>
        <el-step 
          title="基础信息" 
          :status="currentStep > 0 ? 'success' : (currentStep === 0 ? 'process' : 'wait')" 
        />
        <el-step 
          title="触发条件" 
          :status="currentStep > 1 ? 'success' : (currentStep === 1 ? 'process' : 'wait')" 
        />
        <el-step 
          title="文案内容" 
          :status="currentStep > 2 ? 'success' : (currentStep === 2 ? 'process' : 'wait')" 
        />
        <el-step 
          title="发布设置" 
          :status="currentStep === 3 ? 'process' : 'wait'" 
        />
      </el-steps>
    </div>

    <!-- 3. 主体内容区 -->
    <div class="main-content">
      
      <!-- ============ 左侧表单区 ============ -->
      <div class="left-form">
        
        <!-- 面板1：基础信息 -->
        <el-card shadow="never" class="form-card">
          <template #header>
            <div class="card-header">
              <span class="card-title"><i class="ri-file-text-line text-blue"></i> 基础信息</span>
            </div>
          </template>

          <el-form :model="formData" label-position="top">
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="文案标题" required>
                  <el-input v-model="formData.title" placeholder="请输入文案标题" />
                  <div class="form-tip">建议 10-30 字，将展示在列表与审计日志中</div>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="文案编码" required>
                  <el-input v-model="formData.code" placeholder="例如：COPY_GAD7_HIGH" />
                  <div class="form-tip">支持大写字母、数字与下划线，创建后不可修改</div>
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="关联量表" required>
                  <el-select v-model="formData.scaleName" style="width: 100%">
                    <el-option label="GAD-7 焦虑自评量表 (v2.1)" value="GAD-7" />
                    <el-option label="PHQ-9 抑郁自评量表" value="PHQ-9" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="适用分类">
                  <el-select v-model="formData.category" style="width: 100%">
                    <el-option label="焦虑" value="anxiety" />
                    <el-option label="抑郁" value="depression" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="风险等级" required>
                  <el-radio-group v-model="formData.riskLevel">
                    <el-radio-button label="低风险" value="低风险" />
                    <el-radio-button label="中风险" value="中风险" />
                    <el-radio-button label="高风险" value="高风险" />
                  </el-radio-group>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="语气风格">
                  <el-select v-model="formData.tone" style="width: 100%">
                    <el-option label="温和共情（推荐-高风险）" value="温和共情" />
                    <el-option label="专业说明" value="专业说明" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>

            <el-form-item label="展示位置">
              <el-checkbox-group v-model="formData.displayPositions">
                <el-checkbox label="测评结果页主卡" value="main" />
                <el-checkbox label="建议列表次要卡" value="secondary" />
                <el-checkbox label="每日健康卡片" value="daily" />
                <el-checkbox label="AI 对话开场白" value="ai" />
              </el-checkbox-group>
            </el-form-item>
          </el-form>
        </el-card>

        <!-- 面板2：触发条件 -->
        <el-card shadow="never" class="form-card">
          <template #header>
            <div class="card-header">
              <span class="card-title"><i class="ri-flashlight-fill text-orange"></i> 触发条件</span>
              <el-radio-group v-model="formData.logic" size="small">
                <el-radio-button label="满足全部 (AND)" value="AND" />
                <el-radio-button label="任一满足 (OR)" value="OR" />
              </el-radio-group>
            </div>
          </template>

          <div v-for="(cond, index) in formData.conditions" :key="index" class="condition-row">
            <span class="index-num">{{ index + 1 }}</span>
            <el-select v-model="cond.field" placeholder="选择字段" style="width: 150px">
              <el-option label="总分" value="total" />
              <el-option label="第 7 题得分" value="q7" />
            </el-select>
            <el-select v-model="cond.operator" placeholder="操作符" style="width: 100px">
              <el-option label=">=" value="gte" />
              <el-option label="<=" value="lte" />
            </el-select>
            <el-input v-model="cond.value" placeholder="数值" style="width: 100px" />
            <span class="unit">分</span>
            <el-button link type="danger" class="del-btn" @click="removeCondition(index)"><el-icon><i class="ri-delete-bin-line"></i></el-icon></el-button>
          </div>
          
          <el-button class="add-btn" plain style="width: 100%" @click="addCondition">
            <el-icon><i class="ri-add-line"></i></el-icon> 添加条件
          </el-button>

          <div class="warning-tip">
            <el-icon><i class="ri-error-warning-line"></i></el-icon>
            当前条件与「PHQ-9 中度抑郁建议」存在重叠区间，建议补充优先级设置（数字越大越优先）。
            <el-input-number v-model="formData.priority" :min="1" :max="100" size="small" style="width: 100px; margin-left: 10px;" />
          </div>
        </el-card>

        <!-- 面板3：文案内容 -->
        <el-card shadow="never" class="form-card">
          <template #header>
            <div class="card-header">
              <span class="card-title"><i class="ri-edit-line text-blue"></i> 文案内容</span>
              <el-button 
                link 
                type="primary" 
                size="small" 
                @click="handleAiPolish"
                :loading="isAiPolishing"
              >
                <el-icon v-if="!isAiPolishing"><i class="ri-magic-line"></i></el-icon>
                {{ isAiPolishing ? 'AI 润色中...' : 'AI 辅助润色' }}
              </el-button>
            </div>
          </template>

          <div class="variable-bar">
            <span>插入变量：</span>
            <el-tag v-for="v in variables" :key="v" size="small" type="info" effect="plain" class="var-tag" @click="insertVariable(v)">
              {{ v }}
            </el-tag>
            <div class="char-count">已输入 {{ formData.content.length }} / 300 字</div>
          </div>

          <el-input
            v-model="formData.content"
            type="textarea"
            :rows="8"
            placeholder="请输入建议文案内容，支持变量占位符..."
            resize="none"
          />
        </el-card>
      </div>

      <!-- ============ 右侧预览区 ============ -->
      <div class="right-preview">
        <!-- 预览卡片1：C 端效果预览 -->
        <el-card shadow="never" class="preview-card">
          <template #header>
            <div class="card-header">
              <span class="card-title"><i class="ri-smartphone-line"></i> C 端效果预览</span>
              <el-button link type="primary" size="small">手机预览</el-button>
            </div>
          </template>
          
          <div class="phone-preview">
            <div class="phone-header">
              <span>9:41</span>
              <div class="icons"><i class="ri-signal-tower-line"></i><i class="ri-wifi-line"></i><i class="ri-battery-line"></i></div>
            </div>
            
            <div class="preview-body">
              <div class="tag-row">
                <el-tag :type="formData.riskLevel === '高风险' ? 'danger' : 'warning'" size="small" effect="dark">{{ formData.riskLevel }}</el-tag>
                <el-tag type="danger" size="small" effect="plain">{{ formData.scaleName }} 自评</el-tag>
              </div>
              <div class="score-box">
                <span class="score-num">17</span>
                <span class="score-unit">/ 21 分</span>
              </div>
              <p class="score-desc">您的{{ formData.category === 'anxiety' ? '焦虑' : '心理' }}水平处于需要关注的区间</p>
              
              <div class="suggestion-box">
                <div class="box-title"><i class="ri-heart-3-fill text-red"></i> 给你的建议</div>
                <div class="content-preview">{{ formData.content || '在上方输入文案后，这里将实时展示...' }}</div>
              </div>
              
              <el-button type="primary" class="btn-action" round>开始呼吸练习</el-button>
            </div>
          </div>
        </el-card>

        <!-- 预览卡片2：命中逻辑模拟 -->
        <el-card shadow="never" class="preview-card">
          <template #header>
            <div class="card-header"><span class="card-title"><i class="ri-shield-check-line"></i> 命中逻辑模拟</span></div>
          </template>
          <div class="logic-check">
            <div class="check-row">
              <span>总分</span>
              <span class="val">17 分</span>
            </div>
            <div class="check-row">
              <span>第 7 题得分（评估中）</span>
              <span class="val text-orange">2 分</span>
            </div>
            <div class="result-box bg-green">
              <i class="ri-checkbox-circle-fill text-green"></i> 条件已匹配（优先级 {{ formData.priority }}）
            </div>
            <div class="result-box bg-orange">
              <i class="ri-error-warning-fill text-orange"></i> 与另外 1 条文案存在竞争
            </div>
          </div>
        </el-card>

        <!-- 预览卡片3：踩坑要点 -->
        <el-card shadow="never" class="preview-card bg-gray">
          <template #header>
            <div class="card-header"><span class="card-title"><i class="ri-alert-line"></i> 踩坑要点</span></div>
          </template>
          <ul class="tips-list">
            <li>① 内容避免出现「诊断」「处方」等医疗指令化句式。</li>
            <li>② 涉及「自伤/自杀」等词汇时，请务必使用安全文案。</li>
          </ul>
        </el-card>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, reactive, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { saveSuggestionTemplate } from '@/api/admin'

const router = useRouter()
const currentStep = ref(0)
const goBack = () => router.back()

const formData = reactive({
  title: 'GAD-7 高分安抚文案',
  code: 'COPY_GAD7_HIGH',
  scaleName: 'GAD-7',
  category: 'anxiety',
  riskLevel: '高风险',
  tone: '温和共情',
  displayPositions: ['main'],
  logic: 'AND',
  conditions: [
    { field: 'total', operator: 'gte', value: '15' },
    { field: 'q7', operator: 'gte', value: '0' }
  ],
  priority: 90,
  content: '亲爱的{user_name}，您在{scale_name}中的总分为{score}，提示近期焦虑水平偏高。\n\n建议先尝试 4-7-8 呼吸练习，每次 3 次；若两周后仍感到明显紧张，可以考虑预约专业心理咨询。'
})

const variables = ['{user_name}', '{scale_name}', '{score}', '{risk_level}', '{next_action}', '{hotline}']

const addCondition = () => {
  formData.conditions.push({ field: '', operator: 'gte', value: '' })
}
const removeCondition = (index) => {
  formData.conditions.splice(index, 1)
}
const insertVariable = (val) => {
  formData.content += val
}

// 💡 监听表单状态，动态改变步骤条
watch(
  () => formData,
  (newVal) => {
    if (newVal.title && newVal.code) currentStep.value = 1
    if (newVal.conditions.length > 0) currentStep.value = 2
    if (newVal.content) currentStep.value = 3
  },
  { deep: true }
)

// 💡 AI 辅助润色功能
const isAiPolishing = ref(false)

const handleAiPolish = () => {
  if (!formData.content.trim()) {
    return ElMessage.warning('请先输入需要润色的文案内容')
  }

  isAiPolishing.value = true
  
  setTimeout(() => {
    const polished = `【专业润色版】\n${formData.content}\n\n请相信，这段情绪的波动是暂时的。我们建议您采取上述行动，如有任何不适，请随时联系您的专属顾问或拨打心理援助热线 {hotline}。`
    formData.content = polished
    isAiPolishing.value = false
    ElMessage.success('AI 润色完成！')
  }, 1200)
}

// ==========================================
// 💡 核心新增：保存草稿逻辑 (不做必填校验)
// ==========================================
const saveDraft = async () => {
  // 如果没填标题，给个默认名字
  const draftTitle = formData.title || '未命名草稿'
  const draftCode = formData.code || `DRAFT_${Date.now()}`
  
  try {
    await saveSuggestionTemplate({
      title: draftTitle,
      code: draftCode,
      scaleName: formData.scaleName,
      triggerCondition: formData.conditions.map(c => `${c.field} ${c.operator} ${c.value}`).join(' 且 '),
      riskLevel: formData.riskLevel,
      tone: formData.tone,
      content: formData.content
    })
    ElMessage.success('草稿保存成功！')
    router.push('/back/suggestion-templates') // 存完跳回列表页
  } catch (e) {
    ElMessage.error('保存草稿失败，请检查后端')
  }
}

// ==========================================
// 💡 提交保存逻辑 (需要校验必填项)
// ==========================================
const submitForm = async () => {
  if (!formData.title || !formData.code) {
    return ElMessage.warning('请填写完整标题和编码')
  }
  if (!formData.content) {
    return ElMessage.warning('请填写文案内容')
  }
  try {
    const conditionStr = formData.conditions.map(c => `${c.field} ${c.operator} ${c.value}`).join(' 且 ')
    
    await saveSuggestionTemplate({
      title: formData.title,
      code: formData.code,
      scaleName: formData.scaleName,
      triggerCondition: conditionStr,
      riskLevel: formData.riskLevel,
      tone: formData.tone,
      content: formData.content
    })
    ElMessage.success('提交审核成功！')
    router.push('/back/suggestion-templates')
  } catch (e) {
    ElMessage.error('提交失败，请检查后端')
  }
}
</script>

<style scoped lang="scss">
/* 这里保留你之前所有的样式，没有任何修改 */
.create-suggestion-page {
  display: flex;
  flex-direction: column;
  background-color: #F5F7F9;
  min-height: 100vh;
  padding-bottom: 80px;

  .top-bar {
    display: flex; justify-content: space-between; align-items: center;
    padding: 16px 24px; background: #FFF; border-bottom: 1px solid #E2E8F0;
    .title-area {
      display: flex; align-items: center; gap: 10px;
      h2 { margin: 0; font-size: 18px; font-weight: 600; color: #111827; }
      .sub-title { font-size: 13px; color: #94A3B8; }
      .back-icon { cursor: pointer; font-size: 20px; color: #64748B; &:hover { color: #2563EB; } }
    }
    .action-area {
      display: flex; gap: 12px;
      .el-button { height: 36px; border-radius: 6px; margin: 0; }
      .btn-export { background: #FFF; border: 1px solid #E2E8F0; color: #475569; &:hover { color: #2563EB; border-color: #2563EB; } }
      .btn-add { background: #2563EB; border: none; &:hover { background: #1D4ED8; } }
    }
  }

  .step-bar {
    background: #FFF; padding: 20px 40px; border-bottom: 1px solid #E2E8F0; margin-bottom: 20px;
  }

  .main-content {
    display: flex; gap: 20px; padding: 0 24px; width: 100%; max-width: 1400px; margin: 0 auto;
    .left-form { flex: 1; display: flex; flex-direction: column; gap: 16px; }
    .right-preview { width: 360px; display: flex; flex-direction: column; gap: 16px; }
  }

  .form-card {
    border-radius: 8px; border: none;
    .card-header {
      display: flex; justify-content: space-between; align-items: center;
      .card-title { font-weight: 600; font-size: 15px; display: flex; align-items: center; gap: 6px; }
    }
    .form-tip { font-size: 12px; color: #94A3B8; margin-top: 4px; }
  }

  .text-blue { color: #2563EB; }
  .text-orange { color: #F59E0B; }
  .text-red { color: #EF4444; }
  .text-green { color: #10B981; }

  .condition-row {
    display: flex; align-items: center; gap: 12px; margin-bottom: 12px;
    background: #F8FAFC; padding: 12px; border-radius: 6px;
    .index-num { width: 24px; height: 24px; background: #E2E8F0; color: #475569; border-radius: 4px; display: flex; justify-content: center; align-items: center; font-size: 12px; font-weight: 600; }
    .unit { color: #64748B; }
    .del-btn { margin-left: auto; }
  }
  .add-btn { margin-bottom: 16px; }

  .warning-tip {
    display: flex; align-items: center; gap: 8px;
    background: #FEF3C7; color: #D97706; padding: 12px; border-radius: 6px; font-size: 13px;
  }

  .variable-bar {
    display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-bottom: 12px;
    span { font-size: 13px; color: #64748B; }
    .var-tag { cursor: pointer; background: #F1F5F9; border-color: #E2E8F0; &:hover { color: #2563EB; border-color: #2563EB; } }
    .char-count { margin-left: auto; font-size: 12px; color: #94A3B8; }
  }

  .preview-card {
    border-radius: 8px; border: none;
    .card-header {
      display: flex; justify-content: space-between; align-items: center;
      .card-title { font-weight: 600; font-size: 14px; display: flex; align-items: center; gap: 6px; }
    }
    &.bg-gray { background: #F8FAFC; }
  }

  .phone-preview {
    background: #FFF; border-radius: 24px; border: 8px solid #111827; overflow: hidden; width: 280px; margin: 0 auto;
    .phone-header {
      display: flex; justify-content: space-between; padding: 8px 16px; font-size: 12px; font-weight: 600; color: #111827;
      .icons { display: flex; gap: 4px; }
    }
    .preview-body {
      padding: 16px;
      .tag-row { display: flex; gap: 8px; margin-bottom: 12px; }
      .score-box {
        display: flex; align-items: baseline; gap: 6px;
        .score-num { font-size: 32px; font-weight: 700; color: #111827; }
        .score-unit { font-size: 12px; color: #94A3B8; }
      }
      .score-desc { font-size: 12px; color: #64748B; margin: 4px 0 16px; }
      .suggestion-box {
        background: #FEF2F2; border-radius: 8px; padding: 12px; margin-bottom: 16px;
        .box-title { font-size: 13px; font-weight: 600; color: #991B1B; display: flex; align-items: center; gap: 4px; margin-bottom: 8px; }
        .content-preview { font-size: 13px; color: #475569; line-height: 1.6; white-space: pre-wrap; }
      }
      .btn-action { width: 100%; }
    }
  }

  .logic-check {
    .check-row {
      display: flex; justify-content: space-between; font-size: 13px; padding: 8px 0; border-bottom: 1px dashed #E2E8F0;
      .val { font-weight: 600; }
    }
    .result-box {
      display: flex; align-items: center; gap: 6px; font-size: 12px; padding: 10px; border-radius: 6px; margin-top: 12px;
      &.bg-green { background: #ECFDF5; color: #065F46; }
      &.bg-orange { background: #FFFBEB; color: #92400E; }
    }
  }

  .tips-list {
    list-style: none; padding: 0; margin: 0;
    li { font-size: 12px; color: #64748B; margin-bottom: 8px; line-height: 1.5; }
  }
}
</style>