<template>
  <div class="suggestion-templates-page">
    <!-- 1. 页面头部 -->
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">建议文案模板 <el-tag size="small" type="info" effect="plain" class="version-tag">v2.4</el-tag></h2>
        <p class="page-subtitle">管理测评结束后向 C 端用户展示的个性化建议文案、触发条件与多语言版本</p>
      </div>
      <div class="header-right">
        <el-button class="btn-export"><el-icon><i class="ri-upload-2-line"></i></el-icon> 批量导入</el-button>
        <el-button class="btn-export"><el-icon><i class="ri-download-2-line"></i></el-icon> 导出</el-button>
        <!-- ✅ 核心修改：绑定跳转事件 -->
        <el-button type="primary" class="btn-add" @click="goToCreate">
          <el-icon><i class="ri-add-line"></i></el-icon> 新建文案
        </el-button>
      </div>
    </div>

    <!-- 2. 顶部统计卡片 -->
    <el-row :gutter="16" class="stats-row">
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">文案总数 <el-icon class="right-icon" color="#2563EB"><i class="ri-file-text-line"></i></el-icon></div>
          <div class="stat-value">{{ total }}</div>
          <div class="stat-desc">覆盖 12 个量表 · 3 种语言</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">启用中 <el-icon class="right-icon" color="#10B981"><i class="ri-checkbox-circle-line"></i></el-icon></div>
          <div class="stat-value text-green">{{ enabledCount }}</div>
          <div class="stat-desc text-green">占比 {{ total ? ((enabledCount / total) * 100).toFixed(1) : 0 }}%，C 端即时生效</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">待审核 <el-icon class="right-icon" color="#F59E0B"><i class="ri-time-line"></i></el-icon></div>
          <div class="stat-value text-orange">{{ pendingCount }}</div>
          <div class="stat-desc">最长等待 2 天 · 含 1 条高风险词</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">本月调用次数 <el-icon class="right-icon" color="#8B5CF6"><i class="ri-bar-chart-fill"></i></el-icon></div>
          <div class="stat-value text-purple">412,860</div>
          <div class="stat-desc text-purple">较上月 +6.2%</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 3. 动态占位符提示条 -->
    <div class="tips-bar">
      <el-icon color="#2563EB"><i class="ri-information-line"></i></el-icon>
      <span>文案支持变量占位符，发送时会自动替换：</span>
      <el-tag size="small" type="info" effect="plain">{user_name}</el-tag>
      <el-tag size="small" type="info" effect="plain">{scale_name}</el-tag>
      <el-tag size="small" type="info" effect="plain">{score}</el-tag>
      <el-tag size="small" type="info" effect="plain">{risk_level}</el-tag>
      <el-tag size="small" type="info" effect="plain">{next_action}</el-tag>
      <el-button link type="primary" size="small" style="margin-left: 10px;">变量说明</el-button>
    </div>

    <!-- 4. 过滤栏 -->
    <div class="filter-bar">
      <el-tabs v-model="activeTab" class="custom-tabs">
        <el-tab-pane label="全部文案" name="all" />
        <el-tab-pane :label="`启用中 ${enabledCount}`" name="enabled" />
        <el-tab-pane :label="`待审核 ${pendingCount}`" name="pending" />
        <el-tab-pane label="已停用" name="disabled" />
      </el-tabs>

      <div class="filter-selects">
        <el-select v-model="filterScale" placeholder="全部量表" size="small" style="width: 120px">
          <el-option label="全部量表" value="" />
        </el-select>
        <el-select v-model="filterRisk" placeholder="全部风险等级" size="small" style="width: 130px">
          <el-option label="全部风险等级" value="" />
          <el-option label="高风险" value="高风险" />
          <el-option label="中风险" value="中风险" />
          <el-option label="低风险" value="低风险" />
        </el-select>
        <el-select v-model="filterSort" placeholder="最新更新" size="small" style="width: 120px">
          <el-option label="最新更新" value="" />
        </el-select>
        <el-input v-model="searchKeyword" placeholder="搜索标题 / 编码" size="small" style="width: 180px" clearable>
          <template #prefix><el-icon><i class="ri-search-line"></i></el-icon></template>
        </el-input>
      </div>
    </div>

    <!-- 5. 数据表格 -->
    <div class="table-container">
      <!-- 批量操作 -->
      <div class="batch-bar" style="margin-bottom: 16px;">
        <el-checkbox v-model="isAllSelected">已选 {{ selectedRows.length }} 项</el-checkbox>
        <el-button size="small" plain>批量启用</el-button>
        <el-button size="small" plain>批量停用</el-button>
        <el-button size="small" plain>批量导出</el-button>
        <div class="right-tip">
          <el-icon color="#10B981"><i class="ri-checkbox-circle-fill"></i></el-icon> 高风险文案需医疗顾问审核后才可发布
        </div>
      </div>

      <el-table :data="filteredData" style="width: 100%" row-key="id">
        <el-table-column type="selection" width="55" />
        <el-table-column label="文案标题 / 编码" min-width="220">
          <template #default="{ row }">
            <div class="name-cell">
              <span class="name">{{ row.title }}</span>
              <span class="code">{{ row.code }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="scale" label="关联量表" width="140" />
        <el-table-column prop="condition" label="触发条件" min-width="180" />
        <el-table-column label="风险等级" width="100">
          <template #default="{ row }">
            <el-tag :type="getRiskTagType(row.risk)" effect="light" size="small">{{ row.risk }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="tone" label="语气风格" width="120" />
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
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button link type="primary" size="small" @click="handlePreview(row)">预览</el-button>
            <el-button v-if="row.status === '启用中'" link type="danger" size="small" @click="handleToggleStatus(row)">停用</el-button>
            <el-button v-else-if="row.status === '待审核'" link type="primary" size="small" @click="handleToggleStatus(row)">审核</el-button>
            <el-button v-else link type="success" size="small" @click="handleToggleStatus(row)">启用</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
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

    <!-- 💡 编辑弹窗 -->
    <el-dialog v-model="dialogVisible" title="编辑文案" width="600px">
      <el-form :model="formData" label-width="100px">
        <el-form-item label="文案标题" required>
          <el-input v-model="formData.title" placeholder="请输入标题" />
        </el-form-item>
        <el-form-item label="文案编码" required>
          <el-input v-model="formData.code" placeholder="例如：COPY_GAD7_HIGH" />
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="关联量表">
              <el-input v-model="formData.scaleName" placeholder="例如：GAD-7 焦虑自评" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="风险等级">
              <el-select v-model="formData.riskLevel" style="width: 100%">
                <el-option label="高风险" value="高风险" />
                <el-option label="中风险" value="中风险" />
                <el-option label="低风险" value="低风险" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="触发条件">
          <el-input v-model="formData.triggerCondition" placeholder="例如：总分 ≥ 13" />
        </el-form-item>
        <el-form-item label="文案内容" required>
          <el-input v-model="formData.content" type="textarea" :rows="4" placeholder="支持 {user_name} 等占位符" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitForm">确认保存</el-button>
      </template>
    </el-dialog>
    
    <!-- 💡 预览文案抽屉 -->
    <el-drawer v-model="previewVisible" title="文案预览" size="40%">
      <div v-if="currentTemplate" class="preview-content">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="文案标题">{{ currentTemplate.title }}</el-descriptions-item>
          <el-descriptions-item label="文案编码">{{ currentTemplate.code }}</el-descriptions-item>
          <el-descriptions-item label="关联量表">{{ currentTemplate.scale }}</el-descriptions-item>
          <el-descriptions-item label="触发条件">{{ currentTemplate.condition }}</el-descriptions-item>
          <el-descriptions-item label="风险等级">
            <el-tag :type="getRiskTagType(currentTemplate.risk)">{{ currentTemplate.risk }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="语气风格">{{ currentTemplate.tone }}</el-descriptions-item>
        </el-descriptions>
        
        <div class="preview-box">
          <div class="preview-label">文案内容展示</div>
          <div class="preview-text" v-if="currentTemplate.content">
            {{ currentTemplate.content }}
          </div>
          <el-empty v-else description="暂无文案内容" />
        </div>
      </div>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRouter } from 'vue-router' // 💡 引入路由
import { getSuggestionTemplates, updateSuggestionStatus, updateSuggestionTemplate } from '@/api/admin'

const router = useRouter() // 💡 实例化路由

// 💡 跳转到新建文案页面
const goToCreate = () => {
  router.push('/back/create-suggestion')
}

const activeTab = ref('all')
const filterScale = ref('')
const filterRisk = ref('')
const filterSort = ref('')
const searchKeyword = ref('')
const isAllSelected = ref(false)
const selectedRows = ref([])
const tableData = ref([])

// 分页
const currentPage = ref(1)
const pageSize = ref(20)
const total = ref(0)

// 弹窗控制
const dialogVisible = ref(false)
const previewVisible = ref(false)
const currentTemplate = ref(null)

const formData = reactive({
  id: null, title: '', code: '', scaleName: '', 
  triggerCondition: '', riskLevel: '', tone: '', content: ''
})

// 统计数据
const enabledCount = computed(() => tableData.value.filter(r => r.status === '启用中').length)
const pendingCount = computed(() => tableData.value.filter(r => r.status === '待审核').length)

// 从后端加载数据
const fetchTemplates = async () => {
  try {
    const res = await getSuggestionTemplates({ page: currentPage.value, size: pageSize.value })
    const pageData = res.data || res
    const data = pageData.records || []
    total.value = pageData.total || 0

    tableData.value = data.map(item => ({
      id: item.id,
      title: item.title,
      code: item.code,
      scale: item.scaleName,
      condition: item.triggerCondition,
      risk: item.riskLevel,
      tone: item.tone,
      status: item.status === 1 ? '启用中' : (item.status === 2 ? '待审核' : '已停用'),
      updater: item.updater,
      updateTime: item.updatedAt ? item.updatedAt.replace('T', ' ').substring(5, 16) : '',
      content: item.content // 确保接收了 content
    }))
  } catch (error) {
    console.error('获取文案列表失败', error)
    ElMessage.error('后端未连接')
  }
}

const handlePageChange = (val) => {
  currentPage.value = val
  fetchTemplates()
}

const filteredData = computed(() => {
  let list = tableData.value
  if (activeTab.value === 'enabled') list = list.filter(r => r.status === '启用中')
  else if (activeTab.value === 'pending') list = list.filter(r => r.status === '待审核')
  else if (activeTab.value === 'disabled') list = list.filter(r => r.status === '已停用')

  if (filterRisk.value) list = list.filter(r => r.risk === filterRisk.value)
  if (searchKeyword.value) {
    const kw = searchKeyword.value.toLowerCase()
    list = list.filter(r => r.title.toLowerCase().includes(kw) || r.code.toLowerCase().includes(kw))
  }
  return list
})

const getRiskTagType = (risk) => {
  if (risk === '高风险') return 'danger'
  if (risk === '中风险') return 'warning'
  return 'info'
}

// 💡 编辑弹窗逻辑
const handleEdit = (row) => {
  Object.assign(formData, {
    id: row.id, title: row.title, code: row.code, scaleName: row.scale,
    triggerCondition: row.condition, riskLevel: row.risk, tone: row.tone, content: row.content || ''
  })
  dialogVisible.value = true
}

// 💡 预览事件
const handlePreview = (row) => {
  currentTemplate.value = row
  previewVisible.value = true
}

const submitForm = async () => {
  if (!formData.title || !formData.code) return ElMessage.warning('请填写完整必填项')
  try {
    await updateSuggestionTemplate(formData)
    ElMessage.success('编辑成功')
    dialogVisible.value = false
    fetchTemplates()
  } catch (e) {
    ElMessage.error('操作失败，请检查后端')
  }
}

// 上下架/审核
const handleToggleStatus = (row) => {
  const isOnline = row.status === '启用中'
  const targetStatus = isOnline ? 0 : 1
  const actionText = isOnline ? '停用' : '启用'

  ElMessageBox.confirm(`确认要${actionText}【${row.title}】吗？`, '提示', { type: 'warning' }).then(async () => {
    try {
      await updateSuggestionStatus(row.id, targetStatus)
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
/* 这里的样式完全保留你原来写的，没有任何修改 */
.suggestion-templates-page {
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
  .tips-bar {
    display: flex; align-items: center; gap: 8px;
    background: #EFF6FF; border: 1px solid #BFDBFE; border-radius: 8px;
    padding: 12px 16px; margin-bottom: 20px; font-size: 13px; color: #1E40AF;
    .el-tag { background: #FFF; border-color: #BFDBFE; color: #1E40AF; }
  }
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
    .batch-bar {
      display: flex; align-items: center; gap: 12px;
      .right-tip { margin-left: auto; font-size: 12px; color: #64748B; display: flex; align-items: center; gap: 4px; }
    }
    .name-cell {
      display: flex; flex-direction: column;
      .name { font-size: 14px; color: #111827; font-weight: 500; }
      .code { font-size: 12px; color: #94A3B8; margin-top: 4px; }
    }
    .update-cell {
      display: flex; flex-direction: column; font-size: 13px; color: #475569;
      .time { font-size: 12px; color: #94A3B8; margin-top: 2px; }
    }
    .pagination-wrapper {
      margin-top: 20px; display: flex; justify-content: space-between; align-items: center;
      .page-info { font-size: 13px; color: #64748B; }
    }
  }

  /* 💡 预览抽屉样式 */
  .preview-content {
    padding: 10px;
    .preview-box {
      margin-top: 20px;
      .preview-label {
        font-size: 14px;
        font-weight: 600;
        color: #374151;
        margin-bottom: 10px;
      }
      .preview-text {
        padding: 20px;
        background: #F8FAFC;
        border: 1px solid #E2E8F0;
        border-radius: 8px;
        font-size: 14px;
        line-height: 1.6;
        color: #475569;
        white-space: pre-wrap;
      }
    }
  }
}
</style>