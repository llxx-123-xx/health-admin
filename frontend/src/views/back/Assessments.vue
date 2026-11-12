<template>
  <div class="assessments-page">
    <!-- 1. 页面头部 -->
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">量表管理</h2>
        <p class="page-subtitle">维护心理测评量表、题库、计分规则与分级阈值，发布后 C 端即时生效</p>
      </div>
      <div class="header-right">
        <el-button class="btn-export"><el-icon><i class="ri-history-line"></i></el-icon> 版本记录</el-button>
        <!-- 💡 绑定 handleCreate 事件 -->
        <el-button type="primary" class="btn-add" @click="handleCreate">
          <el-icon><i class="ri-add-line"></i></el-icon> 新建量表
        </el-button>
      </div>
    </div>

    <!-- 2. 统计卡片 -->
    <el-row :gutter="16" class="stats-row">
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">量表总数 <el-icon class="right-icon" color="#2563EB"><i class="ri-file-list-3-line"></i></el-icon></div>
          <div class="stat-value">{{ tableData.length }}</div>
          <div class="stat-desc">含 {{ publishedCount }} 个已上架</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">已上架 <el-icon class="right-icon" color="#10B981"><i class="ri-checkbox-circle-line"></i></el-icon></div>
          <div class="stat-value text-green">{{ publishedCount }}</div>
          <div class="stat-desc">C 端可见</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">草稿/待发布 <el-icon class="right-icon" color="#F59E0B"><i class="ri-file-edit-line"></i></el-icon></div>
          <div class="stat-value text-orange">{{ draftCount }}</div>
          <div class="stat-desc">待审核</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">本月完成测评 <el-icon class="right-icon" color="#8B5CF6"><i class="ri-bar-chart-fill"></i></el-icon></div>
          <div class="stat-value text-purple">28,412</div>
          <div class="stat-desc text-purple">较上月 +14.6%</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 3. 过滤栏 -->
    <div class="filter-bar">
      <el-tabs v-model="activeTab" class="custom-tabs">
        <el-tab-pane label="全部" name="all" />
        <el-tab-pane :label="`已上架 ${publishedCount}`" name="published" />
        <el-tab-pane :label="`草稿 ${draftCount}`" name="draft" />
        <el-tab-pane :label="`已下架 ${offlineCount}`" name="offline" />
      </el-tabs>

      <div class="filter-selects">
        <el-select v-model="filterCategory" placeholder="全部分类" size="small" style="width: 120px">
          <el-option label="全部分类" value="" />
          <el-option label="焦虑" value="焦虑" />
          <el-option label="抑郁" value="抑郁" />
          <el-option label="睡眠" value="睡眠" />
        </el-select>
        <el-input v-model="searchKeyword" placeholder="搜索量表名称/编码" size="small" style="width: 200px" clearable>
          <template #prefix><el-icon><i class="ri-search-line"></i></el-icon></template>
        </el-input>
      </div>
    </div>

    <!-- 4. 数据表格 -->
    <div class="table-container">
      <el-table :data="filteredData" style="width: 100%" row-key="id" class="custom-table">
        <el-table-column label="量表名称/编码" min-width="200">
          <template #default="{ row }">
            <div class="name-cell">
              <span class="name">{{ row.name }}</span>
              <span class="code">{{ row.code }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="category" label="分类" width="120" />
        <el-table-column prop="questionCount" label="题量" width="80" />
        <el-table-column prop="time" label="预计用时" width="100" />
        <el-table-column prop="version" label="版本" width="80" />
        <el-table-column label="高风险规则" width="160">
          <template #default="{ row }">
            <el-tag v-if="row.riskRule" type="danger" effect="light" size="small">{{ row.riskRule }}</el-tag>
            <el-tag v-else type="info" effect="light" size="small">未配置</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.status === '已上架'" type="success" effect="light" size="small">已上架</el-tag>
            <el-tag v-else-if="row.status === '草稿'" type="warning" effect="light" size="small">草稿</el-tag>
            <el-tag v-else type="info" effect="light" size="small">已下架</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="updateTime" label="更新时间" width="120" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button link type="primary" size="small" @click="handlePreview(row)">预览</el-button>
            <el-button v-if="row.status === '已上架'" link type="danger" size="small" @click="handleToggleStatus(row)">下架</el-button>
            <el-button v-else-if="row.status === '已下架'" link type="success" size="small" @click="handleToggleStatus(row)">上架</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrapper">
        <span class="page-info">共 {{ filteredData.length }} 条</span>
        <el-pagination background layout="prev, pager, next" :total="filteredData.length" :page-size="20" />
      </div>
    </div>

    <!-- 💡 预览抽屉 -->
    <el-drawer v-model="previewVisible" title="量表预览" size="40%">
      <div v-if="currentScale" class="preview-content">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="量表名称">{{ currentScale.name }}</el-descriptions-item>
          <el-descriptions-item label="量表编码">{{ currentScale.code }}</el-descriptions-item>
          <el-descriptions-item label="所属分类">{{ currentScale.category }}</el-descriptions-item>
          <el-descriptions-item label="题目数量">{{ currentScale.questionCount }}</el-descriptions-item>
          <el-descriptions-item label="预计用时">{{ currentScale.time }}</el-descriptions-item>
          <el-descriptions-item label="当前版本">{{ currentScale.version }}</el-descriptions-item>
          <el-descriptions-item label="高风险规则">
            <el-tag v-if="currentScale.riskRule" type="danger">{{ currentScale.riskRule }}</el-tag>
            <span v-else>暂无</span>
          </el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="currentScale.status === '已上架' ? 'success' : 'info'">{{ currentScale.status }}</el-tag>
          </el-descriptions-item>
        </el-descriptions>
        <div class="preview-placeholder">
          <el-icon><i class="ri-file-list-3-line"></i></el-icon>
          <p>此处将展示量表的所有题目和选项</p>
        </div>
      </div>
    </el-drawer>

    <!-- 💡 新建/编辑弹窗 -->
    <el-dialog v-model="formVisible" :title="isEditing ? '编辑量表' : '新建量表'" width="600px">
      <el-form :model="formData" label-width="100px">
        <el-form-item label="量表名称" required>
          <el-input v-model="formData.name" placeholder="请输入量表名称" />
        </el-form-item>
        <el-form-item label="量表编码" required>
          <el-input v-model="formData.code" placeholder="请输入英文编码，如 SCALE_XXX" />
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="所属分类" required>
              <el-select v-model="formData.category" style="width: 100%">
                <el-option label="焦虑" value="焦虑" />
                <el-option label="抑郁" value="抑郁" />
                <el-option label="睡眠" value="睡眠" />
                <el-option label="情绪" value="情绪" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="题量" required>
              <el-input-number v-model="formData.questionCount" :min="1" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="预计用时">
          <el-input v-model="formData.timeCost" placeholder="例如：约 3 分钟" />
        </el-form-item>
        <el-form-item label="高风险规则">
          <el-input v-model="formData.riskRule" placeholder="例如：总分 ≥ 15 触发（不填则无）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="formVisible = false">取消</el-button>
        <el-button type="primary" @click="submitForm">确认{{ isEditing ? '保存' : '新建' }}</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
// 💡 引入新建/修改的 API
import { getAssessments, updateAssessmentStatus, saveAssessment, updateAssessment } from '@/api/admin'

const activeTab = ref('all')
const filterCategory = ref('')
const searchKeyword = ref('')
const previewVisible = ref(false)
const currentScale = ref(null)
const tableData = ref([])

// ==========================================
// 💡 弹窗与表单控制
// ==========================================
const formVisible = ref(false)
const isEditing = ref(false)
const formData = reactive({
  id: null,
  name: '',
  code: '',
  category: '',
  questionCount: 1,
  timeCost: '',
  riskRule: ''
})

// 统计数据
const publishedCount = computed(() => tableData.value.filter(r => r.status === '已上架').length)
const draftCount = computed(() => tableData.value.filter(r => r.status === '草稿').length)
const offlineCount = computed(() => tableData.value.filter(r => r.status === '已下架').length)

// 前端多条件过滤
const filteredData = computed(() => {
  let list = tableData.value
  if (activeTab.value === 'published') list = list.filter(r => r.status === '已上架')
  else if (activeTab.value === 'draft') list = list.filter(r => r.status === '草稿')
  else if (activeTab.value === 'offline') list = list.filter(r => r.status === '已下架')

  if (filterCategory.value) list = list.filter(r => r.category === filterCategory.value)
  if (searchKeyword.value) {
    const kw = searchKeyword.value.toLowerCase()
    list = list.filter(r => r.name.toLowerCase().includes(kw) || r.code.toLowerCase().includes(kw))
  }
  return list
})

// ==========================================
// 💡 获取列表
// ==========================================
const fetchList = async () => {
  try {
    const res = await getAssessments()
    const data = res.data || res || []
    tableData.value = data.map(item => ({
      id: item.id,
      name: item.name,
      code: item.code,
      category: item.category,
      questionCount: item.questionCount + ' 题',
      time: item.timeCost,
      version: item.version,
      riskRule: item.riskRule,
      status: item.status === 1 ? '已上架' : (item.status === 2 ? '草稿' : '已下架'),
      updateTime: item.updatedAt ? item.updatedAt.replace('T', ' ').substring(5, 16) : ''
    }))
  } catch (error) {
    console.error('获取量表失败', error)
    tableData.value = []
  }
}

// ==========================================
// 💡 交互事件
// ==========================================

// 新建
const handleCreate = () => {
  isEditing.value = false
  Object.assign(formData, {
    id: null, name: '', code: '', category: '', questionCount: 1, timeCost: '', riskRule: ''
  })
  formVisible.value = true
}

// 编辑
const handleEdit = (row) => {
  isEditing.value = true
  Object.assign(formData, {
    id: row.id,
    name: row.name,
    code: row.code,
    category: row.category,
    questionCount: parseInt(row.questionCount), // 去掉 " 题"
    timeCost: row.time,
    riskRule: row.riskRule
  })
  formVisible.value = true
}

// 预览
const handlePreview = (row) => {
  currentScale.value = row
  previewVisible.value = true
}

// 上下架
const handleToggleStatus = (row) => {
  const isOnline = row.status === '已上架'
  const actionText = isOnline ? '下架' : '上架'
  ElMessageBox.confirm(
    `确认要${actionText}【${row.name}】吗？`,
    '操作确认',
    { confirmButtonText: `确认${actionText}`, cancelButtonText: '取消', type: isOnline ? 'warning' : 'info' }
  ).then(async () => {
    try {
      const targetStatus = isOnline ? 0 : 1
      await updateAssessmentStatus(row.id, targetStatus)
      row.status = isOnline ? '已下架' : '已上架'
      ElMessage.success(`【${row.name}】已成功${actionText}`)
    } catch (error) {
      ElMessage.error('操作失败，请检查网络')
    }
  }).catch(() => {})
}

// ==========================================
// 💡 提交表单（新建/保存）
// ==========================================
const submitForm = async () => {
  if (!formData.name || !formData.code || !formData.category) {
    ElMessage.warning('请填写完整必填项')
    return
  }
  
  try {
    if (isEditing.value) {
      // 💡 编辑保存
      await updateAssessment(formData)
      ElMessage.success('编辑保存成功')
    } else {
      // 💡 新建保存
      await saveAssessment(formData)
      ElMessage.success('新建量表成功')
    }
    formVisible.value = false
    fetchList() // 刷新列表
  } catch (error) {
    ElMessage.error('操作失败，请检查后端接口')
    console.error(error)
  }
}

onMounted(() => fetchList())
</script>

<style scoped lang="scss">
/* 你原来的样式完全保留，我补了两个细节类 */
.assessments-page {
  padding-bottom: 20px;
  .page-header {
    display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px;
    .header-left {
      .page-title { font-size: 22px; font-weight: 600; color: #111827; margin: 0 0 8px 0; }
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
    margin-bottom: 24px;
    .stat-card {
      border-radius: 8px; border: none; box-shadow: 0 1px 3px rgba(0,0,0,0.05); padding: 4px;
      .stat-title {
        font-size: 13px; color: #64748B; display: flex; justify-content: space-between; align-items: center;
        .right-icon { font-size: 18px; }
      }
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
      :deep(.el-tabs__item) {
        height: 56px; line-height: 56px; padding: 0 20px; font-size: 14px; color: #64748B; font-weight: 500;
        &:hover { color: #111827; }
        &.is-active { color: #2563EB; font-weight: 600; }
      }
      :deep(.el-tabs__active-bar) { background-color: #2563EB; height: 2px; }
    }
    .filter-selects { display: flex; gap: 12px; }
  }
  .table-container {
    background: #FFF; border-radius: 8px; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    .custom-table {
      :deep(.el-table__header th) { background-color: #F8FAFC; color: #64748B; font-weight: 500; }
      .name-cell {
        display: flex; flex-direction: column;
        .name { font-size: 14px; color: #111827; font-weight: 500; }
        .code { font-size: 12px; color: #94A3B8; margin-top: 4px; }
      }
    }
    .pagination-wrapper {
      margin-top: 20px; display: flex; justify-content: space-between; align-items: center;
      .page-info { font-size: 13px; color: #64748B; }
    }
  }
  .preview-content {
    padding: 10px;
    .preview-placeholder {
      margin-top: 30px; padding: 40px;
      background-color: #F8FAFC; border-radius: 8px;
      text-align: center; color: #94A3B8;
      .el-icon { font-size: 40px; margin-bottom: 10px; }
    }
  }
}
</style>