<template>
  <div class="warning-rules-page">

    <!-- 1. 页面标题与操作按钮 -->
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">预警规则</h2>
        <p class="page-subtitle">共 {{ totalRules }} 条规则 · {{ usedRules }} 条启用中 · 今日触发 {{ touchedRules }} 次</p>
      </div>
      <div class="header-right">
        <el-button class="btn-export" @click="handleBatchOperation">
          <el-icon><i class="ri-checkbox-multiple-line"></i></el-icon>
          <span>批量操作</span>
        </el-button>
        <el-button class="btn-export" @click="handleViewLogs">
          <el-icon><i class="ri-history-line"></i></el-icon>
          <span>变更日志</span>
        </el-button>
        <el-button type="primary" class="btn-add" @click="handleAddRule">
          <el-icon><i class="ri-add-line"></i></el-icon>
          <span>新建规则</span>
        </el-button>
      </div>
    </div>

    <!-- 2. 顶部统计卡片 -->
    <el-row :gutter="16" class="stats-row">
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">
            启用中规则
            <el-icon class="right-icon" color="#10B981"><i class="ri-checkbox-circle-line"></i></el-icon>
          </div>
          <div class="stat-value">{{ usedRules }}</div>
          <div class="stat-desc text-green">占全部规则 {{ totalRules ? ((usedRules / totalRules) * 100).toFixed(1) : 0 }}%</div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">
            已停用规则
            <el-icon class="right-icon" color="#94A3B8"><i class="ri-pause-circle-line"></i></el-icon>
          </div>
          <div class="stat-value">{{ disabledRules }}</div>
          <div class="stat-desc">其中 {{ TempDisabledRules }} 条为临时停用</div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">
            草稿待发布
            <el-icon class="right-icon" color="#F59E0B"><i class="ri-file-edit-line"></i></el-icon>
          </div>
          <div class="stat-value">{{ draftRules }}</div>
          <div class="stat-desc text-orange">草稿仅本人可见</div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">
            今日触发次数
            <el-icon class="right-icon" color="#2563EB"><i class="ri-flashlight-fill"></i></el-icon>
          </div>
          <div class="stat-value">{{ touchedRules }}</div>
          <div class="stat-desc">较昨日 +2 次</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 3. 过滤栏 -->
    <div class="filter-bar">
      <el-tabs v-model="activeTab" class="custom-tabs" @tab-change="handleTabChange">
        <el-tab-pane label="全部规则" name="all" />
        <el-tab-pane label="启用中" name="enabled" />
        <el-tab-pane label="已停用" name="disabled" />
        <el-tab-pane label="草稿" name="draft" />
        <el-tab-pane label="我创建的" name="mine" />
      </el-tabs>

      <div class="filter-selects">
        <el-select v-model="filterCategory" placeholder="全部分类" size="small" style="width: 140px"
          @change="handleCategoryChange">
          <el-option v-for="item in categoryOptions" :key="item.value" :label="`${item.label} (${item.count})`"
            :value="item.value" :disabled="item.count === 0 && item.value !== ''" />
        </el-select>

        <el-select v-model="filterTrigger" placeholder="全部触发源" size="small" style="width: 200px" multiple collapse-tags
          collapse-tags-tooltip>
          <el-option-group v-for="group in triggerGroups" :key="group.label" :label="group.label">
            <el-option v-for="item in group.options" :key="item.value" :label="item.label" :value="item.value"
              :disabled="item.disabled" />
          </el-option-group>
        </el-select>

        <el-select v-model="filterPriority" placeholder="优先级排序" size="small" style="width: 120px" clearable>
          <el-option label="P0 高危" value="P0" />
          <el-option label="P1 高" value="P1" />
          <el-option label="P2 中" value="P2" />
        </el-select>
      </div>
    </div>

    <!-- 4. 规则列表区 -->
    <div class="rules-list">
      <div v-for="rule in ruleList" :key="rule.id" class="rule-card">
        <div class="rule-left">
          <el-tag :type="getPriorityType(rule.priority)" effect="dark" size="small" class="priority-tag">
            {{ rule.priority }}
          </el-tag>
          <span class="rule-id">{{ rule.id }}</span>
        </div>

        <div class="rule-main">
          <div class="rule-title-row">
            <h3 class="rule-title">{{ rule.title }}</h3>
            <el-tag v-if="rule.status === '启用中'" type="success" size="small" effect="plain">启用中</el-tag>
            <el-tag v-else-if="rule.status === '已停用'" type="info" size="small" effect="plain">已停用</el-tag>
            <el-tag v-else-if="rule.status === '草稿'" type="warning" size="small" effect="plain">草稿</el-tag>
            <span class="rule-source">来源: {{ rule.source }}</span>
          </div>

          <ul class="rule-conditions">
            <li v-for="(cond, index) in rule.conditions" :key="index">{{ cond }}</li>
          </ul>

          <div class="rule-footer">
            <span><el-icon><i class="ri-user-line"></i></el-icon> {{ rule.creator }}</span>
            <span>{{ rule.updateTime }} 更新</span>
            <span class="trigger-count"><i class="ri-flashlight-fill"></i> 近 7 天命中 {{ rule.triggerCount }} 次</span>
          </div>
        </div>

        <div class="rule-right">
          <div class="chart-box">
            <div class="chart-label">近 7 天触发</div>
            <div class="mini-chart">
              <svg viewBox="0 0 100 20" class="sparkline">
                <path d="M0,15 L20,18 L40,10 L60,12 L80,5 L100,8" fill="none" :stroke="getPriorityColor(rule.priority)"
                  stroke-width="1.5" />
              </svg>
            </div>
          </div>

          <!-- 💡 按钮事件已绑定 -->
          <div class="rule-actions">
            <el-button link @click="handleEdit(rule)">
              <el-icon><i class="ri-edit-line"></i></el-icon>编辑
            </el-button>
            <el-button link @click="handleViewHits(rule)">
              <el-icon><i class="ri-history-line"></i></el-icon>命中记录
            </el-button>
            <el-switch 
              v-model="rule.isEnabled" 
              size="small" 
              @change="(val) => handleStatusChange(rule, val)" 
            />
          </div>
        </div>
      </div>

      <!-- 空状态 -->
      <el-empty v-if="ruleList.length === 0" description="暂无预警规则，快去新建一条吧">
        <el-button type="primary" class="btn-add" @click="handleAddRule">立即新建</el-button>
      </el-empty>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRouter } from 'vue-router'
// 💡 引入修改状态的接口
import { getWarningRules, updateRuleStatus } from '@/api/admin'

const router = useRouter()

// 基础数据变量
const totalRules = ref(0)
const usedRules = ref(0)
const disabledRules = ref(0)
const TempDisabledRules = ref(0)
const draftRules = ref(0)
const touchedRules = ref(0)
const ruleList = ref([])

const activeTab = ref('all')
const filterCategory = ref('')
const filterTrigger = ref([])
const filterPriority = ref('')

// 分类选项
const categoryOptions = ref([
  { label: '全部分类', value: '', count: 12 },
  { label: '心理情绪', value: 'psychology', count: 5 },
  { label: '体征睡眠', value: 'physical', count: 3 },
  { label: '饮食营养', value: 'diet', count: 2 },
  { label: '运动行为', value: 'sport', count: 1 },
  { label: '依从与随访', value: 'followup', count: 1 }
])

// 触发源选项
const rawTriggerGroups = [
  { label: '量表测评', category: 'psychology', options: [{ label: 'GAD-7 焦虑自评', value: 'gad7' }, { label: 'PHQ-9 抑郁自评', value: 'phq9' }] },
  { label: '体征上报', category: 'physical', options: [{ label: '睡眠时长', value: 'sleep' }, { label: '静息心率', value: 'heart' }] },
  { label: '饮食记录', category: 'diet', options: [{ label: '热量摄入', value: 'calorie' }, { label: '餐次完整性', value: 'meal' }] },
  { label: '对话与 AI', category: 'psychology', options: [{ label: '会话负向情绪识别', value: 'ai_emotion' }, { label: 'AI 对话审计命中', value: 'ai_audit' }] },
  { label: '任务与打卡', category: 'followup', options: [{ label: '计划未完成', value: 'task_miss' }, { label: '连续未打卡', value: 'no_checkin' }] },
  { label: '人工', category: 'all', options: [{ label: '顾问手动创建', value: 'manual' }] }
]

const triggerGroups = computed(() => {
  const currentCat = filterCategory.value
  return rawTriggerGroups.map(group => {
    const isDisabledGroup = currentCat !== '' && group.category !== 'all' && group.category !== currentCat
    return {
      label: group.label,
      options: group.options.map(opt => ({ ...opt, disabled: isDisabledGroup }))
    }
  })
})

// 辅助方法
const getPriorityType = (priority) => {
  if (priority.includes('P0')) return 'danger'
  if (priority.includes('P1')) return 'warning'
  return 'info'
}
const getPriorityColor = (priority) => {
  if (priority.includes('P0')) return '#EF4444'
  if (priority.includes('P1')) return '#F59E0B'
  return '#2563EB'
}

// ==========================================
// 💡 核心：获取列表数据
// ==========================================
const fetchRuleList = async () => {
  try {
    const res = await getWarningRules()
    const dataList = res.data || res || []
    
    ruleList.value = dataList.map(item => {
      let parsedConditions = []
      try {
        if (item.conditionsJson) parsedConditions = JSON.parse(item.conditionsJson)
      } catch (e) { console.error(e) }

      return {
        id: 'R-' + item.id,
        title: item.name,
        priority: item.priority,
        status: item.status === 1 ? '启用中' : '已停用',
        source: '量表: GAD-7',
        conditions: parsedConditions.map(c => `当 ${c.field} ${c.operator === 'gte' ? '≥' : '≤'} ${c.value}`),
        creator: '林小雨',
        updateTime: item.createdAt ? item.createdAt.replace('T', ' ').substring(0, 16) : '',
        triggerCount: 0,
        isEnabled: item.status === 1
      }
    })

    // 更新统计卡片
    totalRules.value = ruleList.value.length
    usedRules.value = ruleList.value.filter(r => r.isEnabled).length
    disabledRules.value = totalRules.value - usedRules.value
  } catch (error) {
    console.error('获取列表失败', error)
    ruleList.value = []
  }
}

// ==========================================
// 💡 核心：按钮事件处理
// ==========================================

// 1. 编辑
const handleEdit = (rule) => {
  ElMessage.info(`正在编辑：${rule.title}（后续跳转编辑页）`)
}

// 2. 命中记录
const handleViewHits = (rule) => {
  ElMessage.success(`正在调取【${rule.title}】的命中记录...`)
}

// 3. 状态切换 (真实调用后端接口)
const handleStatusChange = async (rule, newValue) => {
  const targetStatus = newValue ? 1 : 0
  const realId = rule.id.replace('R-', '')
  
  try {
    await updateRuleStatus(realId, targetStatus)
    ElMessage.success(`已${newValue ? '启用' : '停用'}规则：${rule.title}`)
    rule.status = newValue ? '启用中' : '已停用'
    
    // 刷新统计数据
    usedRules.value = ruleList.value.filter(r => r.isEnabled).length
    disabledRules.value = totalRules.value - usedRules.value
  } catch (error) {
    console.error('修改状态失败', error)
    ElMessage.error('修改失败，请检查网络')
    rule.isEnabled = !newValue // 失败回滚
  }
}

// 其他操作
const handleBatchOperation = () => {
  ElMessageBox.confirm('确认要对选中的规则进行批量操作吗？', '提示', {
    confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning',
  }).then(() => ElMessage.success('批量操作执行成功（模拟）'))
    .catch(() => ElMessage.info('已取消操作'))
}
const handleViewLogs = () => ElMessage.success('正在调取变更日志...')
const handleAddRule = () => router.push('/back/created-new-rules')

const handleCategoryChange = () => {
  const currentCat = filterCategory.value
  if (currentCat === '') return
  const validValues = []
  rawTriggerGroups.forEach(group => {
    if (group.category === 'all' || group.category === currentCat) {
      group.options.forEach(opt => validValues.push(opt.value))
    }
  })
  filterTrigger.value = filterTrigger.value.filter(val => validValues.includes(val))
}

const handleTabChange = (tabName) => {
  activeTab.value = tabName
  fetchRuleList()
}

// 页面加载时请求数据
onMounted(() => {
  fetchRuleList()
})
</script>

<style scoped lang="scss">
/* 这里保留你刚刚写的所有样式（完全没有问题） */
.warning-rules-page {
  padding-bottom: 20px;
}

/* 1. 页面标题 */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;

  .header-left {
    .page-title {
      font-size: 22px;
      font-weight: 600;
      color: #111827;
      margin: 0 0 8px 0;
    }

    .page-subtitle {
      font-size: 13px;
      color: #94A3B8;
      margin: 0;
    }
  }

  .header-right {
    display: flex;
    gap: 12px;

    .el-button {
      height: 36px;
      border-radius: 6px;
      margin: 0;
    }

    .btn-export {
      background: #FFF;
      border: 1px solid #E2E8F0;
      color: #475569;

      &:hover {
        color: #2563EB;
        border-color: #2563EB;
      }
    }

    .btn-add {
      background: #2563EB;
      border: none;

      &:hover {
        background: #1D4ED8;
      }
    }
  }
}

/* 2. 统计卡片 */
.stats-row {
  margin-bottom: 24px;

  .stat-card {
    border-radius: 8px;
    border: none;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    padding: 4px;

    .stat-title {
      font-size: 13px;
      color: #64748B;
      display: flex;
      justify-content: space-between;
      align-items: center;

      .right-icon {
        font-size: 18px;
      }
    }

    .stat-value {
      font-size: 28px;
      font-weight: 700;
      color: #111827;
      margin: 10px 0 6px;
    }

    .stat-desc {
      font-size: 12px;
      color: #94A3B8;

      &.text-green {
        color: #10B981;
      }

      &.text-orange {
        color: #F59E0B;
      }
    }
  }
}

/* 3. 过滤栏 */
.filter-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #FFF;
  padding: 0 20px;
  border-radius: 8px;
  margin-bottom: 20px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);

  .custom-tabs {
    :deep(.el-tabs__header) {
      margin: 0;
      border-bottom: none !important;
    }

    :deep(.el-tabs__nav-wrap::after) {
      display: none !important;
      height: 0 !important;
    }

    :deep(.el-tabs__item) {
      height: 56px;
      line-height: 56px;
      padding: 0 20px;
      font-size: 14px;
      color: #64748B;
      font-weight: 500;

      &:hover {
        color: #111827;
      }

      &.is-active {
        color: #2563EB;
        font-weight: 600;
      }
    }

    :deep(.el-tabs__active-bar) {
      background-color: #2563EB;
      height: 2px;
    }
  }

  .filter-selects {
    display: flex;
    gap: 12px;
  }
}

/* 4. 规则列表卡片 */
.rules-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-height: 400px;

  .rule-card {
    display: flex;
    background: #FFF;
    border-radius: 8px;
    padding: 20px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    transition: all 0.2s;

    &:hover {
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    }

    .rule-left {
      width: 80px;
      display: flex;
      flex-direction: column;
      align-items: flex-start;
      gap: 8px;

      .priority-tag {
        border-radius: 4px;
        font-weight: 600;
        padding: 0 6px;
      }

      .rule-id {
        font-size: 12px;
        color: #94A3B8;
      }
    }

    .rule-main {
      flex: 1;
      padding: 0 20px;

      .rule-title-row {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 12px;

        .rule-title {
          font-size: 16px;
          font-weight: 600;
          color: #111827;
          margin: 0;
        }

        .rule-source {
          font-size: 12px;
          color: #94A3B8;
          margin-left: 10px;
        }
      }

      .rule-conditions {
        margin: 0 0 16px 0;
        padding-left: 16px;
        color: #475569;
        font-size: 13px;
        line-height: 1.6;

        li {
          margin-bottom: 4px;
        }
      }

      .rule-footer {
        display: flex;
        gap: 20px;
        font-size: 12px;
        color: #94A3B8;
        align-items: center;

        span {
          display: flex;
          align-items: center;
          gap: 4px;
        }

        .trigger-count {
          color: #2563EB;
          margin-left: auto;
        }
      }
    }

    .rule-right {
      width: 180px;
      display: flex;
      flex-direction: column;
      align-items: flex-end;
      justify-content: space-between;

      .chart-box {
        text-align: right;

        .chart-label {
          font-size: 12px;
          color: #94A3B8;
        }

        .mini-chart {
          width: 100px;
          height: 24px;
          margin-top: 4px;

          .sparkline {
            width: 100%;
            height: 100%;
            overflow: visible;
          }
        }
      }

      .rule-actions {
        display: flex;
        align-items: center;
        gap: 12px;

        .el-button {
          padding: 0;
          font-size: 13px;
          color: #64748B;
        }

        :deep(.el-switch) {
          --el-switch-on-color: #2563EB;
        }
      }
    }
  }

  :deep(.el-empty) {
    background: #FFF;
    border-radius: 8px;
    padding: 60px 0;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  }
}
</style>