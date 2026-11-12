<template>
  <div class="prompt-templates-page">
    <!-- 1. 页面头部 -->
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">提示词模板 <el-tag size="small" type="info" effect="plain" class="version-tag">v1.2</el-tag></h2>
        <p class="page-subtitle">管理对话 Prompt、系统提示词、内容生成模板等提示词，支持变量、多版本与审批</p>
      </div>
      <div class="header-right">
        <el-button class="btn-export"><el-icon><i class="ri-history-line"></i></el-icon> 版本记录</el-button>
        <el-button class="btn-export"><el-icon><i class="ri-refresh-line"></i></el-icon> 同步变更</el-button>
        <!-- 直接调用 router.push 即可 -->
        <el-button type="primary" class="btn-add" @click="router.push('/back/create-prompt')">
          <el-icon><i class="ri-add-line"></i></el-icon> 新建提示词
        </el-button>
      </div>
    </div>

    <!-- 2. 统计卡片 -->
    <el-row :gutter="16" class="stats-row">
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">模板总数 <el-icon class="right-icon" color="#2563EB"><i class="ri-file-code-line"></i></el-icon></div>
          <div class="stat-value">{{ totalCount }}</div>
          <div class="stat-desc">覆盖 10 个业务 · 5 个模型</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">启用中 <el-icon class="right-icon" color="#10B981"><i class="ri-checkbox-circle-line"></i></el-icon></div>
          <div class="stat-value text-green">{{ enabledCount }}</div>
          <div class="stat-desc text-green">占比 {{ totalCount ? ((enabledCount / totalCount) * 100).toFixed(1) : 0 }}%，已绑定业务</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">待审核 <el-icon class="right-icon" color="#F59E0B"><i class="ri-time-line"></i></el-icon></div>
          <div class="stat-value text-orange">{{ pendingCount }}</div>
          <div class="stat-desc">含 2 条高风险提示词，需医疗顾问审核</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">本月调用 <el-icon class="right-icon" color="#8B5CF6"><i class="ri-bar-chart-fill"></i></el-icon></div>
          <div class="stat-value text-purple">1,248,600</div>
          <div class="stat-desc text-purple">成功率 99.2% · 平均耗时 1.6s</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 3. 过滤栏 -->
    <div class="filter-bar">
      <el-tabs v-model="activeTab" class="custom-tabs">
        <el-tab-pane label="全部" name="all" />
        <el-tab-pane label="系统提示词" name="system" />
        <el-tab-pane label="对话模板" name="chat" />
        <el-tab-pane label="内容生成" name="generate" />
      </el-tabs>

      <div class="filter-selects">
        <el-select v-model="filterModel" placeholder="全部模型" size="small" style="width: 140px">
          <el-option label="全部模型" value="" />
          <el-option label="GPT-4o" value="GPT-4o" />
          <el-option label="Claude 3.5" value="Claude 3.5" />
        </el-select>
        <el-select v-model="filterStatus" placeholder="全部状态" size="small" style="width: 120px">
          <el-option label="全部状态" value="" />
        </el-select>
        <el-input v-model="searchKeyword" placeholder="搜索模板名称/编码" size="small" style="width: 200px" clearable>
          <template #prefix><el-icon><i class="ri-search-line"></i></el-icon></template>
        </el-input>
      </div>
    </div>

    <!-- 4. 表格区域 -->
    <div class="table-container">
      <el-table :data="tableData" style="width: 100%" row-key="id">
        <el-table-column type="selection" width="55" />
        <el-table-column label="模板名称/编码" min-width="220">
          <template #default="{ row }">
            <div class="name-cell">
              <span class="name">{{ row.title }}</span>
              <span class="code">{{ row.code }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="category" label="分类" width="120" />
        <el-table-column label="模型" width="140">
          <template #default="{ row }">
            <el-tag type="info" effect="plain">{{ row.model }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="version" label="版本" width="100" />
        <el-table-column label="Tokens 估算" width="120">
          <template #default="{ row }">
            <span class="tokens">{{ row.tokens }}</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.status === '启用中'" type="success" effect="light" size="small">启用中</el-tag>
            <el-tag v-else-if="row.status === '待审核'" type="warning" effect="light" size="small">待审核</el-tag>
            <el-tag v-else type="info" effect="light" size="small">已停用</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="更新人 / 时间" width="140">
          <template #default="{ row }">
            <div class="update-cell">
              <span>{{ row.updater }}</span>
              <span class="time">{{ row.updateTime }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button link type="primary" size="small" @click="handlePreview(row)">预览</el-button>
            <el-button v-if="row.status === '启用中'" link type="danger" size="small" @click="handleToggleStatus(row)">停用</el-button>
            <el-button v-else-if="row.status === '待审核'" link type="primary" size="small" @click="handleToggleStatus(row)">审核</el-button>
            <el-button v-else link type="success" size="small" @click="handleToggleStatus(row)">启用</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrapper">
        <span class="page-info">共 {{ total }} 条，当前展示第 {{ (currentPage - 1) * pageSize + 1 }}-{{ Math.min(currentPage * pageSize, total) }} 条</span>
        <el-pagination 
          background 
          layout="prev, pager, next" 
          :total="total" 
          :page-size="pageSize"
          v-model:current-page="currentPage"
          @current-change="handlePageChange" 
        />
      </div>
    </div>

    <!-- 💡 编辑弹窗 (新建改用跳转了，所以这里只负责编辑) -->
    <el-dialog v-model="dialogVisible" title="编辑提示词" width="600px">
      <el-form :model="formData" label-width="100px">
        <el-form-item label="模板名称" required>
          <el-input v-model="formData.title" placeholder="请输入模板名称" />
        </el-form-item>
        <el-form-item label="模板编码" required>
          <el-input v-model="formData.code" placeholder="例如：PROMPT_SCALE_INTERPRET" />
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="分类">
              <el-input v-model="formData.category" placeholder="例如：量表解读" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="适用模型">
              <el-select v-model="formData.model" style="width: 100%">
                <el-option label="GPT-4o" value="GPT-4o" />
                <el-option label="Claude 3.5 Sonnet" value="Claude 3.5 Sonnet" />
                <el-option label="Qwen-72B" value="Qwen-72B" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="版本号">
              <el-input v-model="formData.version" placeholder="例如：v1.0" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="Tokens 估算">
              <el-input v-model="formData.tokens" placeholder="例如：1.2k" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitForm">确认保存</el-button>
      </template>
    </el-dialog>

    <!-- 💡 预览抽屉 -->
    <el-drawer v-model="previewVisible" title="提示词预览" size="40%">
      <div v-if="currentTemplate" class="preview-content">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="模板名称">{{ currentTemplate.title }}</el-descriptions-item>
          <el-descriptions-item label="模板编码">{{ currentTemplate.code }}</el-descriptions-item>
          <el-descriptions-item label="分类">{{ currentTemplate.category }}</el-descriptions-item>
          <el-descriptions-item label="模型">{{ currentTemplate.model }}</el-descriptions-item>
          <el-descriptions-item label="版本">{{ currentTemplate.version }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="currentTemplate.status === '启用中' ? 'success' : 'info'">{{ currentTemplate.status }}</el-tag>
          </el-descriptions-item>
        </el-descriptions>
        <div class="preview-box">
          <div class="preview-label">Prompt 内容展示</div>
          <div class="preview-text">你是一名专业的心理健康助手，请以共情、温和的语气回答用户...</div>
        </div>
      </div>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRouter } from 'vue-router' // 引入路由
import { getPromptTemplates, updatePromptTemplate, updatePromptStatus } from '@/api/admin'

const router = useRouter() // 实例化路由

const activeTab = ref('all')
const filterModel = ref('')
const filterStatus = ref('')
const searchKeyword = ref('')
const tableData = ref([])

const currentPage = ref(1)
const pageSize = ref(20)
const total = ref(0)

// 弹窗控制
const dialogVisible = ref(false)
const previewVisible = ref(false)
const currentTemplate = ref(null)

const formData = reactive({
  id: null, title: '', code: '', category: '', model: '', version: '', tokens: ''
})

const totalCount = computed(() => tableData.value.length)
const enabledCount = computed(() => tableData.value.filter(r => r.status === '启用中').length)
const pendingCount = computed(() => tableData.value.filter(r => r.status === '待审核').length)

const fetchTemplates = async () => {
  try {
    const res = await getPromptTemplates({ page: currentPage.value, size: pageSize.value })
    const pageData = res.data || res
    const data = pageData.records || []
    total.value = pageData.total || 0

    tableData.value = data.map(item => ({
      id: item.id,
      title: item.title,
      code: item.code,
      category: item.category,
      model: item.model,
      version: item.version,
      tokens: item.tokens,
      status: item.status === 1 ? '启用中' : (item.status === 2 ? '待审核' : '已停用'),
      updater: item.updater,
      updateTime: item.updatedAt ? item.updatedAt.replace('T', ' ').substring(5, 16) : ''
    }))
  } catch (error) {
    console.error('获取提示词模板失败', error)
    ElMessage.error('后端未连接')
  }
}

const handlePageChange = (val) => {
  currentPage.value = val
  fetchTemplates()
}

// 💡 这里只保留编辑逻辑
const handleEdit = (row) => {
  Object.assign(formData, {
    id: row.id, title: row.title, code: row.code, category: row.category,
    model: row.model, version: row.version, tokens: row.tokens
  })
  dialogVisible.value = true
}

const handlePreview = (row) => {
  currentTemplate.value = row
  previewVisible.value = true
}

const submitForm = async () => {
  if (!formData.title || !formData.code) return ElMessage.warning('请填写完整必填项')
  try {
    await updatePromptTemplate(formData)
    ElMessage.success('编辑成功')
    dialogVisible.value = false
    fetchTemplates()
  } catch (e) {
    ElMessage.error('操作失败，请检查后端')
  }
}

const handleToggleStatus = (row) => {
  const isOnline = row.status === '启用中'
  const targetStatus = isOnline ? 0 : 1
  const actionText = isOnline ? '停用' : '启用'

  ElMessageBox.confirm(`确认要${actionText}【${row.title}】吗？`, '提示', { type: 'warning' }).then(async () => {
    try {
      await updatePromptStatus(row.id, targetStatus)
      row.status = isOnline ? '已停用' : '启用中'
      ElMessage.success(`已${actionText}`)
      fetchTemplates()
    } catch (e) {
      ElMessage.error('操作失败')
    }
  }).catch(() => {})
}

onMounted(() => {
  fetchTemplates()
})
</script>

<style scoped lang="scss">
.prompt-templates-page {
  padding-bottom: 20px;
  .page-header {
    display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px;
    .header-left {
      .page-title { font-size: 22px; font-weight: 600; color: #111827; margin: 0 0 8px 0; display: flex; align-items: center; gap: 8px; .version-tag { border-radius: 4px; } }
      .page-subtitle { font-size: 13px; color: #94A3B8; margin: 0; }
    }
    .header-right {
      display: flex; gap: 12px;
      .el-button { height: 36px; border-radius: 6px; }
      .btn-export { background: #FFF; border: 1px solid #E2E8F0; color: #475569; &:hover { color: #2563EB; border-color: #2563EB; } }
      .btn-add { background: #2563EB; border: none; &:hover { background: #1D4ED8; } }
    }
  }
  .stats-row {
    margin-bottom: 16px;
    .stat-card {
      border-radius: 8px; border: none; box-shadow: 0 1px 3px rgba(0,0,0,0.05); padding: 4px;
      .stat-title { font-size: 13px; color: #64748B; display: flex; justify-content: space-between; align-items: center; .right-icon { font-size: 18px; } }
      .stat-value { font-size: 28px; font-weight: 700; color: #111827; margin: 10px 0 6px; }
      .stat-desc { font-size: 12px; color: #94A3B8; }
    }
  }
  .text-green { color: #10B981 !important; }
  .text-orange { color: #F59E0B !important; }
  .text-purple { color: #8B5CF6 !important; }
  .filter-bar {
    display: flex; justify-content: space-between; align-items: center;
    background: #FFF; padding: 0 20px; border-radius: 8px; margin-bottom: 20px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    .custom-tabs {
      :deep(.el-tabs__header) { margin: 0; border-bottom: none !important; }
      :deep(.el-tabs__nav-wrap::after) { display: none !important; height: 0 !important; }
      :deep(.el-tabs__item) { height: 56px; line-height: 56px; padding: 0 20px; font-size: 14px; color: #64748B; font-weight: 500; &:hover { color: #111827; } &.is-active { color: #2563EB; font-weight: 600; } }
      :deep(.el-tabs__active-bar) { background-color: #2563EB; height: 2px; }
    }
    .filter-selects { display: flex; gap: 12px; }
  }
  .table-container {
    background: #FFF; border-radius: 8px; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    .name-cell {
      display: flex; flex-direction: column;
      .name { font-size: 14px; color: #111827; font-weight: 500; }
      .code { font-size: 12px; color: #94A3B8; margin-top: 4px; }
    }
    .tokens { color: #F59E0B; font-weight: 600; }
    .update-cell {
      display: flex; flex-direction: column; font-size: 13px; color: #475569;
      .time { font-size: 12px; color: #94A3B8; margin-top: 2px; }
    }
    .pagination-wrapper {
      margin-top: 20px; display: flex; justify-content: space-between; align-items: center;
      .page-info { font-size: 13px; color: #64748B; }
    }
  }
  .preview-content {
    padding: 10px;
    .preview-box {
      margin-top: 20px;
      .preview-label { font-size: 14px; font-weight: 600; color: #374151; margin-bottom: 10px; }
      .preview-text { padding: 20px; background: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 8px; font-size: 14px; line-height: 1.6; color: #475569; }
    }
  }
}
</style>