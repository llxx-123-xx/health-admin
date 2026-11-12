<template>
  <div class="risk-alerts-page">
    <!-- 1. 页面标题与操作按钮 -->
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">风险预警</h2>
        <p class="page-subtitle">今日新增 {{ todayNew }} 条 · 高风险需 24 小时内完成跟进</p>
      </div>
      <div class="header-right">
        <el-button class="btn-export" @click="goToRules"><el-icon><i class="ri-settings-4-line"></i></el-icon> 预警规则配置</el-button>
        <el-button class="btn-export"><el-icon><i class="ri-download-2-line"></i></el-icon> 导出</el-button>
        <el-button type="primary" class="btn-add"><el-icon><i class="ri-add-line"></i></el-icon> 手动创建预警</el-button>
      </div>
    </div>

    <!-- 2. 顶部统计卡片 -->
    <el-row :gutter="16" class="stats-row">
      <el-col :span="6">
        <el-card shadow="never" class="stat-card red-card">
          <div class="stat-title">
            高风险待处理
            <el-icon class="right-icon" color="#EF4444"><i class="ri-error-warning-fill"></i></el-icon>
          </div>
          <div class="stat-value text-red">{{ highRiskCount }}</div>
          <div class="stat-desc">其中 {{ overdueCount }} 条已超时</div>
        </el-card>
      </el-col>
      
      <el-col :span="6">
        <el-card shadow="never" class="stat-card orange-card">
          <div class="stat-title">
            中风险待处理
            <el-icon class="right-icon" color="#F59E0B"><i class="ri-alert-fill"></i></el-icon>
          </div>
          <div class="stat-value text-orange">{{ midRiskCount }}</div>
          <div class="stat-desc">较昨日 +3</div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="never" class="stat-card blue-card">
          <div class="stat-title">
            今日新增
            <el-icon class="right-icon" color="#2563EB"><i class="ri-add-circle-fill"></i></el-icon>
          </div>
          <div class="stat-value text-blue">{{ todayNew }}</div>
          <div class="stat-desc">来源: 量表 5 / AI 2 / 体征 1</div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="never" class="stat-card green-card">
          <div class="stat-title">
            本月已闭环
            <el-icon class="right-icon" color="#10B981"><i class="ri-checkbox-circle-fill"></i></el-icon>
          </div>
          <div class="stat-value text-green">{{ closedCount }}</div>
          <div class="stat-desc text-green">闭环率 92.0%</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 3. 过滤栏 -->
    <div class="filter-bar">
      <el-tabs v-model="activeTab" class="custom-tabs" @tab-change="handleTabChange">
        <el-tab-pane label="全部" name="all" />
        <el-tab-pane label="高风险" name="high" />
        <el-tab-pane label="中风险" name="mid" />
        <el-tab-pane label="已闭环" name="closed" />
        <el-tab-pane label="已忽略" name="ignored" />
      </el-tabs>

      <div class="filter-selects">
        <el-select v-model="filterSource" placeholder="全部来源" size="small" style="width: 120px" @change="fetchOrders">
          <el-option label="全部来源" value="" />
          <el-option label="量表" value="量表" />
          <el-option label="AI 对话" value="AI 对话" />
        </el-select>
        <el-date-picker v-model="filterDate" type="daterange" range-separator="至" start-placeholder="近 7 天" end-placeholder="近 7 天" size="small" style="width: 200px" />
      </div>
    </div>

    <!-- 4. 数据表格 -->
    <div class="table-container">
      <!-- 批量操作栏 -->
      <div class="batch-actions">
        <span class="table-title"><el-icon><i class="ri-list-check"></i></el-icon> 预警记录 <span class="sub-count">共 {{ tableData.length }} 条</span></span>
        <div class="right-actions">
          <el-button link><el-icon><i class="ri-user-add-line"></i></el-icon> 批量分配</el-button>
          <el-button link @click="fetchOrders"><el-icon><i class="ri-refresh-line"></i></el-icon></el-button>
        </div>
      </div>

      <el-table :data="tableData" style="width: 100%" row-key="id" class="custom-table">
        <el-table-column prop="id" label="预警ID" width="120">
          <template #default="{ row }">
            <span class="alert-id">{{ row.id }}</span>
          </template>
        </el-table-column>
        
        <el-table-column label="用户" min-width="150">
          <template #default="{ row }">
            <div class="user-info-cell">
              <el-avatar :size="32" :src="row.avatar">{{ row.userName.charAt(0) }}</el-avatar>
              <div class="name-box">
                <span class="name">{{ row.userName }}</span>
                <span class="uid">{{ row.uid }}</span>
              </div>
            </div>
          </template>
        </el-table-column>

        <el-table-column label="来源" width="120">
          <template #default="{ row }">
            <el-tag :type="getSourceTagType(row.source)" effect="light" size="small" class="source-tag">
              {{ row.source }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="condition" label="触发原因" min-width="220" show-overflow-tooltip />
        
        <el-table-column label="等级" width="100">
          <template #default="{ row }">
            <el-tag :type="row.level === '高危' ? 'danger' : 'warning'" size="small" effect="dark" class="level-tag">
              <i v-if="row.level === '高危'" class="ri-error-warning-fill"></i> {{ row.level }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column label="触发时间" width="150">
          <template #default="{ row }">
            <div class="time-cell">
              <span>{{ row.triggerTime }}</span>
              <span class="time-desc text-red" v-if="row.isOverdue">已超时</span>
              <span class="time-desc text-orange" v-else-if="row.remainTime">剩余 {{ row.remainTime }}</span>
            </div>
          </template>
        </el-table-column>

        <el-table-column label="状态" width="120">
          <template #default="{ row }">
            <div class="status-cell">
              <el-tag v-if="row.status === '待处理'" type="danger" effect="plain" size="small">待处理</el-tag>
              <el-tag v-else-if="row.status === '跟进中'" type="primary" effect="plain" size="small">跟进中</el-tag>
              <el-tag v-else-if="row.status === '已闭环'" type="success" effect="plain" size="small">已闭环</el-tag>
              <el-tag v-else type="info" effect="plain" size="small">已忽略</el-tag>
            </div>
          </template>
        </el-table-column>

        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <!-- 💡 绑定跟进事件 -->
            <el-button link type="primary" size="small" 
              @click="handleFollowUp(row)" 
              v-if="row.status === '待处理' || row.status === '跟进中'">
              {{ row.status === '待处理' ? '跟进' : '继续' }}
            </el-button>
            <!-- 💡 绑定详情事件 -->
            <el-button link type="info" size="small" @click="handleDetail(row)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <span class="page-info">显示 1-{{ tableData.length }} 条，共 {{ tableData.length }} 条记录</span>
        <el-pagination background layout="prev, pager, next" :total="tableData.length" :page-size="10" />
      </div>
    </div>

    <!-- 💡 详情抽屉 -->
    <el-drawer v-model="detailVisible" title="预警详情" size="40%">
      <div v-if="currentOrder" class="detail-content">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="预警ID">{{ currentOrder.id }}</el-descriptions-item>
          <el-descriptions-item label="用户">{{ currentOrder.userName }} ({{ currentOrder.uid }})</el-descriptions-item>
          <el-descriptions-item label="来源">{{ currentOrder.source }}</el-descriptions-item>
          <el-descriptions-item label="风险等级">
            <el-tag :type="currentOrder.level === '高危' ? 'danger' : 'warning'">{{ currentOrder.level }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="触发原因">{{ currentOrder.condition }}</el-descriptions-item>
          <el-descriptions-item label="触发时间">{{ currentOrder.triggerTime }}</el-descriptions-item>
          <el-descriptions-item label="状态">{{ currentOrder.status }}</el-descriptions-item>
        </el-descriptions>
      </div>
    </el-drawer>

    <!-- 💡 跟进弹窗 -->
    <el-dialog v-model="followUpVisible" title="预警跟进" width="500px">
      <el-form :model="followUpForm" label-width="80px">
        <el-form-item label="跟进记录" required>
          <el-input v-model="followUpForm.remark" type="textarea" :rows="4" placeholder="请填写跟进记录..." />
        </el-form-item>
        <el-form-item label="处理结果">
          <el-radio-group v-model="followUpForm.result">
            <el-radio label="跟进中">继续跟进</el-radio>
            <el-radio label="已闭环">确认闭环</el-radio>
            <el-radio label="已忽略">误报忽略</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="followUpVisible = false">取消</el-button>
        <el-button type="primary" @click="submitFollowUp">提交</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useRouter } from 'vue-router'
import { getWarningOrders } from '@/api/admin'

const router = useRouter()

// ==========================================
// ✅ 1. 基础状态与数据
// ==========================================
const activeTab = ref('all')
const filterSource = ref('')
const filterDate = ref([])
const tableData = ref([])

const todayNew = ref(0)

// 动态统计卡片数据
const highRiskCount = computed(() => tableData.value.filter(r => r.level === '高危' && r.status === '待处理').length)
const midRiskCount = computed(() => tableData.value.filter(r => r.level === '中危' && r.status === '待处理').length)
const closedCount = computed(() => tableData.value.filter(r => r.status === '已闭环').length)
const overdueCount = computed(() => tableData.value.filter(r => r.isOverdue).length)

// ==========================================
// ✅ 2. 弹窗控制
// ==========================================
const detailVisible = ref(false)
const currentOrder = ref(null)

const followUpVisible = ref(false)
const followUpForm = reactive({ id: null, remark: '', result: '已闭环' })

// ==========================================
// ✅ 3. 获取数据
// ==========================================
const fetchOrders = async () => {
  try {
    const res = await getWarningOrders()
    const data = res.data || res || []
    
    tableData.value = data.map(item => ({
      id: 'WARN-' + String(item.id).padStart(4, '0'),
      userName: item.userName,
      uid: item.uid,
      avatar: '',
      source: item.source,
      condition: item.triggerReason,
      level: item.riskLevel,
      triggerTime: item.triggerTime ? item.triggerTime.replace('T', ' ').substring(5, 16) : '',
      isOverdue: item.isOverdue === 1,
      remainTime: item.remainTime,
      status: item.status
    }))
    
    todayNew.value = tableData.value.length // 模拟今日新增
  } catch (error) {
    console.error('获取列表失败', error)
    tableData.value = []
  }
}

// ==========================================
// ✅ 4. 辅助方法 & 交互事件
// ==========================================
const getSourceTagType = (source) => {
  if (source === '量表') return ''
  if (source === 'AI 对话') return 'success'
  if (source === '指标') return 'warning'
  return 'info'
}

const handleTabChange = (tabName) => {
  activeTab.value = tabName
  // TODO: 以后接后端时，在这里根据 tabName 重新请求带参数的数据
}

const goToRules = () => {
  router.push('/back/warning-rules')
}

// 点击详情
const handleDetail = (row) => {
  currentOrder.value = row
  detailVisible.value = true
}

// 点击跟进
const handleFollowUp = (row) => {
  followUpForm.id = row.id
  followUpForm.remark = ''
  followUpForm.result = '已闭环'
  followUpVisible.value = true
}

// 提交跟进
const submitFollowUp = () => {
  if (!followUpForm.remark.trim()) {
    ElMessage.warning('请填写跟进记录')
    return
  }
  
  const targetRow = tableData.value.find(item => item.id === followUpForm.id)
  if (targetRow) {
    targetRow.status = followUpForm.result
    ElMessage.success(`已更新状态为：${followUpForm.result}`)
  }
  
  followUpVisible.value = false
}

// 页面加载时请求
onMounted(() => {
  fetchOrders()
})
</script>

<style scoped lang="scss">
/* 你的样式完全保留不变 */
.risk-alerts-page {
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
      border-radius: 8px; border: none; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05); padding: 4px;
      position: relative;
      &::before { content: ''; position: absolute; top: 12px; right: 12px; width: 6px; height: 6px; border-radius: 50%; }
      &.red-card::before { background-color: #EF4444; }
      &.orange-card::before { background-color: #F59E0B; }
      &.blue-card::before { background-color: #2563EB; }
      &.green-card::before { background-color: #10B981; }

      .stat-title {
        font-size: 13px; color: #64748B; display: flex; justify-content: space-between; align-items: center;
        .right-icon { font-size: 18px; }
      }
      .stat-value { font-size: 28px; font-weight: 700; color: #111827; margin: 10px 0 6px; }
      .stat-desc { font-size: 12px; color: #94A3B8; }
    }
  }

  .text-red { color: #EF4444 !important; }
  .text-orange { color: #F59E0B !important; }
  .text-blue { color: #2563EB !important; }
  .text-green { color: #10B981 !important; }

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
    background: #FFF; border-radius: 8px; padding: 20px; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    
    .batch-actions {
      display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;
      .table-title {
        font-size: 15px; font-weight: 600; color: #111827; display: flex; align-items: center; gap: 6px;
        .sub-count { font-size: 12px; color: #94A3B8; font-weight: normal; margin-left: 6px; }
      }
      .right-actions { display: flex; gap: 12px; align-items: center; .el-button { padding: 0; } }
    }

    .custom-table {
      :deep(.el-table__header th) { background-color: #F8FAFC; color: #64748B; font-weight: 500; }
      .alert-id { color: #2563EB; font-weight: 500; }
      .user-info-cell {
        display: flex; align-items: center; gap: 10px;
        .name-box {
          display: flex; flex-direction: column;
          .name { font-size: 14px; color: #111827; font-weight: 500; }
          .uid { font-size: 12px; color: #94A3B8; }
        }
      }
      .source-tag { border-radius: 4px; }
      .level-tag { border-radius: 4px; font-weight: 600; display: inline-flex; align-items: center; gap: 4px; padding: 0 8px; }
      .time-cell { display: flex; flex-direction: column; .time-desc { font-size: 12px; margin-top: 4px; } }
      .status-cell { display: flex; align-items: center; }
    }

    .pagination-wrapper {
      margin-top: 20px; display: flex; justify-content: space-between; align-items: center;
      .page-info { font-size: 13px; color: #64748B; }
    }
  }

  /* 详情抽屉 */
  .detail-content {
    padding: 10px;
  }
}
</style>