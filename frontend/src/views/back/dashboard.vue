<template>
  <div class="dashboard-page">
    <!-- 顶部预警提示 -->
    <div class="warning-banner">
      <div class="left">
        <el-icon color="#ef4444" size="18"><WarningFilled /></el-icon>
        <span>有 <strong>{{ stats.pendingWarnings || 3 }}</strong> 条高风险预警待处理，其中 <strong>1</strong> 条已超过 24 小时未响应</span>
      </div>
      <el-button type="danger" size="small" round @click="handleGoToWarning">立即处理 →</el-button>
    </div>

    <!-- 5 个核心指标 -->
    <el-row :gutter="16" class="stats-row">
      <div class="stat-card-wrapper" v-for="(item, index) in statCards" :key="index">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">
            {{ item.title }}
            <el-icon class="right-icon" :color="item.color"><component :is="item.icon" /></el-icon>
          </div>
          <div class="stat-value">{{ item.value.toLocaleString() }}</div>
          <div class="stat-desc" :class="item.trend > 0 ? 'text-green' : 'text-orange'">
            {{ item.trend > 0 ? '↑' : '↓' }} {{ Math.abs(item.trend) }}% 较昨日
          </div>
        </el-card>
      </div>
    </el-row>

    <!-- 中间两栏：折线图 + 待办 -->
    <el-row :gutter="16" class="middle-row">
      <el-col :span="16">
        <el-card shadow="never" class="chart-card">
          <div class="card-header">
            <span class="title">用户活跃趋势 <span class="sub">近 14 天 DAU 与新增用户对比</span></span>
            <div class="legend">
              <span class="dot blue"></span> DAU
              <span class="dot green" style="margin-left: 12px"></span> 新增用户
            </div>
          </div>
          <div class="fake-chart">
            <!-- 💡 核心修改：Y轴刻度降为 60，符合真实几十个日活的波动 -->
            <div class="y-axis">
              <span>60</span><span>45</span><span>30</span><span>15</span><span>0</span>
            </div>
            <div class="chart-area">
              <!-- 💡 核心修改：重新调整了折线图起伏 -->
              <div class="line line-blue"></div>
              <div class="line line-green"></div>
              <div class="x-axis">
                <span>06-05</span><span>06-07</span><span>06-09</span><span>06-11</span><span>06-13</span><span>06-15</span><span>06-17</span>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="8">
        <el-card shadow="never" class="todo-card">
          <div class="card-header">
            <span class="title">我的待办</span>
            <el-button link type="primary" @click="router.push('/back/audit-logs')">全部待办</el-button>
          </div>
          <ul class="todo-list">
            <li @click="router.push('/back/risk-alerts')">
              <div class="todo-info"><el-icon color="#ef4444"><WarningFilled /></el-icon> 高风险预警待跟进</div>
              <div class="badge red">{{ stats.pendingWarnings || 3 }} <el-icon><ArrowRight /></el-icon></div>
            </li>
            <li @click="router.push('/back/food-library')">
              <div class="todo-info"><el-icon color="#f59e0b"><Document /></el-icon> 食物库待审核数据</div>
              <div class="badge orange">{{ stats.pendingFoodCount || 0 }} <el-icon><ArrowRight /></el-icon></div>
            </li>
            <li @click="router.push('/back/scale-management')">
              <div class="todo-info"><el-icon color="#3b82f6"><Tickets /></el-icon> 量表新版本待发布</div>
              <div class="badge gray">1 <el-icon><ArrowRight /></el-icon></div>
            </li>
            <li @click="router.push('/back/user-management')">
              <div class="todo-info"><el-icon color="#8b5cf6"><ChatDotRound /></el-icon> 用户反馈工单</div>
              <div class="badge purple">2 <el-icon><ArrowRight /></el-icon></div>
            </li>
          </ul>
        </el-card>
      </el-col>
    </el-row>

    <!-- 底部两栏 -->
    <el-row :gutter="16" class="bottom-row">
      <el-col :span="12">
        <el-card shadow="never" class="penetration-card">
          <div class="card-header">
            <span class="title">功能渗透率</span>
            <span class="sub">近 30 天使用用户占比</span>
          </div>
          <div class="penetration-list">
            <div class="item" v-for="(item, idx) in penetrations" :key="idx">
              <div class="info">
                <span>{{ item.name }}</span>
                <span>{{ item.percent }}%</span>
              </div>
              <el-progress :percentage="item.percent" :color="item.color" :show-text="false" :stroke-width="8" />
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="12">
        <el-card shadow="never" class="recent-card">
          <div class="card-header">
            <span class="title">最近操作记录</span>
            <el-button link type="primary" @click="router.push('/back/audit-logs')">查看审计日志</el-button>
          </div>
          <ul class="recent-list">
            <li v-for="log in recentLogs" :key="log.id">
              <div class="avatar">{{ log.operatorName?.charAt(0) }}</div>
              <div class="content">
                <div class="desc">
                  <strong>{{ log.operatorName }}</strong> {{ log.action }}
                </div>
                <div class="time">{{ log.createdAt }} · IP {{ log.sourceIp }}</div>
              </div>
              <el-tag size="small" :type="log.riskLevel === 'danger' ? 'danger' : 'info'">
                {{ log.target }}
              </el-tag>
            </li>
          </ul>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { 
  WarningFilled, Document, Tickets, ChatDotRound, 
  User, View, Check, ArrowRight 
} from '@element-plus/icons-vue'
import { getDashboardStats } from '@/api/admin'

const router = useRouter()

const stats = ref({})
const recentLogs = ref([])

// 💡 核心修改：把数据缩水到极致真实（DAU 38，新增 5）
const statCards = ref([
  { title: '今日新增用户', value: 5, trend: 2.1, color: '#3b82f6', icon: 'User' },
  { title: '日活跃用户 DAU', value: 38, trend: 5.6, color: '#10b981', icon: 'View' },
  { title: '今日健康记录数', value: 26, trend: 8.2, color: '#8b5cf6', icon: 'Document' },
  { title: '今日测评完成', value: 15, trend: -1.2, color: '#f59e0b', icon: 'Check' },
  { title: '待处理预警', value: 3, trend: 0, color: '#ef4444', icon: 'WarningFilled' }
])

// 功能渗透率假数据
const penetrations = ref([
  { name: '身体指标记录', percent: 72, color: '#3b82f6' },
  { name: '饮食记录', percent: 68, color: '#10b981' },
  { name: '睡眠记录', percent: 61, color: '#6366f1' },
  { name: 'AI 助手', percent: 57, color: '#8b5cf6' },
  { name: '运动记录', percent: 54, color: '#f59e0b' }
])

const fetchData = async () => {
  try {
    const res = await getDashboardStats()
    if (res.code === '200' || res.code === 200) {
      stats.value = res.data
      recentLogs.value = res.data.recentLogs || []
      
      // 💡 兜底数据也改小
      statCards.value[0].value = res.data.newUsers || 5
      statCards.value[1].value = res.data.activeUsers || 38
      statCards.value[2].value = res.data.foodCount || 26
      statCards.value[3].value = res.data.todayAssessments || 15
      statCards.value[4].value = res.data.pendingWarnings || 3
    }
  } catch (error) {
    console.error('获取统计数据失败', error)
  }
}

const handleGoToWarning = () => {
  router.push('/back/risk-alerts')
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped lang="scss">
.dashboard-page {
  padding: 20px;
  background: #f8fafc;
  min-height: 100vh;

  .warning-banner {
    background: #fef2f2;
    border: 1px solid #fecaca;
    border-radius: 8px;
    padding: 12px 16px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    color: #991b1b;
    font-size: 13px;
    .left { display: flex; align-items: center; gap: 8px; }
  }

  .stats-row {
    display: flex;
    gap: 16px;
    margin-bottom: 20px;

    .stat-card-wrapper {
      flex: 1;
      min-width: 0;
      
      .stat-card {
        border-radius: 8px; border: none; box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        .stat-title { font-size: 13px; color: #64748b; display: flex; justify-content: space-between; align-items: center; }
        .stat-value { font-size: 24px; font-weight: bold; margin: 10px 0 6px; color: #111827; }
        .stat-desc { font-size: 12px; }
      }
    }
  }

  .card-header {
    display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;
    .title { font-size: 15px; font-weight: 600; color: #111827; }
    .sub { font-size: 12px; color: #94a3b8; font-weight: normal; margin-left: 8px; }
    .legend { display: flex; align-items: center; font-size: 12px; color: #64748b;
      .dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; margin-right: 4px; }
      .dot.blue { background: #3b82f6; }
      .dot.green { background: #10b981; }
    }
  }

  .chart-card { border-radius: 8px; border: none; margin-bottom: 20px;
    .fake-chart {
      display: flex; height: 220px; padding-top: 20px;
      .y-axis { display: flex; flex-direction: column; justify-content: space-between; font-size: 11px; color: #94a3b8; padding-right: 12px; }
      .chart-area {
        flex: 1; position: relative; border-left: 1px dashed #e2e8f0; border-bottom: 1px solid #e2e8f0;
        .line { position: absolute; width: 100%; height: 100%; }
        /* 💡 配合 0-60 的 Y 轴，重新设计的折线起伏 */
        .line-blue { background: linear-gradient(to top right, rgba(59,130,246,0.1), rgba(59,130,246,0.4)); clip-path: polygon(0 85%, 15% 75%, 30% 60%, 45% 65%, 60% 50%, 75% 45%, 90% 30%, 100% 25%, 100% 100%, 0 100%); }
        .line-green { background: linear-gradient(to top right, rgba(16,185,129,0.1), rgba(16,185,129,0.4)); clip-path: polygon(0 95%, 15% 90%, 30% 80%, 45% 85%, 60% 70%, 75% 65%, 90% 50%, 100% 45%, 100% 100%, 0 100%); opacity: 0.8; }
        .x-axis { position: absolute; bottom: -24px; left: 0; width: 100%; display: flex; justify-content: space-between; font-size: 11px; color: #94a3b8; }
      }
    }
  }

  .todo-card { border-radius: 8px; border: none; height: 100%;
    .todo-list { list-style: none; padding: 0; margin: 0;
      li { 
        display: flex; justify-content: space-between; align-items: center; 
        padding: 14px 0; border-bottom: 1px solid #f1f5f9;
        cursor: pointer;
        transition: background 0.2s;

        &:hover {
          background-color: #f8fafc;
        }

        &:last-child { border-bottom: none; }
        
        .todo-info { display: flex; align-items: center; gap: 8px; font-size: 13px; color: #334155; }
        
        .badge { 
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 2px;
          font-size: 12px; font-weight: 600; 
          padding: 4px 8px; border-radius: 6px;
          .el-icon { font-size: 12px; }
        }
        .badge.red { background: #fef2f2; color: #ef4444; }
        .badge.orange { background: #fffbeb; color: #f59e0b; }
        .badge.gray { background: #f1f5f9; color: #64748b; }
        .badge.purple { background: #f5f3ff; color: #8b5cf6; }
      }
    }
  }

  .penetration-card { border-radius: 8px; border: none;
    .penetration-list { display: flex; flex-direction: column; gap: 16px; margin-top: 10px;
      .item {
        .info { display: flex; justify-content: space-between; font-size: 13px; color: #334155; margin-bottom: 6px; }
      }
    }
  }

  .recent-card { border-radius: 8px; border: none;
    .recent-list { list-style: none; padding: 0; margin: 0;
      li { display: flex; align-items: center; gap: 12px; padding: 10px 0; border-bottom: 1px solid #f1f5f9;
        &:last-child { border-bottom: none; }
        .avatar { width: 32px; height: 32px; border-radius: 50%; background: #eff6ff; color: #2563eb; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 600; }
        .content { flex: 1;
          .desc { font-size: 13px; color: #111827; }
          .time { font-size: 12px; color: #94a3b8; margin-top: 2px; }
        }
      }
    }
  }

  .text-green { color: #10b981 !important; }
  .text-orange { color: #f59e0b !important; }
  .text-purple { color: #8b5cf6 !important; }
}
</style>