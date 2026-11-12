<template>
  <div class="chat-audit-page">
    <!-- 1. 页面头部 -->
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">对话审计 <el-tag size="small" type="info" effect="plain">全部会话</el-tag> <el-tag size="small" type="success" effect="light">自动审计已开启</el-tag></h2>
        <p class="page-subtitle">对 AI 会话进行敏感、风险命中识别与人工复核，保障合规与健康建议输出合规、可追溯。</p>
      </div>
      <div class="header-right">
        <!-- 💡 绑定事件 -->
        <el-button class="btn-export" @click="handleAuditRules">
          <el-icon><i class="ri-settings-4-line"></i></el-icon> 审计规则
        </el-button>
        <el-button class="btn-export" @click="handleExportReport">
          <el-icon><i class="ri-download-2-line"></i></el-icon> 导出报告
        </el-button>
        <el-button type="primary" class="btn-add" @click="handleCreateTask">
          <el-icon><i class="ri-add-line"></i></el-icon> 新建会话任务
        </el-button>
      </div>
    </div>

    <!-- 2. 顶部统计卡片 -->
    <el-row :gutter="16" class="stats-row">
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">今日会话总量 <el-icon class="right-icon" color="#2563EB"><i class="ri-message-3-line"></i></el-icon></div>
          <div class="stat-value">12,486 <span class="trend text-green">+8.2%</span></div>
          <div class="stat-desc">较昨日 11,538</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">命中风险会话 <el-icon class="right-icon" color="#F59E0B"><i class="ri-alert-line"></i></el-icon></div>
          <div class="stat-value text-orange">186 <span class="trend text-orange">+23 条</span></div>
          <div class="stat-desc">占全部会话 1.49%</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">待人工复核 <el-icon class="right-icon" color="#EF4444"><i class="ri-time-line"></i></el-icon></div>
          <div class="stat-value text-red">42 <span class="trend text-red">高危 8 条</span></div>
          <div class="stat-desc">最长等待 4.2 小时</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">平均安全评分 <el-icon class="right-icon" color="#10B981"><i class="ri-shield-check-line"></i></el-icon></div>
          <div class="stat-value text-green">96.4 <span class="trend text-green">+1.2</span></div>
          <div class="stat-desc">较上周 95.2</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 3. 图表与分布区 -->
    <el-row :gutter="16" class="chart-row">
      <el-col :span="16">
        <el-card shadow="never" class="chart-card">
          <template #header>
            <div class="card-header">
              <span class="card-title">近 7 日风险命中趋势</span>
              <span class="card-subtitle">按命中会话数统计（自动审计）</span>
            </div>
          </template>
          <div class="mock-chart">
            <svg viewBox="0 0 600 200" style="width: 100%; height: 200px;">
              <line x1="0" y1="50" x2="600" y2="50" stroke="#F1F5F9" stroke-width="1" />
              <line x1="0" y1="100" x2="600" y2="100" stroke="#F1F5F9" stroke-width="1" />
              <line x1="0" y1="150" x2="600" y2="150" stroke="#F1F5F9" stroke-width="1" />
              <path d="M0,150 L100,120 L200,140 L300,80 L400,100 L500,60 L600,70" fill="none" stroke="#EF4444" stroke-width="2" />
              <path d="M0,180 L100,160 L200,170 L300,130 L400,150 L500,110 L600,120" fill="none" stroke="#F59E0B" stroke-width="2" />
              <path d="M0,190 L100,180 L200,185 L300,160 L400,170 L500,150 L600,155" fill="none" stroke="#2563EB" stroke-width="2" />
            </svg>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="never" class="chart-card">
          <template #header>
            <div class="card-header"><span class="card-title">风险类型分布</span></div>
          </template>
          <ul class="risk-list">
            <li><span class="label">敏感词命中</span><el-progress :percentage="62" :stroke-width="6" :show-text="false" color="#EF4444" /><span class="val">62%</span></li>
            <li><span class="label">用药与剂量建议</span><el-progress :percentage="44" :stroke-width="6" :show-text="false" color="#F59E0B" /><span class="val">44%</span></li>
            <li><span class="label">高危诊断描述</span><el-progress :percentage="31" :stroke-width="6" :show-text="false" color="#8B5CF6" /><span class="val">31%</span></li>
            <li><span class="label">情绪危机识别缺失</span><el-progress :percentage="27" :stroke-width="6" :show-text="false" color="#2563EB" /><span class="val">27%</span></li>
            <li><span class="label">夸大功效 / 绝对化用语</span><el-progress :percentage="22" :stroke-width="6" :show-text="false" color="#10B981" /><span class="val">22%</span></li>
          </ul>
        </el-card>
      </el-col>
    </el-row>

    <!-- 4. 过滤栏 -->
    <div class="filter-bar">
      <el-input v-model="searchKeyword" placeholder="搜索会话 ID / 用户 / 关键词" size="small" style="width: 240px" clearable @keyup.enter="handleSearch">
        <template #prefix><el-icon><i class="ri-search-line"></i></el-icon></template>
      </el-input>
      <el-select v-model="filterRisk" placeholder="风险等级" size="small" style="width: 120px">
        <el-option label="全部" value="" />
        <el-option label="高危" value="高危" />
        <el-option label="中危" value="中危" />
      </el-select>
      <el-select v-model="filterModel" placeholder="模型" size="small" style="width: 120px">
        <el-option label="全部" value="" />
        <el-option label="GPT-4o" value="GPT-4o" />
      </el-select>
      <el-button type="primary" size="small" style="background: #2563EB;" @click="handleSearch">查询</el-button>
      <el-button size="small" @click="handleReset">重置</el-button>
    </div>

    <!-- 5. 数据表格 -->
    <div class="table-container">
      <el-table :data="tableData" style="width: 100%" row-key="id">
        <el-table-column type="selection" width="55" />
        <el-table-column label="会话 ID" width="140">
          <template #default="{ row }"><span class="session-id">{{ row.id }}</span></template>
        </el-table-column>
        <el-table-column label="用户" width="150">
          <template #default="{ row }">
            <div class="user-cell">
              <span class="name">{{ row.userName }}</span>
              <span class="uid">{{ row.uid }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="scene" label="会话场景" width="120" />
        <el-table-column prop="model" label="模型" width="120" />
        <el-table-column prop="msgCount" label="消息数" width="80" />
        <el-table-column label="风险等级" width="100">
          <template #default="{ row }">
            <el-tag :type="row.risk === '高危' ? 'danger' : 'warning'" size="small" effect="light">{{ row.risk }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="rule" label="命中规则" min-width="180" show-overflow-tooltip />
        <el-table-column label="安全评分" width="100">
          <template #default="{ row }">
            <span class="score" :class="row.score < 80 ? 'text-red' : 'text-green'">{{ row.score }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="lastTime" label="最近消息" width="160" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.status === '待复核'" type="warning" effect="plain" size="small">待复核</el-tag>
            <el-tag v-else-if="row.status === '已复核'" type="success" effect="plain" size="small">已复核</el-tag>
            <el-tag v-else type="info" effect="plain" size="small">已通过</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleDetail(row)">详情</el-button>
            <el-button v-if="row.status === '待复核'" link type="primary" size="small" @click="handleReview(row)">复核</el-button>
            <el-button link type="info" size="small" @click="handleRecord(row)">记录</el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <!-- 分页 -->
      <div class="pagination-wrapper">
        <span class="page-info">共 {{ total }} 条</span>
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

    <!-- 💡 详情/记录 弹窗 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px">
      <div v-if="currentRow">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="会话ID">{{ currentRow.id }}</el-descriptions-item>
          <el-descriptions-item label="用户">{{ currentRow.userName }} ({{ currentRow.uid }})</el-descriptions-item>
          <el-descriptions-item label="风险等级">{{ currentRow.risk }}</el-descriptions-item>
          <el-descriptions-item label="命中规则">{{ currentRow.rule || '无' }}</el-descriptions-item>
          <el-descriptions-item label="安全评分">{{ currentRow.score }}</el-descriptions-item>
        </el-descriptions>
        <div v-if="dialogTitle === '详情'" class="chat-preview">
          <div class="chat-bubble user">我最近总是睡不着觉，很焦虑。</div>
          <div class="chat-bubble ai">理解您的感受。您可以尝试深呼吸，或者联系我们的人工顾问。</div>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRouter } from 'vue-router'
import { getChatAudits, updateChatAuditStatus } from '@/api/admin'

const router = useRouter()

const searchKeyword = ref('')
const filterRisk = ref('')
const filterModel = ref('')

const tableData = ref([])
const currentPage = ref(1)
const pageSize = ref(20)
const total = ref(0)

const dialogVisible = ref(false)
const dialogTitle = ref('')
const currentRow = ref(null)

// ==========================================
// 💡 核心新增：顶部三个按钮的逻辑
// ==========================================

// 1. 审计规则（跳转到提示词模板页面）
// 💡 修改后
const handleAuditRules = () => {
  router.push('/back/conversation-audit/rules') // ✅ 跳转到审计规则页
}

// 2. 导出报告（导出当前表格的数据）
const handleExportReport = () => {
  if (tableData.value.length === 0) {
    return ElMessage.warning('暂无数据可导出')
  }
  ElMessage.success('正在生成报告，即将开始下载...')
  setTimeout(() => {
    // 简单模拟将数据转为 JSON 字符串并下载
    const dataStr = JSON.stringify(tableData.value, null, 2)
    const blob = new Blob([dataStr], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `对话审计报告_${new Date().getTime()}.json`
    link.click()
    URL.revokeObjectURL(url)
  }, 1000)
}

// 3. 新建会话任务（弹出一个简单的确认框）
const handleCreateTask = () => {
  ElMessageBox.prompt('请输入要进行审计的会话 ID', '新建会话任务', {
    confirmButtonText: '确认',
    cancelButtonText: '取消',
  }).then(({ value }) => {
    if (!value) {
      return ElMessage.warning('会话 ID 不能为空')
    }
    ElMessage.success(`已成功创建会话任务：${value}`)
  }).catch(() => {})
}

// ==========================================
// 数据加载与表格操作
// ==========================================
const fetchChatAudits = async () => {
  try {
    const res = await getChatAudits({ 
      page: currentPage.value, 
      size: pageSize.value,
      keyword: searchKeyword.value,
      risk: filterRisk.value,
      model: filterModel.value
    })
    const pageData = res.data || res
    const data = pageData.records || []
    total.value = pageData.total || 0

    tableData.value = data.map(item => ({
      id: item.sessionId,
      realId: item.id,
      userName: item.userName,
      uid: item.uid,
      scene: item.scene,
      model: item.model,
      msgCount: item.msgCount,
      risk: item.riskLevel,
      rule: item.ruleHit,
      score: item.score,
      lastTime: item.lastTime ? item.lastTime.replace('T', ' ').substring(5, 16) : '',
      status: item.status === 1 ? '已通过' : (item.status === 2 ? '待复核' : '已复核')
    }))
  } catch (error) {
    console.error('获取对话审计列表失败', error)
    ElMessage.error('后端未连接')
  }
}

const handleSearch = () => {
  currentPage.value = 1
  fetchChatAudits()
}

const handleReset = () => {
  searchKeyword.value = ''
  filterRisk.value = ''
  filterModel.value = ''
  currentPage.value = 1
  fetchChatAudits()
}

const handlePageChange = (val) => {
  currentPage.value = val
  fetchChatAudits()
}

const handleReview = (row) => {
  ElMessageBox.confirm(`确认复核通过【${row.id}】吗？`, '复核', { type: 'warning' }).then(async () => {
    try {
      await updateChatAuditStatus(row.realId, 3)
      row.status = '已复核'
      ElMessage.success('复核完成！')
    } catch (e) {
      ElMessage.error('复核失败')
    }
  }).catch(() => {})
}

const handleDetail = (row) => {
  currentRow.value = row
  dialogTitle.value = '详情'
  dialogVisible.value = true
}

const handleRecord = (row) => {
  currentRow.value = row
  dialogTitle.value = '审计记录'
  dialogVisible.value = true
}

onMounted(() => {
  fetchChatAudits()
})
</script>

<style scoped lang="scss">
/* 这里保留你之前的样式，没有修改，只补充了弹窗和分页的样式 */
.chat-audit-page {
  padding-bottom: 20px;
  .page-header {
    display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px;
    .header-left {
      .page-title { font-size: 22px; font-weight: 600; color: #111827; margin: 0 0 8px 0; display: flex; align-items: center; gap: 8px; }
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
      .stat-value { font-size: 28px; font-weight: 700; color: #111827; margin: 10px 0 6px; display: flex; align-items: baseline; gap: 8px; }
      .trend { font-size: 12px; font-weight: normal; }
      .stat-desc { font-size: 12px; color: #94A3B8; }
    }
  }

  .text-orange { color: #F59E0B !important; }
  .text-red { color: #EF4444 !important; }
  .text-green { color: #10B981 !important; }

  .chart-row {
    margin-bottom: 20px;
    .chart-card {
      border-radius: 8px; border: none; box-shadow: 0 1px 3px rgba(0,0,0,0.05); height: 100%;
      .card-header {
        .card-title { font-weight: 600; font-size: 15px; color: #111827; }
        .card-subtitle { font-size: 12px; color: #94A3B8; margin-left: 10px; }
      }
    }
    .risk-list {
      list-style: none; padding: 0; margin: 0;
      li {
        display: flex; align-items: center; gap: 10px; margin-bottom: 12px; font-size: 13px;
        .label { width: 120px; color: #475569; }
        .el-progress { flex: 1; }
        .val { width: 40px; text-align: right; color: #64748B; }
      }
    }
  }

  .filter-bar {
    display: flex; gap: 12px; align-items: center; background: #FFF; padding: 16px; border-radius: 8px; margin-bottom: 20px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
  }

  .table-container {
    background: #FFF; border-radius: 8px; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    .session-id { color: #2563EB; font-weight: 500; }
    .user-cell {
      display: flex; flex-direction: column;
      .name { font-size: 14px; color: #111827; font-weight: 500; }
      .uid { font-size: 12px; color: #94A3B8; margin-top: 2px; }
    }
    .score { font-weight: 700; font-size: 15px; }
    
    .pagination-wrapper {
      margin-top: 20px; display: flex; justify-content: space-between; align-items: center;
      .page-info { font-size: 13px; color: #64748B; }
    }
  }
}

.chat-preview {
  margin-top: 20px;
  background: #F8FAFC; padding: 20px; border-radius: 8px;
  .chat-bubble {
    max-width: 80%; padding: 10px 15px; border-radius: 8px; margin-bottom: 10px; font-size: 14px; line-height: 1.5;
    &.user { background: #DBEAFE; color: #1E3A8A; margin-left: auto; }
    &.ai { background: #FFF; color: #374151; border: 1px solid #E2E8F0; }
  }
}
</style>