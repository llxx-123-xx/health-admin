<template>
  <div class="push-templates-page">
    <!-- 1. 页面头部 -->
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">推送模板 <el-tag size="small" type="info" effect="plain" class="version-tag">v1.2</el-tag></h2>
        <p class="page-subtitle">管理站内信、App Push、短信服务号与企微的推送模板，支持变量与人群定向</p>
      </div>
      <div class="header-right">
        <el-button class="btn-export"><el-icon><i class="ri-refresh-line"></i></el-icon> 预览规则</el-button>
        <el-button class="btn-export"><el-icon><i class="ri-download-2-line"></i></el-icon> 导出</el-button>
        <!-- 💡 绑定新建事件 -->
        <el-button type="primary" class="btn-add" @click="handleAdd">
          <el-icon><i class="ri-add-line"></i></el-icon> 新建模板
        </el-button>
      </div>
    </div>

    <!-- 2. 顶部统计卡片 -->
    <el-row :gutter="16" class="stats-row">
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">模板总数 <el-icon class="right-icon" color="#2563EB"><i class="ri-notification-3-line"></i></el-icon></div>
          <div class="stat-value">{{ totalCount }}</div>
          <div class="stat-desc">覆盖 5 个业务 · 4 个渠道</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">启用中 <el-icon class="right-icon" color="#10B981"><i class="ri-checkbox-circle-line"></i></el-icon></div>
          <div class="stat-value text-green">{{ enabledCount }}</div>
          <div class="stat-desc text-green">启用 {{ totalCount ? ((enabledCount / totalCount) * 100).toFixed(1) : 0 }}%，已绑定触发事件</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">待审核 <el-icon class="right-icon" color="#F59E0B"><i class="ri-time-line"></i></el-icon></div>
          <div class="stat-value text-orange">{{ pendingCount }}</div>
          <div class="stat-desc">含 1 条高风险模板</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">本月触达 <el-icon class="right-icon" color="#8B5CF6"><i class="ri-bar-chart-fill"></i></el-icon></div>
          <div class="stat-value text-purple">1,286,400</div>
          <div class="stat-desc text-purple">送达率 98.4% · 点击率 12.3%</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 3. 过滤栏 -->
    <div class="filter-bar">
      <el-tabs v-model="activeTab" class="custom-tabs">
        <el-tab-pane label="全部" name="all" />
        <el-tab-pane label="站内信" name="inner" />
        <el-tab-pane label="APP Push" name="app" />
        <el-tab-pane label="短信" name="sms" />
        <el-tab-pane label="企微" name="wecom" />
        <el-tab-pane label="待审核" name="pending" />
      </el-tabs>

      <div class="filter-selects">
        <el-select v-model="filterStatus" placeholder="全部状态" size="small" style="width: 120px">
          <el-option label="全部状态" value="" />
        </el-select>
        <el-select v-model="filterSort" placeholder="最新更新" size="small" style="width: 120px">
          <el-option label="最新更新" value="" />
        </el-select>
        <el-input v-model="searchKeyword" placeholder="搜索标题 / 编码 / 事件" size="small" style="width: 200px" clearable>
          <template #prefix><el-icon><i class="ri-search-line"></i></el-icon></template>
        </el-input>
      </div>
    </div>

    <!-- 4. 数据表格 -->
    <div class="table-container">
      <!-- 批量操作 -->
      <div class="batch-bar" style="margin-bottom: 16px;">
        <el-checkbox v-model="isAllSelected">已选 {{ selectedRows.length }} 项</el-checkbox>
        <el-button size="small" plain>批量启用</el-button>
        <el-button size="small" plain>批量停用</el-button>
        <el-button size="small" plain>批量删除</el-button>
        <div class="right-tip">
          <i class="ri-information-line"></i> 仅展示当前数据表最新状态，修改文案后将生成新版本
        </div>
      </div>

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
        <el-table-column prop="event" label="触发事件" width="120" />
        <el-table-column prop="channel" label="推送渠道" width="120">
          <template #default="{ row }">
            <el-tag :type="getChannelTagType(row.channel)" effect="light" size="small">{{ row.channel }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="target" label="目标人群" width="140" />
        <el-table-column label="近7天数据" width="160">
          <template #default="{ row }">
            <div class="stats-cell">
              <span>发送 {{ row.sent }}</span>
              <span class="click-rate">点击 {{ row.clickRate }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.status === '启用中'" type="success" effect="light" size="small">启用中</el-tag>
            <el-tag v-else-if="row.status === '待审核'" type="warning" effect="light" size="small">待审核</el-tag>
            <el-tag v-else-if="row.status === '已停用'" type="info" effect="light" size="small">已停用</el-tag>
            <el-tag v-else type="danger" effect="light" size="small">草稿</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="更新人/时间" width="140">
          <template #default="{ row }">
            <div class="update-cell">
              <span>{{ row.updater }}</span>
              <span class="time">{{ row.updateTime }}</span>
            </div>
          </template>
        </el-table-column>
        <!-- 💡 核心修改：操作列绑定事件 -->
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

    <!-- 💡 新建/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="isEditing ? '编辑推送模板' : '新建推送模板'" width="600px">
      <el-form :model="formData" label-width="100px">
        <el-form-item label="模板标题" required>
          <el-input v-model="formData.title" placeholder="请输入模板标题" />
        </el-form-item>
        <el-form-item label="模板编码" required>
          <el-input v-model="formData.code" placeholder="例如：PUSH_HIGH_RISK" />
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="触发事件">
              <el-input v-model="formData.event" placeholder="例如：高风险预警" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="推送渠道">
              <el-select v-model="formData.channel" style="width: 100%">
                <el-option label="站内信" value="站内信" />
                <el-option label="APP Push" value="APP Push" />
                <el-option label="短信" value="短信" />
                <el-option label="企微" value="企微" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="目标人群">
          <el-input v-model="formData.target" placeholder="例如：全体用户 / 高风险用户" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitForm">确认{{ isEditing ? '保存' : '新建' }}</el-button>
      </template>
    </el-dialog>

    <!-- 💡 预览抽屉 -->
    <el-drawer v-model="previewVisible" title="模板预览" size="40%">
      <div v-if="currentTemplate" class="preview-content">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="模板标题">{{ currentTemplate.title }}</el-descriptions-item>
          <el-descriptions-item label="模板编码">{{ currentTemplate.code }}</el-descriptions-item>
          <el-descriptions-item label="触发事件">{{ currentTemplate.event }}</el-descriptions-item>
          <el-descriptions-item label="推送渠道">{{ currentTemplate.channel }}</el-descriptions-item>
          <el-descriptions-item label="目标人群">{{ currentTemplate.target }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="currentTemplate.status === '启用中' ? 'success' : 'info'">{{ currentTemplate.status }}</el-tag>
          </el-descriptions-item>
        </el-descriptions>
        <div class="preview-box">
          <div class="preview-label">推送内容预览</div>
          <div class="preview-text">您好，这是一条测试推送消息。</div>
        </div>
      </div>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getPushTemplates, savePushTemplate, updatePushTemplate, updatePushStatus } from '@/api/admin'

const activeTab = ref('all')
const filterStatus = ref('')
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
const isEditing = ref(false)
const previewVisible = ref(false)
const currentTemplate = ref(null)

const formData = reactive({
  id: null, title: '', code: '', event: '', channel: '', target: ''
})

// 统计数据
const totalCount = computed(() => tableData.value.length)
const enabledCount = computed(() => tableData.value.filter(r => r.status === '启用中').length)
const pendingCount = computed(() => tableData.value.filter(r => r.status === '待审核').length)

// 渠道颜色
const getChannelTagType = (channel) => {
  if (channel === '站内信') return 'primary'
  if (channel === 'APP Push') return 'success'
  if (channel === '短信') return 'warning'
  if (channel === '企微') return 'info'
  return 'info'
}

// 获取列表
const fetchTemplates = async () => {
  try {
    const res = await getPushTemplates({ page: currentPage.value, size: pageSize.value })
    const pageData = res.data || res
    const data = pageData.records || []
    total.value = pageData.total || 0

    tableData.value = data.map(item => ({
      id: item.id,
      title: item.title,
      code: item.code,
      event: item.event,
      channel: item.channel,
      target: item.target,
      status: item.status === 1 ? '启用中' : (item.status === 2 ? '待审核' : (item.status === 3 ? '草稿' : '已停用')),
      updater: item.updater,
      updateTime: item.updatedAt ? item.updatedAt.replace('T', ' ').substring(5, 16) : '',
      sent: '0',
      clickRate: '0%'
    }))
  } catch (error) {
    console.error('获取推送模板失败', error)
    ElMessage.error('后端未连接')
  }
}

const handlePageChange = (val) => {
  currentPage.value = val
  fetchTemplates()
}

// 新建
const handleAdd = () => {
  isEditing.value = false
  Object.assign(formData, { id: null, title: '', code: '', event: '', channel: '', target: '' })
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row) => {
  isEditing.value = true
  Object.assign(formData, {
    id: row.id, title: row.title, code: row.code, event: row.event, channel: row.channel, target: row.target
  })
  dialogVisible.value = true
}

// 预览
const handlePreview = (row) => {
  currentTemplate.value = row
  previewVisible.value = true
}

// 提交表单
const submitForm = async () => {
  if (!formData.title || !formData.code) return ElMessage.warning('请填写完整必填项')
  try {
    if (isEditing.value) {
      await updatePushTemplate(formData)
      ElMessage.success('编辑成功')
    } else {
      await savePushTemplate(formData)
      ElMessage.success('新建成功')
    }
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
      await updatePushStatus(row.id, targetStatus)
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
/* 样式完全保留你之前写的，这里只新增了预览抽屉的样式 */
.push-templates-page {
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
    
    .batch-bar {
      display: flex; align-items: center; gap: 12px;
      .right-tip { margin-left: auto; font-size: 12px; color: #94A3B8; display: flex; align-items: center; gap: 4px; }
    }
    .name-cell {
      display: flex; flex-direction: column;
      .name { font-size: 14px; color: #111827; font-weight: 500; }
      .code { font-size: 12px; color: #94A3B8; margin-top: 4px; }
    }
    .stats-cell {
      display: flex; flex-direction: column; font-size: 12px; color: #475569;
      .click-rate { color: #10B981; margin-top: 2px; }
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

  /* 💡 新增预览抽屉样式 */
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