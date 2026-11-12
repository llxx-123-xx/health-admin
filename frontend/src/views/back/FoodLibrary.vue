<template>
  <div class="food-library-page">
    <!-- 1. 头部 -->
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">食物库管理</h2>
        <p class="page-subtitle">维护食物营养数据库、份量换算与检索标签，保存并上架后 C 端即时生效</p>
      </div>
      <div class="header-right">
        <el-button class="btn-export"><el-icon><i class="ri-upload-2-line"></i></el-icon> 批量导入</el-button>
        <el-button class="btn-export"><el-icon><i class="ri-refresh-line"></i></el-icon> 同步官方库</el-button>
        <el-button type="primary" class="btn-add" @click="handleAdd">
          <el-icon><i class="ri-add-line"></i></el-icon> 新增食物
        </el-button>
      </div>
    </div>

    <!-- 2. 统计卡片 -->
    <el-row :gutter="16" class="stats-row">
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">食物总数 <el-icon class="right-icon" color="#2563EB"><i class="ri-restaurant-2-line"></i></el-icon></div>
          <div class="stat-value">{{ total }}</div>
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
          <div class="stat-title">待审核 <el-icon class="right-icon" color="#F59E0B"><i class="ri-time-line"></i></el-icon></div>
          <div class="stat-value text-orange">{{ pendingCount }}</div>
          <div class="stat-desc">用户贡献 6 条</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">本月查询次数 <el-icon class="right-icon" color="#8B5CF6"><i class="ri-bar-chart-fill"></i></el-icon></div>
          <div class="stat-value text-purple">86,420</div>
          <div class="stat-desc text-purple">较上月 +21.3%</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 3. 过滤栏 -->
    <div class="filter-bar">
      <el-tabs v-model="activeTab" class="custom-tabs">
        <el-tab-pane label="全部" name="all" />
        <el-tab-pane :label="`已上架 ${publishedCount}`" name="published" />
        <el-tab-pane :label="`待审核 ${pendingCount}`" name="pending" />
        <el-tab-pane label="已下架" name="offline" />
      </el-tabs>

      <div class="filter-selects">
        <el-select v-model="filterCategory" placeholder="全部分类" size="small" style="width: 120px">
          <el-option label="全部分类" value="" />
          <el-option label="谷薯类" value="谷薯类" />
          <el-option label="肉类" value="肉类" />
          <el-option label="水果类" value="水果类" />
          <el-option label="水产类" value="水产类" />
        </el-select>
        <el-select v-model="filterSource" placeholder="全部来源" size="small" style="width: 120px">
          <el-option label="全部来源" value="" />
          <el-option label="官方库" value="官方库" />
          <el-option label="AI 识别" value="AI 识别" />
          <el-option label="用户贡献" value="用户贡献" />
        </el-select>
        <el-input v-model="searchKeyword" placeholder="搜索食物名称 / 编码" size="small" style="width: 200px" clearable>
          <template #prefix><el-icon><i class="ri-search-line"></i></el-icon></template>
        </el-input>
      </div>
    </div>

    <!-- 4. 数据表格 -->
    <div class="table-container">
      <!-- 批量操作 -->
      <div class="batch-bar" style="margin-bottom: 16px;">
        <el-checkbox v-model="isAllSelected" @change="handleSelectAll">已选 {{ selectedRows.length }} 项</el-checkbox>
        <el-button size="small" plain @click="handleBatch('上架')">批量上架</el-button>
        <el-button size="small" plain @click="handleBatch('下架')">批量下架</el-button>
        <el-button size="small" plain type="danger" @click="handleBatch('删除')">批量删除</el-button>
        <div class="right-tip">
          <el-icon><i class="ri-information-line"></i></el-icon> 按更新时间倒序
        </div>
      </div>

      <el-table :data="filteredData" style="width: 100%" row-key="id" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="55" />
        <el-table-column label="食物名称/编码" min-width="200">
          <template #default="{ row }">
            <div class="name-cell">
              <span class="name">{{ row.name }}</span>
              <span class="code">{{ row.code }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="category" label="分类" width="100" />
        <el-table-column label="热量" width="100">
          <template #default="{ row }">
            <span class="heat">{{ row.calories }} kcal</span>
          </template>
        </el-table-column>
        <el-table-column label="营养素 / 每100g" width="180">
          <template #default="{ row }">
            <div class="nutrients">
              <span>碳 {{ row.carbs }}</span>
              <span>蛋 {{ row.protein }}</span>
              <span>脂 {{ row.fat }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="portion" label="份量单位" width="120" />
        <el-table-column label="来源" width="120">
          <template #default="{ row }">
            <el-tag :type="getSourceTagType(row.source)" effect="light" size="small">{{ row.source }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.status === '已上架'" type="success" effect="light" size="small">已上架</el-tag>
            <el-tag v-else-if="row.status === '待审核'" type="warning" effect="light" size="small">待审核</el-tag>
            <el-tag v-else type="info" effect="light" size="small">已下架</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="updateTime" label="更新时间" width="120" />
        
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleDetail(row)">详情</el-button>
            
            <el-button v-if="row.status === '已上架'" link type="danger" size="small" @click="toggleStatus(row)">
              下架
            </el-button>
            
            <template v-else-if="row.status === '待审核'">
              <el-button link type="success" size="small" @click="handleAudit(row, 1)">审核通过</el-button>
              <el-button link type="info" size="small" @click="handleAudit(row, 0)">驳回</el-button>
            </template>
            
            <el-button v-else-if="row.status === '已下架'" link type="success" size="small" @click="toggleStatus(row)">
              上架
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 💡 核心新增：分页组件 -->
      <div class="pagination-wrapper">
        <span class="page-info">共 {{ total }} 条记录</span>
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
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getFoods, updateFoodStatus, batchUpdateFoodStatus } from '@/api/admin'

const activeTab = ref('all')
const filterCategory = ref('')
const filterSource = ref('')
const searchKeyword = ref('')
const isAllSelected = ref(false)
const selectedRows = ref([])
const tableData = ref([])

// 💡 新增分页变量
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 💡 修改：从后端加载数据（带分页）
const fetchFoods = async () => {
  try {
    const res = await getFoods({
      page: currentPage.value,
      size: pageSize.value
    })
    
    // 后端返回的是 Page 对象，数据在 records 里
    const pageData = res.data || res
    const data = pageData.records || []
    total.value = pageData.total || 0

    tableData.value = data.map(item => ({
      id: item.id,
      name: item.name,
      code: item.code,
      category: item.category,
      calories: item.calories,
      carbs: item.carbs,
      protein: item.protein,
      fat: item.fat,
      portion: item.portion,
      source: item.source,
      status: item.status === 1 ? '已上架' : (item.status === 2 ? '待审核' : '已下架'),
      updateTime: item.updatedAt ? item.updatedAt.replace('T', ' ').substring(5, 16) : ''
    }))
  } catch (error) {
    console.error('获取食物列表失败', error)
    ElMessage.error('后端未连接')
  }
}

// 💡 新增：翻页事件
const handlePageChange = (val) => {
  currentPage.value = val
  fetchFoods()
}

// 统计数据
const publishedCount = computed(() => tableData.value.filter(r => r.status === '已上架').length)
const pendingCount = computed(() => tableData.value.filter(r => r.status === '待审核').length)

// 过滤
const filteredData = computed(() => {
  let list = tableData.value
  if (activeTab.value === 'published') list = list.filter(r => r.status === '已上架')
  else if (activeTab.value === 'pending') list = list.filter(r => r.status === '待审核')
  else if (activeTab.value === 'offline') list = list.filter(r => r.status === '已下架')

  if (filterCategory.value) list = list.filter(r => r.category === filterCategory.value)
  if (filterSource.value) list = list.filter(r => r.source === filterSource.value)
  if (searchKeyword.value) {
    const kw = searchKeyword.value.toLowerCase()
    list = list.filter(r => r.name.toLowerCase().includes(kw) || r.code.toLowerCase().includes(kw))
  }
  return list
})

const getSourceTagType = (source) => {
  if (source === '官方库') return ''
  if (source === 'AI 识别') return 'warning'
  if (source === '用户贡献') return 'success'
  return 'info'
}

const handleSelectionChange = (val) => {
  selectedRows.value = val
  isAllSelected.value = val.length === filteredData.value.length
}
const handleSelectAll = (val) => {
  selectedRows.value = val ? filteredData.value : []
}

const toggleStatus = (row) => {
  const isOnline = row.status === '已上架'
  const targetStatus = isOnline ? 0 : 1
  const actionText = isOnline ? '下架' : '上架'
  
  ElMessageBox.confirm(`确认要${actionText}【${row.name}】吗？`, '提示', { type: 'warning' }).then(async () => {
    try {
      await updateFoodStatus(row.id, targetStatus)
      row.status = isOnline ? '已下架' : '已上架'
      ElMessage.success(`已${actionText}`)
      fetchFoods() // 💡 操作完刷新列表
    } catch (e) {
      ElMessage.error('操作失败，请检查后端接口')
    }
  }).catch(() => {})
}

const handleAudit = (row, targetStatus) => {
  const actionText = targetStatus === 1 ? '审核通过并上架' : '驳回下架'
  ElMessageBox.confirm(`确认要${actionText}【${row.name}】吗？`, '提示', { type: 'warning' }).then(async () => {
    try {
      await updateFoodStatus(row.id, targetStatus)
      row.status = targetStatus === 1 ? '已上架' : '已下架'
      ElMessage.success(`已${actionText}`)
      fetchFoods() // 💡 操作完刷新列表
    } catch (e) {
      ElMessage.error('操作失败')
    }
  }).catch(() => {})
}

const handleDetail = (row) => {
  ElMessage.info(`查看详情：${row.name}`)
}

const handleAdd = () => ElMessage.info('后续接新建弹窗')

// 💡 核心修改：真实的批量操作
const handleBatch = async (action) => {
  if (selectedRows.value.length === 0) return ElMessage.warning('请先选择要操作的数据')
  
  // 把选中的行 ID 提取出来
  const ids = selectedRows.value.map(r => r.id)
  
  // 确定目标状态
  let targetStatus = 1
  if (action === '下架') targetStatus = 0
  if (action === '审核') targetStatus = 1
  if (action === '删除') {
    // 批量删除逻辑（如果你后端写了批量删除接口）
    ElMessage.success(`已批量删除 ${ids.length} 项（模拟）`)
    return
  }

  try {
    // 调用后端接口
    await batchUpdateFoodStatus(ids, targetStatus)
    ElMessage.success(`已批量${action} ${ids.length} 项`)
    
    // 刷新列表（很重要，不然页面上的状态没变）
    fetchFoods() 
  } catch (error) {
    console.error('批量操作失败', error)
    ElMessage.error('批量操作失败，请检查后端')
  }
}

onMounted(() => {
  fetchFoods()
})
</script>

<style scoped lang="scss">
.food-library-page {
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
    .batch-bar {
      display: flex; align-items: center; gap: 12px;
      .right-tip { margin-left: auto; font-size: 12px; color: #94A3B8; display: flex; align-items: center; gap: 4px; }
    }
    .name-cell {
      display: flex; flex-direction: column;
      .name { font-size: 14px; color: #111827; font-weight: 500; }
      .code { font-size: 12px; color: #94A3B8; margin-top: 4px; }
    }
    .heat { color: #EF4444; font-weight: 600; font-size: 14px; }
    .nutrients {
      display: flex; gap: 10px; font-size: 12px; color: #64748B;
    }

    /* 💡 新增：分页器样式 */
    .pagination-wrapper {
      margin-top: 20px; 
      display: flex; 
      justify-content: space-between; 
      align-items: center;
      .page-info { font-size: 13px; color: #64748B; }
    }
  }
}
</style>