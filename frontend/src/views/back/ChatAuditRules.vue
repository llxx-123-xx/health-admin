<template>
  <div class="chat-audit-rules-page">
    <!-- 1. 页面头部 -->
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">
          审计规则
          <el-tag size="small" type="info" effect="plain">规则库 v4.2</el-tag>
        </h2>
        <p class="page-subtitle">
          配置风险识别条件、适用场景与处置动作，规则启用前可先用样例文本测试验证。
        </p>
      </div>
      <div class="header-right">
        <el-button class="btn-export">
          <el-icon><i class="ri-play-circle-line"></i></el-icon> 规则测试台
        </el-button>
        <el-button class="btn-export">
          <el-icon><i class="ri-upload-2-line"></i></el-icon> 导入规则包
        </el-button>
        <el-button type="primary" class="btn-add" @click="goCreateRule">
          <el-icon><i class="ri-add-line"></i></el-icon> 新建规则
        </el-button>
      </div>
    </div>

    <!-- 2. 顶部 Tab 切换 -->
    <div class="filter-bar">
      <el-tabs v-model="activeTab" class="custom-tabs">
        <el-tab-pane label="会话审计" name="chat" />
        <el-tab-pane label="审计规则" name="rules" />
        <el-tab-pane label="抽检任务" name="tasks" />
        <el-tab-pane label="审计日志" name="logs" />
      </el-tabs>
    </div>

    <!-- 3. 顶部统计卡片 -->
    <el-row :gutter="16" class="stats-row">
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">
            规则总数
            <el-icon class="right-icon" color="#2563EB"><i class="ri-file-list-3-line"></i></el-icon>
          </div>
          <div class="stat-value">{{ tableData.length }}</div>
          <div class="stat-desc">
            系统内置 {{ systemCount }} · 自定义 {{ customCount }}
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">
            启用中规则
            <el-icon class="right-icon" color="#10B981"><i class="ri-checkbox-circle-line"></i></el-icon>
          </div>
          <div class="stat-value text-green">{{ enabledCount }}</div>
          <div class="stat-desc">已开启自动拦截</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">
            近 7 日命中
            <el-icon class="right-icon" color="#F59E0B"><i class="ri-alert-line"></i></el-icon>
          </div>
          <div class="stat-value text-orange">{{ totalHitCount }}</div>
          <div class="stat-desc">高危 12 · 中危 68 · 低危 86</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">
            平均误报率
            <el-icon class="right-icon" color="#8B5CF6"><i class="ri-bar-chart-fill"></i></el-icon>
          </div>
          <div class="stat-value text-purple">{{ avgFalseRate }}%</div>
          <div class="stat-desc">较上周 -1.8% 识别准确率优化</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 4. 主体内容区 -->
    <div class="main-content">
      <!-- 左侧分类菜单 -->
      <div class="left-menu">
        <div class="menu-header">
          <span>规则分组</span>
        </div>
        <ul class="menu-list">
          <li
            v-for="cat in categoryList"
            :key="cat.value"
            :class="{ active: activeCategory === cat.value }"
            @click="handleCategoryChange(cat.value)"
          >
            <span class="label"><i :class="cat.icon"></i> {{ cat.label }}</span>
            <span class="count">{{ getCategoryCount(cat.value) }}</span>
          </li>
        </ul>
      </div>

      <!-- 右侧规则列表 -->
      <div class="right-content">
        <div class="filter-bar-inner">
          <el-input
            v-model="searchKeyword"
            placeholder="搜索规则名称/关键词"
            size="small"
            style="width: 240px"
            clearable
            @keyup.enter="handleSearch"
            @clear="handleSearch"
          >
            <template #prefix><el-icon><i class="ri-search-line"></i></el-icon></template>
          </el-input>
          <el-button type="primary" size="small" @click="handleSearch">查询</el-button>
          <el-button size="small" @click="handleReset">重置</el-button>
        </div>

        <el-table :data="pagedData" style="width: 100%" row-key="id">
          <el-table-column label="规则名称" min-width="200">
            <template #default="{ row }">
              <div class="name-cell">
                <span class="name">{{ row.title }}</span>
                <span class="code">{{ row.code }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="等级" width="100">
            <template #default="{ row }">
              <el-tag v-if="row.level === 'high'" type="danger" size="small" effect="dark">高危</el-tag>
              <el-tag v-else-if="row.level === 'medium'" type="warning" size="small" effect="dark">中危</el-tag>
              <el-tag v-else type="info" size="small" effect="dark">低危</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="作用场景" width="120">
            <template #default="{ row }">
              {{ row.scene || '全场景' }}
            </template>
          </el-table-column>
          <el-table-column label="7 日内命中" width="120">
            <template #default="{ row }">
              <span class="hit-count">{{ row.hitCount }}</span>
            </template>
          </el-table-column>
          <el-table-column label="误报率" width="100">
            <template #default="{ row }">
              <span class="false-rate">{{ row.falseRate }}%</span>
            </template>
          </el-table-column>
          <el-table-column label="状态" width="100">
            <template #default="{ row }">
              <el-switch v-model="row.isEnabled" @change="(val) => handleSwitchChange(row, val)" />
            </template>
          </el-table-column>
          <el-table-column prop="updateTime" label="更新时间" width="140" />
          <el-table-column label="操作" width="100" fixed="right">
            <template #default="{ row }">
              <el-button link type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            </template>
          </el-table-column>
        </el-table>

        <div class="pagination-wrapper">
          <span class="page-info">共 {{ filteredData.length }} 条规则</span>
          <el-pagination
            background
            layout="prev, pager, next"
            :total="filteredData.length"
            :page-size="pageSize"
            v-model:current-page="currentPage"
            @current-change="handlePageChange"
          />
        </div>
      </div>
    </div>

    <el-dialog
      v-model="dialogVisible"
      title="编辑审计规则"
      width="500px"
      @closed="handleDialogClosed"
    >
      <el-form ref="formRef" :model="formData" :rules="formRules" label-width="100px">
        <el-form-item label="规则名称" prop="title">
          <el-input v-model="formData.title" placeholder="请输入规则名称" maxlength="50" show-word-limit />
        </el-form-item>
        <el-form-item label="规则编码" prop="code">
          <el-input v-model="formData.code" placeholder="例如：R-1009" disabled maxlength="30" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="submitEdit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  getAuditRules,
  updateAuditRuleStatus,
  updatePromptTemplate
} from '@/api/admin'

const router = useRouter()

const activeTab = ref('rules')
const searchKeyword = ref('')
const activeCategory = ref('all')

const tableData = ref([])
const currentPage = ref(1)
const pageSize = ref(8)
const enabledCount = ref(0)

const dialogVisible = ref(false)
const submitting = ref(false)
const formRef = ref(null)
const formData = ref({})

const formRules = {
  title: [{ required: true, message: '请输入规则名称', trigger: 'blur' }]
}

const categoryList = ref([
  { label: '全部规则', value: 'all', icon: 'ri-folder-line' },
  { label: '敏感承诺', value: 'sensitive', icon: 'ri-alert-line' },
  { label: '用药安全', value: 'medicine', icon: 'ri-medicine-bottle-line' },
  { label: '疾病诊断', value: 'diagnosis', icon: 'ri-stethoscope-line' },
  { label: '情绪危机', value: 'emotion', icon: 'ri-heart-pulse-line' },
  { label: '夸大功效', value: 'exaggerate', icon: 'ri-megaphone-line' },
  { label: '隐私与合规', value: 'privacy', icon: 'ri-shield-line' },
  { label: '自定义规则', value: 'custom', icon: 'ri-settings-4-line' }
])

const matchCategory = (row, category) => {
  if (category === 'all') return true
  return row.ruleCategory === category
}

// 💡 核心修复：补上之前缺失的 fetchRules 函数
const fetchRules = async () => {
  try {
    const res = await getAuditRules({ page: 1, size: 100, keyword: searchKeyword.value })
    const pageData = res.data || res
    const data = pageData.records || []

    tableData.value = data.map(item => ({
      id: item.id,
      title: item.title,
      code: item.code,
      isEnabled: item.status === 1,
      updateTime: item.updatedAt ? item.updatedAt.replace('T', ' ').substring(5, 16) : '',
      hitCount: Math.floor(Math.random() * 50),
      falseRate: (Math.random() * 10).toFixed(1),
      ruleCategory: item.ruleCategory || item.rule_category || '', 
      level: item.level || 'high',
      scene: item.scene || ''
    }))

    enabledCount.value = tableData.value.filter(r => r.isEnabled).length
  } catch (error) {
    console.error('获取审计规则失败', error)
    ElMessage.error('后端未连接')
  }
}

// 统计卡片逻辑
const customCount = computed(
  () => tableData.value.filter(r => r.ruleCategory === 'custom').length
)
const systemCount = computed(() => tableData.value.length - customCount.value)
const totalHitCount = computed(() =>
  tableData.value.reduce((sum, r) => sum + (r.hitCount || 0), 0)
)
const avgFalseRate = computed(() => {
  if (!tableData.value.length) return '0.0'
  const total = tableData.value.reduce((sum, r) => sum + parseFloat(r.falseRate || 0), 0)
  return (total / tableData.value.length).toFixed(1)
})

const handleCategoryChange = (value) => {
  activeCategory.value = value
  currentPage.value = 1
}

const filteredData = computed(() => {
  let list = tableData.value
  if (activeCategory.value !== 'all') {
    list = list.filter(r => matchCategory(r, activeCategory.value))
  }
  if (searchKeyword.value) {
    const kw = searchKeyword.value.toLowerCase()
    list = list.filter(
      r =>
        r.title.toLowerCase().includes(kw) ||
        (r.code && r.code.toLowerCase().includes(kw))
    )
  }
  return list
})

const pagedData = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  return filteredData.value.slice(start, start + pageSize.value)
})

watch(filteredData, (list) => {
  const maxPage = Math.max(1, Math.ceil(list.length / pageSize.value))
  if (currentPage.value > maxPage) {
    currentPage.value = maxPage
  }
})

const getCategoryCount = (val) => {
  if (val === 'all') return tableData.value.length
  return tableData.value.filter(r => matchCategory(r, val)).length
}

const handleSearch = () => {
  currentPage.value = 1
}

const handleReset = () => {
  searchKeyword.value = ''
  activeCategory.value = 'all'
  currentPage.value = 1
}

const handlePageChange = (val) => {
  currentPage.value = val
}

const handleSwitchChange = async (row, newVal) => {
  try {
    await updateAuditRuleStatus(row.id, newVal ? 1 : 0)
    ElMessage.success(`规则已${newVal ? '启用' : '停用'}`)
    enabledCount.value = tableData.value.filter(r => r.isEnabled).length
  } catch (e) {
    ElMessage.error('状态修改失败')
    row.isEnabled = !newVal
  }
}

const goCreateRule = () => {
  router.push('/back/conversation-audit/rules/create')
}

const handleEdit = (row) => {
  formData.value = { ...row }
  dialogVisible.value = true
}

const handleDialogClosed = () => {
  formRef.value?.clearValidate()
}

const submitEdit = async () => {
  if (!formRef.value) return
  try {
    await formRef.value.validate()
  } catch {
    return
  }

  submitting.value = true
  try {
    await updatePromptTemplate({
      id: formData.value.id,
      title: formData.value.title
    })
    ElMessage.success('修改成功！')
    dialogVisible.value = false
    fetchRules()
  } catch (e) {
    console.error(e)
    ElMessage.error('操作失败，请检查后端')
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  fetchRules()
})
</script>

<style scoped lang="scss">
.chat-audit-rules-page {
  padding-bottom: 20px;
  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 20px;
    .header-left {
      .page-title {
        font-size: 22px;
        font-weight: 600;
        color: #111827;
        margin: 0 0 8px 0;
        display: flex;
        align-items: center;
        gap: 8px;
      }
      .page-subtitle {
        font-size: 13px;
        color: #94a3b8;
        margin: 0;
      }
    }
    .header-right {
      display: flex;
      gap: 12px;
      .el-button {
        height: 36px;
        border-radius: 6px;
      }
      .btn-export {
        background: #fff;
        border: 1px solid #e2e8f0;
        color: #475569;
        &:hover {
          color: #2563eb;
          border-color: #2563eb;
        }
      }
      .btn-add {
        background: #2563eb;
        border: none;
        &:hover {
          background: #1d4ed8;
        }
      }
    }
  }
  .filter-bar {
    background: #fff;
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
        color: #64748b;
        font-weight: 500;
        &:hover {
          color: #111827;
        }
        &.is-active {
          color: #2563eb;
          font-weight: 600;
        }
      }
      :deep(.el-tabs__active-bar) {
        background-color: #2563eb;
        height: 2px;
      }
    }
  }
  .stats-row {
    margin-bottom: 20px;
    .stat-card {
      border-radius: 8px;
      border: none;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
      padding: 4px;
      .stat-title {
        font-size: 13px;
        color: #64748b;
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
        color: #94a3b8;
      }
    }
  }
  .text-green {
    color: #10b981 !important;
  }
  .text-orange {
    color: #f59e0b !important;
  }
  .text-purple {
    color: #8b5cf6 !important;
  }
  .main-content {
    display: flex;
    gap: 20px;
    .left-menu {
      width: 220px;
      background: #fff;
      border-radius: 8px;
      padding: 16px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
      height: fit-content;
      .menu-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 14px;
        font-weight: 600;
        color: #111827;
        margin-bottom: 12px;
      }
      .menu-list {
        list-style: none;
        padding: 0;
        margin: 0;
        li {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 10px;
          border-radius: 6px;
          cursor: pointer;
          font-size: 13px;
          color: #475569;
          margin-bottom: 4px;
          .label {
            display: flex;
            align-items: center;
            gap: 8px;
          }
          &:hover {
            background: #f8fafc;
          }
          &.active {
            background: #eff6ff;
            color: #2563eb;
            font-weight: 500;
          }
          .count {
            font-size: 12px;
            color: #94a3b8;
          }
        }
      }
    }
    .right-content {
      flex: 1;
      background: #fff;
      border-radius: 8px;
      padding: 20px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
      .filter-bar-inner {
        display: flex;
        gap: 12px;
        align-items: center;
        margin-bottom: 20px;
        .right-actions {
          margin-left: auto;
          display: flex;
          gap: 12px;
        }
      }
      .name-cell {
        display: flex;
        flex-direction: column;
        .name {
          font-size: 14px;
          color: #111827;
          font-weight: 500;
        }
        .code {
          font-size: 12px;
          color: #94a3b8;
          margin-top: 4px;
        }
      }
      .hit-count {
        font-weight: 600;
        color: #475569;
      }
      .false-rate {
        font-weight: 600;
        color: #10b981;
      }
      .pagination-wrapper {
        margin-top: 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        .page-info {
          font-size: 13px;
          color: #64748b;
        }
      }
    }
  }
}
</style>