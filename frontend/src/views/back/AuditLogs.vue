<template>
  <div class="audit-logs-page">
    <!-- 顶部提示条 -->
    <div class="notice-bar">
      <el-icon color="#2563eb" size="16"><InfoFilled /></el-icon>
      <span>本日志由系统自动写入，任何人（含超级管理员）均不可编辑或删除；到期自动归档冷存储。<el-link type="primary" :underline="false">查看存储规则</el-link></span>
    </div>

    <!-- 顶部统计卡片 (全部动态计算) -->
    <el-row :gutter="16" class="stats-row">
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">今日操作数 <el-icon color="#64748b"><Document /></el-icon></div>
          <div class="stat-value">{{ total }}</div>
          <div class="stat-desc"><span class="text-green">↑ 6.2%</span> 较昨日 1,369 次</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card danger">
          <div class="stat-title">高危操作数 <el-icon color="#ef4444"><Warning /></el-icon></div>
          <div class="stat-value text-red">{{ dangerCount }}</div>
          <div class="stat-desc"><span class="text-red">+4 次</span> 操作人 19 次，需关注</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card warning">
          <div class="stat-title">待审批导出 <el-icon color="#f59e0b"><Lock /></el-icon></div>
          <div class="stat-value text-orange">3</div>
          <div class="stat-desc">最长等待 42 分钟</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">敏感数据访问 <el-icon color="#3b82f6"><View /></el-icon></div>
          <div class="stat-value text-purple">87</div>
          <div class="stat-desc">↑ 12 次 水印覆盖 100%</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 筛选工具栏 -->
    <div class="filter-bar">
      <el-input 
        v-model="queryParams.keyword" 
        placeholder="日志编号/操作人/对象 ID" 
        style="width: 220px" 
        size="small" 
        clearable 
        @keyup.enter="handleSearch"
      >
        <template #prefix><el-icon><Search /></el-icon></template>
      </el-input>
      
      <el-select v-model="queryParams.riskLevel" placeholder="全部操作类型" size="small" clearable style="width: 120px">
        <el-option label="高危操作" value="danger" />
        <el-option label="关注操作" value="warning" />
        <el-option label="常规操作" value="normal" />
      </el-select>
      
      <!-- 补齐设计图里的其他筛选项 -->
      <el-select v-model="queryParams.status" placeholder="全部执行结果" size="small" clearable style="width: 120px">
        <el-option label="成功" value="success" />
        <el-option label="失败" value="fail" />
      </el-select>
      
      <el-button type="primary" size="small" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
      <el-button size="small" @click="handleReset">重置</el-button>
    </div>

    <!-- 数据表格 -->
    <div class="table-container">
      <el-table :data="tableData" style="width: 100%" v-loading="loading" row-key="id">
        <el-table-column label="日志编号" width="160">
          <template #default="{ row }">
            <span class="log-code">{{ row.logCode }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作时间" width="170">
          <template #default="{ row }">
            {{ row.createdAt ? row.createdAt.replace('T', ' ').substring(0, 19) : '-' }}
          </template>
        </el-table-column>
        <el-table-column label="操作人" width="180">
          <template #default="{ row }">
            <div class="operator-cell">
              <el-avatar :size="26" style="background: #eff6ff; color: #2563eb; font-size: 12px">{{ row.operatorName?.charAt(0) }}</el-avatar>
              <div>
                <div class="name">{{ row.operatorName }}</div>
                <div class="account">{{ row.operatorRole }}</div>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="操作类型" width="160">
          <template #default="{ row }">
            <div class="action-cell">
              <el-icon><Operation /></el-icon>
              {{ row.action }}
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="target" label="操作对象" width="140" />
        <el-table-column prop="changeSummary" label="变更摘要" min-width="200" show-overflow-tooltip />
        <el-table-column prop="sourceIp" label="来源 IP" width="130" />
        <el-table-column label="风险" width="90">
          <template #default="{ row }">
            <el-tag :type="getRiskType(row.riskLevel)" size="small" effect="dark">
              {{ getRiskText(row.riskLevel) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="执行结果" width="100">
          <template #default="{ row }">
            <span :class="row.status === 'success' ? 'text-green' : 'text-red'">
              {{ row.status === 'success' ? '成功' : '失败' }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="80" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleView(row)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <span class="page-info">共 {{ total }} 条记录</span>
        <el-pagination
          background
          layout="prev, pager, next"
          :total="total"
          :page-size="queryParams.size"
          v-model:current-page="queryParams.page"
          @current-change="fetchLogs"
        />
      </div>
    </div>

    <!-- 右侧详情抽屉 -->
    <el-drawer v-model="drawerVisible" title="日志详情" size="400px">
      <div class="detail-content" v-if="currentLog">
        <div class="detail-section">
          <h4>基本信息</h4>
          <el-descriptions :column="1" border size="small">
            <el-descriptions-item label="日志编号">{{ currentLog.logCode }}</el-descriptions-item>
            <el-descriptions-item label="操作时间">{{ currentLog.createdAt }}</el-descriptions-item>
            <el-descriptions-item label="操作人">{{ currentLog.operatorName }}</el-descriptions-item>
            <el-descriptions-item label="角色">{{ currentLog.operatorRole }}</el-descriptions-item>
            <el-descriptions-item label="操作动作">{{ currentLog.action }}</el-descriptions-item>
            <el-descriptions-item label="操作对象">{{ currentLog.target }}</el-descriptions-item>
            <el-descriptions-item label="变更摘要">{{ currentLog.changeSummary }}</el-descriptions-item>
            <el-descriptions-item label="来源 IP">{{ currentLog.sourceIp }}</el-descriptions-item>
            <el-descriptions-item label="风险等级">
              <el-tag :type="getRiskType(currentLog.riskLevel)" size="small">{{ getRiskText(currentLog.riskLevel) }}</el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="执行结果">
              <span :class="currentLog.status === 'success' ? 'text-green' : 'text-red'">{{ currentLog.status === 'success' ? '成功' : '失败' }}</span>
            </el-descriptions-item>
          </el-descriptions>
        </div>
      </div>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { InfoFilled, Document, Warning, Lock, View, Search, Operation } from '@element-plus/icons-vue'
import { getAuditLogs } from '@/api/admin' // 💡 改为从 api 统一管理引入

const tableData = ref([])
const total = ref(0)
const loading = ref(false)

const drawerVisible = ref(false)
const currentLog = ref(null)

const queryParams = ref({
  page: 1,
  size: 10,
  keyword: '',
  riskLevel: '',
  status: ''
})

// 统计高危数量
const dangerCount = computed(() => tableData.value.filter(r => r.riskLevel === 'danger').length)

// 根据风险等级返回标签类型
const getRiskType = (level) => {
  if (level === 'danger') return 'danger'
  if (level === 'warning') return 'warning'
  return 'info'
}

const getRiskText = (level) => {
  if (level === 'danger') return '高危'
  if (level === 'warning') return '关注'
  return '常规'
}

// 获取日志列表
const fetchLogs = async () => {
  loading.value = true
  try {
    const res = await getAuditLogs(queryParams.value) // 💡 改为调用封装好的 API
    if (res.code === '200' || res.code === 200) {
      tableData.value = res.data.records || []
      total.value = res.data.total || 0
    }
  } catch (error) {
    ElMessage.error('获取审计日志失败')
  } finally {
    loading.value = false
  }
}

// 搜索/重置
const handleSearch = () => {
  queryParams.value.page = 1
  fetchLogs()
}
const handleReset = () => {
  queryParams.value = { page: 1, size: 10, keyword: '', riskLevel: '', status: '' }
  fetchLogs()
}

// 查看详情
const handleView = (row) => {
  currentLog.value = { ...row }
  drawerVisible.value = true
}

onMounted(() => {
  fetchLogs()
})
</script>

<style scoped lang="scss">
.audit-logs-page {
  padding: 20px;
  background: #f8fafc;
  min-height: 100vh;

  .notice-bar {
    background: #eff6ff;
    border: 1px solid #bfdbfe;
    border-radius: 8px;
    padding: 12px 16px;
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 13px;
    color: #1e40af;
    margin-bottom: 20px;
  }

  .stats-row {
    margin-bottom: 20px;
    .stat-card {
      border-radius: 8px; border: none; box-shadow: 0 1px 3px rgba(0,0,0,0.05);
      .stat-title { font-size: 13px; color: #64748b; display: flex; justify-content: space-between; align-items: center; }
      .stat-value { font-size: 24px; font-weight: bold; margin: 10px 0 6px; color: #111827; }
      .stat-desc { font-size: 12px; color: #94a3b8; }
      &.danger { border-left: 3px solid #ef4444; }
      &.warning { border-left: 3px solid #f59e0b; }
    }
  }
  
  .text-red { color: #ef4444 !important; }
  .text-green { color: #10b981 !important; }
  .text-orange { color: #f59e0b !important; }
  .text-purple { color: #8b5cf6 !important; }

  .filter-bar {
    display: flex;
    gap: 12px;
    margin-bottom: 20px;
    background: #fff;
    padding: 16px;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    align-items: center;
  }

  .table-container {
    background: #fff;
    border-radius: 8px;
    padding: 20px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);

    .log-code { font-family: monospace; color: #2563eb; font-weight: 500; }
    
    .operator-cell {
      display: flex; align-items: center; gap: 8px;
      .name { font-size: 13px; font-weight: 500; color: #111827; }
      .account { font-size: 12px; color: #64748b; }
    }

    .action-cell {
      display: flex; align-items: center; gap: 6px; font-size: 13px;
      .el-icon { color: #64748b; }
    }

    .pagination-wrapper {
      margin-top: 20px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      .page-info { font-size: 13px; color: #64748b; }
    }
  }
}
</style>