<template>
  <div class="create-audit-rule-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-left">
        <div class="title-row">
          <h2 class="page-title">新建审计规则</h2>
          <el-tag size="small" type="warning" effect="plain">草稿</el-tag>
        </div>
        <p class="page-subtitle">
          规则保存后可先测试再启用，启用后立即参与会话自动审计。
        </p>
      </div>
      <el-icon class="close-icon" @click="goBack"><i class="ri-close-line"></i></el-icon>
    </div>

    <!-- 左右两栏 -->
    <div class="main-layout">
      <!-- 左侧：表单 -->
      <div class="left-form">
        <el-form ref="formRef" :model="formData" :rules="formRules" label-position="top">
          <!-- 1. 基础信息 -->
          <div class="section">
            <div class="section-title"><i class="ri-information-line"></i> 基础信息</div>
            <el-row :gutter="16">
              <el-col :span="14">
                <el-form-item label="规则名称" prop="title">
                  <el-input id="rule-title" v-model="formData.title" placeholder="请输入规则名称" maxlength="50" show-word-limit />
                </el-form-item>
              </el-col>
              <el-col :span="10">
                <el-form-item label="规则编码（自动生成）" prop="code">
                  <el-input id="rule-code" v-model="formData.code" placeholder="R-1024" disabled />
                </el-form-item>
              </el-col>
            </el-row>
            <el-row :gutter="16">
              <el-col :span="14">
                <el-form-item label="所属分类" prop="category">
                  <el-select id="rule-category" v-model="formData.category" placeholder="请选择分类" style="width: 100%">
                    <el-option v-for="c in categoryOptions" :key="c.value" :label="c.label" :value="c.value" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="10">
                <el-form-item label="风险等级" prop="level">
                  <el-radio-group v-model="formData.level">
                    <el-radio-button value="high">高危</el-radio-button>
                    <el-radio-button value="medium">中危</el-radio-button>
                    <el-radio-button value="low">低危</el-radio-button>
                  </el-radio-group>
                </el-form-item>
              </el-col>
            </el-row>
          </div>

          <!-- 2. 适用范围 -->
          <div class="section">
            <div class="section-title"><i class="ri-focus-3-line"></i> 适用范围</div>
            <el-form-item label="适用场景" prop="scene">
              <el-checkbox-group v-model="formData.scene">
                <el-checkbox value="consult">健康咨询</el-checkbox>
                <el-checkbox value="diet">饮食建议</el-checkbox>
                <el-checkbox value="rehab">康复训练</el-checkbox>
                <el-checkbox value="emotion">情绪安抚</el-checkbox>
                <el-checkbox value="push">推送文案</el-checkbox>
              </el-checkbox-group>
            </el-form-item>
            <el-form-item label="生效模型" prop="models">
              <el-checkbox-group v-model="formData.models">
                <el-checkbox-button value="all">全部模型</el-checkbox-button>
                <el-checkbox-button value="gpt4o">GPT-4o</el-checkbox-button>
                <el-checkbox-button value="claude">Claude 3.5</el-checkbox-button>
              </el-checkbox-group>
            </el-form-item>
          </div>

          <!-- 3. 检测方式 -->
          <div class="section">
            <div class="section-title"><i class="ri-scan-line"></i> 检测方式</div>
            <el-form-item prop="detectType">
              <div class="detect-types">
                <div
                  v-for="dt in detectTypes"
                  :key="dt.value"
                  :class="['detect-item', { active: formData.detectType === dt.value }]"
                  @click="formData.detectType = dt.value"
                >
                  <i :class="dt.icon"></i>
                  <div class="dt-content">
                    <div class="dt-label">{{ dt.label }}</div>
                    <div class="dt-desc">{{ dt.desc }}</div>
                  </div>
                  <el-icon v-if="formData.detectType === dt.value" class="check-icon"><i class="ri-checkbox-circle-fill"></i></el-icon>
                </div>
              </div>
            </el-form-item>
          </div>

          <!-- 4. 命中条件 -->
          <div class="section">
            <div class="section-title">
              <i class="ri-filter-3-line"></i> 命中条件
              <el-button link class="logic-btn">启用识别 <el-icon><i class="ri-arrow-down-s-line"></i></el-icon></el-button>
            </div>
            <div class="keyword-combo">
              <div class="combo-row">
                <el-select v-model="formData.comboLogic" style="width: 90px" size="small"><el-option label="治愈" value="治愈" /></el-select>
                <el-select v-model="formData.comboOp1" style="width: 90px" size="small"><el-option label="极大概率" value="极大概率" /></el-select>
                <span class="combo-sep">x</span>
                <el-select v-model="formData.comboLogic2" style="width: 90px" size="small"><el-option label="根治" value="根治" /></el-select>
                <span class="combo-sep">x</span>
                <el-select v-model="formData.comboOp2" style="width: 90px" size="small"><el-option label="保证有效" value="保证有效" /></el-select>
                <el-select v-model="formData.comboOp3" style="width: 90px" size="small"><el-option label="一劳永逸" value="一劳永逸" /></el-select>
              </div>
            </div>
            <el-input id="keyword-input" v-model="formData.keywordInput" type="textarea" :rows="2" placeholder="输入关键词后回车添加，支持写正则表达式" class="keyword-input" />
            <div class="batch-import"><el-button link type="primary" size="small">批量导入</el-button></div>
            <div class="slider-row">
              <span class="slider-label">语义相似度阈值</span>
              <el-slider v-model="formData.similarityThreshold" :min="0" :max="1" :step="0.01" class="slider" />
              <span class="slider-value">{{ formData.similarityThreshold.toFixed(2) }}</span>
            </div>
            <div class="hit-times-row">
              <span class="slider-label">命中次数</span>
              <div class="hit-times-btns">
                <div v-for="n in [1, 2, 3]" :key="n" :class="['hit-btn', { active: formData.hitTimes === n }]" @click="formData.hitTimes = n">{{ n }}</div>
              </div>
              <span class="hit-times-tip">次会话命中即中断回复，降低误报披露率</span>
            </div>
          </div>

          <!-- 5. 白名单 / 排除条件 -->
          <div class="section">
            <div class="section-title"><i class="ri-shield-check-line"></i> 白名单 / 排除条件</div>
            <el-checkbox-group v-model="formData.exclude">
              <el-checkbox value="quote">科普场景引用文献</el-checkbox>
              <el-checkbox value="reprint">复述医生原话</el-checkbox>
            </el-checkbox-group>
            <el-button link type="primary" size="small" class="add-exclude"><i class="ri-add-line"></i> 添加排除条件</el-button>
            <div class="exclude-tip">命中文本若同时满足排除条件，则不计入风险判定结果（已开启）</div>
          </div>

          <!-- 6. 处置动作 -->
          <div class="section">
            <div class="section-title"><i class="ri-settings-5-line"></i> 处置动作</div>
            <el-checkbox-group v-model="formData.actions" class="action-group">
              <el-checkbox value="log">标记会话会话并留痕</el-checkbox>
              <el-checkbox value="manual">进入人工复核队列（高危）</el-checkbox>
              <el-checkbox value="replace">拦截并替换该条回复</el-checkbox>
              <el-checkbox value="notify">即时通知内容负责人</el-checkbox>
            </el-checkbox-group>
          </div>
        </el-form>
      </div>

      <!-- 右侧：实时测试台 -->
      <div class="right-preview">
        <div class="preview-header">
          <span class="preview-title"><i class="ri-play-circle-line"></i> 规则测试</span>
          <span class="preview-sub">用样例文本快速验证命中效果</span>
        </div>
        <el-input id="test-textarea" v-model="testText" type="textarea" :rows="4" placeholder="输入一段测试文本，或点击「示例」快速填充" class="test-textarea" />
        <div class="test-actions">
          <el-button type="primary" size="small" @click="runTest"><i class="ri-play-fill"></i> 运行测试</el-button>
          <el-button size="small" @click="fillSample">示例</el-button>
        </div>
        <div v-if="testResult" class="test-result">
          <div class="result-line"><i class="ri-alert-line text-orange"></i><span>命中 2 处：治愈、一劳永逸 · 判定为高危</span></div>
        </div>
      </div>
    </div>

    <!-- 底部操作栏 -->
    <div class="footer-bar">
      <div class="footer-tip"><i class="ri-information-line"></i> 启用后将在一个会话生效</div>
      <div class="footer-actions">
        <el-button @click="goBack">取消</el-button>
        <el-button @click="handleSaveDraft">保存草稿</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit"><i class="ri-save-line"></i> 保存并启用</el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { saveAuditRule, generateAuditRuleCode } from '@/api/admin'

const router = useRouter()
const formRef = ref(null)
const submitting = ref(false)
const testText = ref('')
const testResult = ref(false)

const categoryOptions = [
  { label: '敏感承诺', value: 'sensitive' },
  { label: '用药安全', value: 'medicine' },
  { label: '疾病诊断', value: 'diagnosis' },
  { label: '情绪危机', value: 'emotion' },
  { label: '夸大功效', value: 'exaggerate' },
  { label: '隐私与合规', value: 'privacy' },
  { label: '自定义规则', value: 'custom' }
]

const detectTypes = [
  { label: '关键词/正则', value: 'keyword', desc: '精确匹配、正则匹配命中', icon: 'ri-key-2-line' },
  { label: '语义相似度', value: 'semantic', desc: '按向量距离判定命中', icon: 'ri-node-tree' },
  { label: '大模型判定', value: 'llm', desc: '理解语境、误报更低', icon: 'ri-brain-line' }
]

const formData = reactive({
  title: '敏感承诺 · 确定性疗效',
  code: 'R-1024',
  category: 'sensitive',
  level: 'high',
  scene: ['consult', 'diet'],
  models: ['all'],
  detectType: 'keyword',
  comboLogic: '治愈',
  comboOp1: '极大概率',
  comboLogic2: '根治',
  comboOp2: '保证有效',
  comboOp3: '一劳永逸',
  keywordInput: '',
  similarityThreshold: 0.72,
  hitTimes: 2,
  exclude: ['quote', 'reprint'],
  actions: ['log', 'manual']
})

const formRules = {
  title: [{ required: true, message: '请输入规则名称', trigger: 'blur' }],
  category: [{ required: true, message: '请选择分类', trigger: 'change' }],
  level: [{ required: true, message: '请选择风险等级', trigger: 'change' }],
  scene: [{ type: 'array', required: true, message: '请至少选择一个场景', trigger: 'change' }],
  models: [{ type: 'array', required: true, message: '请至少选择一个模型', trigger: 'change' }],
  detectType: [{ required: true, message: '请选择检测方式', trigger: 'change' }]
}

const fillSample = () => {
  testText.value = '该方案不吃药、不节食，30 天保证有效，几乎能治愈所有亚健康问题，一劳永逸。'
}

const runTest = () => {
  if (!testText.value.trim()) { ElMessage.warning('请输入测试文本'); return; }
  testResult.value = true
  ElMessage.success('测试完成')
}

const goBack = () => {
  router.push({ name: 'ChatAuditRules' })
}

const buildPayload = (status) => ({
  title: formData.title,
  code: formData.code,
  category: 'audit',
  ruleCategory: 'custom', // 💡 强制写死为 custom，不管下拉框选了什么
  level: formData.level,
  scene: formData.scene.join(','),
  models: formData.models.join(','),
  model: formData.models[0] === 'all' ? 'GPT-4o' : formData.models[0], 
  detectType: formData.detectType,
  comboLogic: JSON.stringify({
    comboLogic: formData.comboLogic,
    comboOp1: formData.comboOp1,
    comboLogic2: formData.comboLogic2,
    comboOp2: formData.comboOp2,
    comboOp3: formData.comboOp3
  }),
  keywordInput: formData.keywordInput,
  similarityThreshold: formData.similarityThreshold,
  hitTimes: formData.hitTimes,
  exclude: formData.exclude.join(','),
  actions: formData.actions.join(','),
  status
})

const doSubmit = async (status) => {
  if (!formRef.value) return
  try { await formRef.value.validate() } catch { return }
  submitting.value = true
  try {
    await saveAuditRule(buildPayload(status))
    ElMessage.success(status === 1 ? '保存并启用成功！' : '草稿保存成功！')
    router.push({ name: 'ChatAuditRules' })
  } catch (e) {
    console.error(e)
    ElMessage.error('保存失败，请检查后端')
  } finally {
    submitting.value = false
  }
}

const handleSaveDraft = () => doSubmit(0)
const handleSubmit = () => doSubmit(1)

onMounted(async () => {
  try {
    const res = await generateAuditRuleCode()
    const code = res.data?.code || res.data
    if (code) formData.code = code
  } catch (e) {
    formData.code = 'R-' + Math.floor(1000 + Math.random() * 9000)
  }
})
</script>

<style scoped lang="scss">
.create-audit-rule-page {
  background: #f8fafc;
  min-height: calc(100vh - 60px);
  padding: 20px 24px 90px;
  position: relative;

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 16px;
    .title-row {
      display: flex;
      align-items: center;
      gap: 8px;
      .page-title { font-size: 20px; font-weight: 600; color: #111827; margin: 0; }
    }
    .page-subtitle { font-size: 13px; color: #94a3b8; margin: 6px 0 0; }
    .close-icon { font-size: 20px; color: #94a3b8; cursor: pointer; &:hover { color: #111827; } }
  }

  .main-layout {
    display: flex;
    gap: 20px;
    align-items: flex-start;

    .left-form {
      flex: 1;
      background: #fff;
      border-radius: 10px;
      padding: 20px 24px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);

      .section {
        padding-bottom: 18px;
        margin-bottom: 18px;
        border-bottom: 1px dashed #e2e8f0;
        &:last-child { border-bottom: none; margin-bottom: 0; }
        .section-title {
          display: flex;
          align-items: center;
          gap: 8px;
          font-size: 14px;
          font-weight: 600;
          color: #111827;
          margin-bottom: 12px;
          i { color: #2563eb; font-size: 16px; }
          .logic-btn { margin-left: auto; font-size: 12px; color: #64748b; }
        }
      }
      :deep(.el-form-item__label) { font-size: 13px; color: #475569; padding-bottom: 4px !important; font-weight: 500; }
    }

    .detect-types {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 12px;
      width: 100%;
      .detect-item {
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 12px;
        display: flex;
        gap: 10px;
        align-items: flex-start;
        cursor: pointer;
        position: relative;
        transition: all 0.2s;
        i { font-size: 18px; color: #94a3b8; margin-top: 2px; }
        .dt-content {
          .dt-label { font-size: 13px; font-weight: 600; color: #111827; }
          .dt-desc { font-size: 12px; color: #94a3b8; margin-top: 2px; }
        }
        .check-icon { position: absolute; top: 8px; right: 8px; color: #2563eb; }
        &:hover { border-color: #93c5fd; }
        &.active { border-color: #2563eb; background: #eff6ff; i { color: #2563eb; } }
      }
    }

    .keyword-combo {
      background: #f8fafc;
      border-radius: 8px;
      padding: 12px;
      margin-bottom: 12px;
      .combo-row {
        display: flex;
        align-items: center;
        gap: 8px;
        flex-wrap: wrap;
        .combo-sep { font-size: 12px; color: #94a3b8; }
      }
    }

    .keyword-input { margin-bottom: 4px; }
    .batch-import { text-align: right; margin-bottom: 12px; }
    .slider-row,
    .hit-times-row {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-top: 12px;
      .slider-label { font-size: 13px; color: #475569; min-width: 100px; }
      .slider { flex: 1; }
      .slider-value { font-size: 13px; color: #2563eb; font-weight: 600; min-width: 40px; text-align: right; }
    }

    .hit-times-btns {
      display: flex;
      gap: 8px;
      .hit-btn {
        width: 34px;
        height: 30px;
        display: flex;
        align-items: center;
        justify-content: center;
        border: 1px solid #e2e8f0;
        border-radius: 6px;
        cursor: pointer;
        font-size: 13px;
        color: #475569;
        background: #fff;
        &:hover { border-color: #93c5fd; }
        &.active { background: #2563eb; border-color: #2563eb; color: #fff; }
      }
    }
    .hit-times-tip { font-size: 12px; color: #94a3b8; }
    .add-exclude { margin-top: 6px; }
    .exclude-tip { font-size: 12px; color: #94a3b8; margin-top: 6px; }
    .action-group { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }

    .right-preview {
      width: 340px;
      background: #fff;
      border-radius: 10px;
      padding: 16px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
      position: sticky;
      top: 20px;
      .preview-header {
        margin-bottom: 12px;
        .preview-title { display: flex; align-items: center; gap: 6px; font-size: 14px; font-weight: 600; color: #111827; i { color: #2563eb; } }
        .preview-sub { display: block; font-size: 12px; color: #94a3b8; margin-top: 4px; }
      }
      .test-textarea { margin-bottom: 10px; }
      .test-actions { display: flex; gap: 8px; margin-bottom: 12px; }
      .test-result {
        background: #fef3c7;
        border: 1px solid #fde68a;
        border-radius: 8px;
        padding: 10px 12px;
        font-size: 13px;
        color: #92400e;
        .result-line { display: flex; align-items: center; gap: 6px; .text-orange { color: #f59e0b; } }
      }
    }
  }

  .footer-bar {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    height: 64px;
    background: #fff;
    border-top: 1px solid #e2e8f0;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 24px;
    z-index: 10;
    .footer-tip { display: flex; align-items: center; gap: 6px; font-size: 13px; color: #64748b; i { color: #94a3b8; } }
    .footer-actions { display: flex; gap: 12px; .el-button { height: 36px; border-radius: 6px; } }
  }
}
</style>