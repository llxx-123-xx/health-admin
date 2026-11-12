<template>
  <div class="create-prompt-page">
    <!-- 1. 顶部操作栏 -->
    <div class="top-bar">
      <div class="title-area">
        <el-icon class="back-icon" @click="goBack"><i class="ri-arrow-left-line"></i></el-icon>
        <h2>新建提示词模板</h2>
        <el-tag size="small" type="info" effect="plain">草稿</el-tag>
        <span class="sub-title">提示词即 AI 的“操作指南”，发布前请先在右侧测试</span>
      </div>
      <div class="action-area">
        <el-button @click="goBack">取消</el-button>
        <el-button class="btn-export">保存草稿</el-button>
        <el-button type="primary" class="btn-add" @click="submitForm">保存并测试</el-button>
      </div>
    </div>

    <!-- 2. 主体内容区（左右两栏） -->
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
                <el-form-item label="模板名称" required>
                  <el-input v-model="formData.title" placeholder="例如：睡眠改善建议 (中英文)" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="模板编码" required>
                  <el-input v-model="formData.code" placeholder="PROMPT_SLEEP_ADVICE" />
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="所属分类">
                  <el-select v-model="formData.category" style="width: 100%">
                    <el-option label="睡眠建议" value="sleep" />
                    <el-option label="情绪安抚" value="emotion" />
                    <el-option label="量表解读" value="scale" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="使用模型">
                  <el-select v-model="formData.model" style="width: 100%">
                    <el-option label="GPT-4o" value="gpt-4o" />
                    <el-option label="Qwen-Max (2048)" value="qwen-max" />
                    <el-option label="Claude 3.5 Sonnet" value="claude-3.5" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>

            <el-form-item label="用途简述">
              <el-input v-model="formData.description" type="textarea" :rows="2" placeholder="简述该提示词的应用场景..." />
            </el-form-item>
          </el-form>
        </el-card>

        <!-- 面板2：System Prompt -->
        <el-card shadow="never" class="form-card">
          <template #header>
            <div class="card-header">
              <span class="card-title"><i class="ri-robot-line text-purple"></i> System Prompt（角色与约束）</span>
              <span class="char-count">已输入 218 / 1000 字</span>
            </div>
          </template>
          
          <el-input
            v-model="formData.systemPrompt"
            type="textarea"
            :rows="5"
            placeholder="你是一名专业、温和的心理健康助手..."
            resize="none"
          />
          
          <div class="prompt-actions">
            <el-checkbox v-model="formData.useVariables">使用变量</el-checkbox>
            <el-checkbox v-model="formData.useFewShot">注入 Few-shot 示例</el-checkbox>
            <div class="right-actions">
              <el-button link type="primary" size="small">从模板库导入</el-button>
              <el-button link type="primary" size="small">一键优化</el-button>
            </div>
          </div>
        </el-card>

        <!-- 面板3：User Prompt -->
        <el-card shadow="never" class="form-card">
          <template #header>
            <div class="card-header">
              <span class="card-title"><i class="ri-chat-1-line text-blue"></i> User Prompt（变量模板）</span>
              <span class="char-count">已输入 75 / 2000 字</span>
            </div>
          </template>

          <div class="variable-bar">
            <span>插入变量：</span>
            <el-tag v-for="v in availableVariables" :key="v" size="small" type="info" effect="plain" class="var-tag" @click="insertVariable(v)">
              {{ v }}
            </el-tag>
          </div>

          <el-input
            v-model="formData.userPrompt"
            type="textarea"
            :rows="4"
            placeholder="请基于以下信息生成建议... {user_name} {scale_result}"
            resize="none"
          />
          
          <div class="prompt-actions">
            <el-checkbox v-model="formData.allowMultiTurn">允许多轮对话 (上下文感知)</el-checkbox>
            <el-checkbox v-model="formData.enableJson">强制 JSON 输出</el-checkbox>
          </div>
        </el-card>

        <!-- 面板4：变量定义 -->
        <el-card shadow="never" class="form-card">
          <template #header>
            <div class="card-header">
              <span class="card-title"><i class="ri-code-s-slash-line text-green"></i> 变量定义</span>
              <el-button link type="primary" size="small"><el-icon><i class="ri-add-line"></i></el-icon> 添加变量</el-button>
            </div>
          </template>
          
          <el-table :data="variableList" style="width: 100%" size="small" border>
            <el-table-column prop="name" label="变量名" width="120" />
            <el-table-column prop="type" label="类型" width="80" />
            <el-table-column prop="source" label="数据来源" width="120" />
            <el-table-column prop="desc" label="说明" />
            <el-table-column label="必填" width="60" align="center">
              <template #default="{ row }">
                <el-checkbox v-model="row.required" />
              </template>
            </el-table-column>
          </el-table>
        </el-card>

        <!-- 面板5：模型参数 -->
        <el-card shadow="never" class="form-card">
          <template #header>
            <div class="card-header">
              <span class="card-title"><i class="ri-settings-4-line text-orange"></i> 模型参数</span>
              <el-button link type="primary" size="small">恢复默认</el-button>
            </div>
          </template>

          <el-form :model="formData.params" label-position="top">
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item :label="`Temperature: ${formData.params.temperature}`">
                  <el-slider v-model="formData.params.temperature" :min="0" :max="1" :step="0.1" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item :label="`Top P: ${formData.params.topP}`">
                  <el-slider v-model="formData.params.topP" :min="0" :max="1" :step="0.1" />
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="Max Tokens">
                  <el-input-number v-model="formData.params.maxTokens" :min="100" :max="8000" :step="100" style="width: 100%" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="格式">
                  <el-radio-group v-model="formData.params.format">
                    <el-radio-button label="Text" value="text" />
                    <el-radio-button label="JSON" value="json" />
                  </el-radio-group>
                </el-form-item>
              </el-col>
            </el-row>
          </el-form>
        </el-card>

        <!-- 面板6：输出格式 (JSON Schema) -->
        <el-card shadow="never" class="form-card">
          <template #header>
            <div class="card-header">
              <span class="card-title"><i class="ri-brackets-line text-cyan"></i> 输出格式（JSON Schema）</span>
              <el-switch v-model="formData.enableSchema" active-text="Schema 校验" />
            </div>
          </template>
          
          <el-input
            v-model="formData.jsonSchema"
            type="textarea"
            :rows="6"
            placeholder="{ ... }"
            resize="none"
            class="code-editor"
          />
        </el-card>

        <!-- 面板7：安全护栏 -->
        <el-card shadow="never" class="form-card">
          <template #header>
            <div class="card-header">
              <span class="card-title"><i class="ri-shield-check-line text-green"></i> 安全护栏</span>
            </div>
          </template>

          <el-form :model="formData.safety" label-position="left" label-width="150px">
            <el-form-item label="敏感词过滤">
              <el-switch v-model="formData.safety.enableSensitiveFilter" />
            </el-form-item>
            <el-form-item label="禁止医疗诊断">
              <el-switch v-model="formData.safety.forbidMedicalDiagnosis" />
            </el-form-item>
            <el-form-item label="禁止负面引导">
              <el-switch v-model="formData.safety.forbidNegativeGuidance" />
            </el-form-item>
          </el-form>
        </el-card>

      </div>

      <!-- ============ 右侧预览测试区 ============ -->
      <div class="right-preview">
        <!-- 卡片1：实时调试 -->
        <el-card shadow="never" class="preview-card">
          <template #header>
            <div class="card-header">
              <span class="card-title"><i class="ri-play-circle-line text-blue"></i> 实时调试</span>
              <el-button type="primary" size="small" @click="runTest">运行测试</el-button>
            </div>
          </template>
          
          <div class="test-input">
            <div class="input-label">模拟用户输入：</div>
            <el-input v-model="testInput" type="textarea" :rows="3" placeholder="例如：我最近总是失眠，怎么办？" />
          </div>

          <div class="test-output">
            <div class="output-label">模型输出：</div>
            <div class="output-content">
              <p v-if="!testResult" class="placeholder-text">点击“运行测试”查看输出结果...</p>
              <p v-else>{{ testResult }}</p>
            </div>
          </div>
        </el-card>

        <!-- 卡片2：变量检测 -->
        <el-card shadow="never" class="preview-card">
          <template #header>
            <div class="card-header"><span class="card-title"><i class="ri-check-double-line text-green"></i> 变量检测</span></div>
          </template>
          <ul class="var-check-list">
            <li><i class="ri-checkbox-circle-fill text-green"></i> {user_name} 已定义</li>
            <li><i class="ri-checkbox-circle-fill text-green"></i> {scale_result} 已定义</li>
            <li><i class="ri-error-warning-fill text-orange"></i> {mood_tag} 未使用</li>
          </ul>
        </el-card>

        <!-- 卡片3：踩坑要点 -->
        <el-card shadow="never" class="preview-card bg-gray">
          <template #header>
            <div class="card-header"><span class="card-title"><i class="ri-alert-line text-orange"></i> 踩坑要点</span></div>
          </template>
          <ul class="tips-list">
            <li>① 不要在 Prompt 里写死用户信息，必须用变量。</li>
            <li>② 强制 JSON 时，请在系统提示词中说明格式。</li>
            <li>③ 如果涉及医疗建议，务必开启“禁止医疗诊断”。</li>
          </ul>
        </el-card>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { savePromptTemplate } from '@/api/admin'

const router = useRouter()
const goBack = () => router.back()

// 表单数据
const formData = reactive({
  title: '睡眠改善建议 (中英文)',
  code: 'PROMPT_SLEEP_ADVICE',
  category: 'sleep',
  model: 'qwen-max',
  description: '基于 PSQI 评分生成个性化睡眠改善计划，可用于对话开场或报告页附加建议。',
  systemPrompt: '你是一名专业的心理与睡眠健康助手。你的任务是根据用户提供的 PSQI 评分和现有睡眠记录，生成包含中文和英文双语的专业建议。\n要求：1. 语气温和，具备同理心；2. 建议包含睡眠卫生教育；3. 如发现严重睡眠障碍倾向，请提示其前往精神心理科就诊。',
  userPrompt: '用户 {user_name} 最近一次测评的 PSQI 总分为 {score} 分（满分 21 分），属于「睡眠质量差」。\n请根据以下信息为用户生成建议：\n- 睡眠时长：{sleep_duration} 小时\n- 入睡困难程度：{difficulty_falling_asleep}\n- 日间功能障碍：{daytime_dysfunction}',
  useVariables: true,
  useFewShot: false,
  allowMultiTurn: true,
  enableJson: true,
  params: {
    temperature: 0.4,
    topP: 0.9,
    maxTokens: 1024,
    format: 'json'
  },
  enableSchema: true,
  jsonSchema: `{
  "type": "object",
  "properties": {
    "zh": { "type": "string", "description": "中文建议" },
    "en": { "type": "string", "description": "英文建议" }
  },
  "required": ["zh", "en"]
}`,
  safety: {
    enableSensitiveFilter: true,
    forbidMedicalDiagnosis: true,
    forbidNegativeGuidance: false
  }
})

// 变量列表
const availableVariables = ['{user_name}', '{score}', '{sleep_duration}', '{difficulty_falling_asleep}', '{daytime_dysfunction}']

const variableList = ref([
  { name: '{user_name}', type: 'String', source: '用户资料', desc: '用户昵称', required: true },
  { name: '{score}', type: 'Number', source: '测评结果', desc: 'PSQI 总分', required: true },
  { name: '{sleep_duration}', type: 'Number', source: '睡眠记录', desc: '近 7 天平均睡眠时长', required: false },
  { name: '{difficulty_falling_asleep}', type: 'String', source: '测评结果', desc: '入睡困难程度', required: false },
  { name: '{daytime_dysfunction}', type: 'String', source: '测评结果', desc: '日间功能障碍', required: false }
])

// 插入变量
const insertVariable = (val) => {
  formData.userPrompt += val
}

// 测试相关
const testInput = ref('我最近总是失眠，每天晚上都要辗转反侧很久才能睡着。')
const testResult = ref('')

const runTest = () => {
  if (!testInput.value) return ElMessage.warning('请输入模拟内容')
  
  ElMessage.info('正在请求 AI 模型...')
  setTimeout(() => {
    testResult.value = `您好！根据您的描述，建议您尝试：
1. 建立规律的作息时间，每天同一时间上床和起床。
2. 睡前 1 小时避免使用电子设备。
3. 可以尝试 4-7-8 呼吸法放松。
如果情况持续，建议咨询专业医生。`
    ElMessage.success('测试成功！')
  }, 1500)
}

// 保存提交
const submitForm = async () => {
  if (!formData.title || !formData.code) {
    return ElMessage.warning('请填写完整的基础信息')
  }
  try {
    await savePromptTemplate(formData)
    ElMessage.success('保存成功！')
    router.push('/back/prompt-templates')
  } catch (e) {
    ElMessage.error('保存失败，请检查后端')
  }
}
</script>

<style scoped lang="scss">
.create-prompt-page {
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
      .sub-title { font-size: 13px; color: #94A3B8; margin-left: 10px; }
      .back-icon { cursor: pointer; font-size: 20px; color: #64748B; &:hover { color: #2563EB; } }
    }
    .action-area {
      display: flex; gap: 12px;
      .el-button { height: 36px; border-radius: 6px; margin: 0; }
      .btn-export { background: #FFF; border: 1px solid #E2E8F0; color: #475569; &:hover { color: #2563EB; border-color: #2563EB; } }
      .btn-add { background: #2563EB; border: none; &:hover { background: #1D4ED8; } }
    }
  }

  .main-content {
    display: flex; gap: 20px; padding: 20px 24px; width: 100%; max-width: 1400px; margin: 0 auto;
    .left-form { flex: 1; display: flex; flex-direction: column; gap: 16px; }
    .right-preview { width: 380px; display: flex; flex-direction: column; gap: 16px; }
  }

  .form-card {
    border-radius: 8px; border: none;
    .card-header {
      display: flex; justify-content: space-between; align-items: center;
      .card-title { font-weight: 600; font-size: 15px; display: flex; align-items: center; gap: 6px; }
      .char-count { font-size: 12px; color: #94A3B8; }
    }
  }

  .text-blue { color: #2563EB; }
  .text-green { color: #10B981; }
  .text-orange { color: #F59E0B; }
  .text-purple { color: #8B5CF6; }
  .text-cyan { color: #06B6D4; }

  .prompt-actions {
    display: flex; align-items: center; gap: 16px; margin-top: 12px;
    .right-actions { margin-left: auto; display: flex; gap: 12px; }
  }

  .variable-bar {
    display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-bottom: 12px;
    span { font-size: 13px; color: #64748B; }
    .var-tag { cursor: pointer; background: #F1F5F9; border-color: #E2E8F0; &:hover { color: #2563EB; border-color: #2563EB; } }
  }

  .code-editor {
    :deep(.el-textarea__inner) {
      font-family: 'Courier New', Courier, monospace;
      background-color: #1E293B;
      color: #E2E8F0;
      line-height: 1.5;
    }
  }

  .preview-card {
    border-radius: 8px; border: none;
    .card-header {
      display: flex; justify-content: space-between; align-items: center;
      .card-title { font-weight: 600; font-size: 14px; display: flex; align-items: center; gap: 6px; }
    }
    &.bg-gray { background: #F8FAFC; }
  }

  .test-input {
    margin-bottom: 16px;
    .input-label { font-size: 13px; font-weight: 500; margin-bottom: 6px; color: #475569; }
  }

  .test-output {
    .output-label { font-size: 13px; font-weight: 500; margin-bottom: 6px; color: #475569; }
    .output-content {
      background: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 6px; padding: 12px; font-size: 13px; line-height: 1.6; color: #475569; min-height: 100px;
      .placeholder-text { color: #94A3B8; font-style: italic; }
    }
  }

  .var-check-list {
    list-style: none; padding: 0; margin: 0;
    li { font-size: 13px; display: flex; align-items: center; gap: 6px; margin-bottom: 8px; color: #475569; }
  }

  .tips-list {
    list-style: none; padding: 0; margin: 0;
    li { font-size: 12px; color: #64748B; margin-bottom: 8px; line-height: 1.5; }
  }
}
</style>