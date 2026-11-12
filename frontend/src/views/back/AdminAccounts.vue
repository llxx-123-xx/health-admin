<template>
  <div class="admin-accounts-page">
    <!-- 1. 页面头部 -->
    <div class="page-header">
      <div>
        <h2>管理员账号 <el-tag size="small" effect="plain" class="count-tag">共 {{ total }} 个账号</el-tag></h2>
        <p class="subtitle">统一管理后台登录账号、角色分配与安全状态，支持停用与权限变更操作。</p>
      </div>
      <div class="actions">
        <el-button class="btn-export" @click="handleExport"><el-icon><Download /></el-icon> 导出清单</el-button>
        <el-button class="btn-export" @click="goToRoles"><el-icon><User /></el-icon> 角色权限</el-button>
        <el-button type="primary" class="btn-add" @click="openDrawer('create')"><el-icon><Plus /></el-icon> 新增管理员</el-button>
      </div>
    </div>

    <!-- 2. 顶部统计卡片 -->
    <el-row :gutter="16" class="stats-row">
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">账号总数 <el-icon color="#3b82f6"><User /></el-icon></div>
          <div class="stat-value">{{ total }}</div>
          <div class="stat-desc">本月 <span class="text-green">+2</span> · 覆盖 6 个部门 / 7 种角色</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">启用中 <el-icon color="#10b981"><CircleCheck /></el-icon></div>
          <div class="stat-value text-green">{{ activeCount }} <span class="percent">占比 {{ activePercent }}%</span></div>
          <div class="stat-desc">当前处于正常启用状态的账号</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">已停用 / 待激活 <el-icon color="#f59e0b"><Warning /></el-icon></div>
          <div class="stat-value"><span class="text-orange">{{ stoppedCount }}</span> / {{ pendingCount }} <span class="percent">近 30 天</span></div>
          <div class="stat-desc">高风险账号需在 24 小时内停用</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">安全风险账号 <el-icon color="#ef4444"><WarningFilled /></el-icon></div>
          <div class="stat-value text-red">{{ riskCount }} <span class="danger-tag">需处理</span></div>
          <div class="stat-desc">1 个异地登录 · 1 个未开启两步验证</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 3. 筛选栏 -->
    <div class="filter-bar">
      <el-input v-model="queryParams.keyword" placeholder="姓名/登录账号/手机号" class="search-input" clearable @keyup.enter="handleSearch">
        <template #prefix><el-icon><Search /></el-icon></template>
      </el-input>
      <el-select v-model="queryParams.role" placeholder="全部角色" clearable class="filter-select">
        <el-option label="超级管理员" value="super_admin" />
        <el-option label="内容运营" value="content_ops" />
        <el-option label="风控管理" value="risk_mgr" />
      </el-select>
      <el-select v-model="queryParams.status" placeholder="全部状态" clearable class="filter-select">
        <el-option label="启用" :value="1" />
        <el-option label="停用" :value="0" />
        <el-option label="待激活" :value="2" />
      </el-select>
      <el-select v-model="queryParams.department" placeholder="全部部门" clearable class="filter-select">
        <el-option label="运营中心" value="运营中心" />
        <el-option label="技术部" value="技术部" />
        <el-option label="风控合规组" value="风控合规组" />
      </el-select>
      <el-button type="primary" @click="handleSearch">查询</el-button>
      <el-button @click="resetQuery">重置</el-button>
    </div>

    <!-- 4. 状态 Tab 切换 -->
    <div class="status-tabs">
      <div class="tab" :class="{ active: activeTab === 'all' }" @click="switchTab('all')">全部 <span class="badge">{{ total }}</span></div>
      <div class="tab" :class="{ active: activeTab === 'active' }" @click="switchTab('active')">启用中 <span class="badge">{{ activeCount }}</span></div>
      <div class="tab" :class="{ active: activeTab === 'stopped' }" @click="switchTab('stopped')">已停用 <span class="badge">{{ stoppedCount }}</span></div>
      <div class="tab" :class="{ active: activeTab === 'pending' }" @click="switchTab('pending')">待激活 <span class="badge">{{ pendingCount }}</span></div>
      <div class="tab text-red" :class="{ active: activeTab === 'risk' }" @click="switchTab('risk')">登录异常 <span class="badge">{{ riskCount }}</span></div>
      <div class="tab-right">
        <span class="update-time">数据更新于 今天 09:35 · 支持按最近登录排序</span>
      </div>
    </div>

    <!-- 5. 数据表格 -->
    <div class="table-card">
      <div class="table-header">
        <span class="title">账号列表 <span class="sub">{{ tableData.length }}</span></span>
        <div class="table-actions">
          <el-button link><el-icon><Operation /></el-icon> 批量操作</el-button>
          <el-button link><el-icon><Setting /></el-icon> 列设置</el-button>
          <el-button link @click="fetchData"><el-icon><Refresh /></el-icon></el-button>
        </div>
      </div>
      
      <!-- 💡 表格的 :data 改为 displayData，配合 Tab 实现前端过滤 -->
      <el-table :data="displayData" style="width: 100%" row-key="id" v-loading="loading">
        <el-table-column type="selection" width="55" />
        <el-table-column label="管理员" min-width="180">
          <template #default="{ row }">
            <div class="user-info">
              <el-avatar :size="36" :style="{ backgroundColor: getAvatarColor(row.realName) }">{{ row.realName?.charAt(0) }}</el-avatar>
              <div class="user-detail">
                <div class="name-row">
                  <span class="real-name">{{ row.realName }}</span>
                  <el-tag v-if="row.role === 'super_admin'" size="small" type="danger" effect="plain" class="role-tag">超级管理员</el-tag>
                </div>
                <span class="username">{{ row.username }}</span>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="角色" width="120">
          <template #default="{ row }">
            <span class="role-text">{{ row.roleName }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="department" label="所属部门" width="120" />
        <el-table-column label="联系方式" width="180">
          <template #default="{ row }">
            <div class="contact-info">
              <div>{{ row.email }}</div>
              <div class="phone">{{ row.phone }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="最近登录" width="160">
          <template #default="{ row }">
            <div class="login-info">
              <div>{{ formatTime(row.lastLoginTime) }}</div>
              <div class="ip">{{ row.lastLoginIp || '-' }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <div class="status-cell">
              <span class="dot" :class="getStatusClass(row.status)"></span>
              <span :class="getStatusTextClass(row.status)">{{ getStatusText(row.status) }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <div class="action-links">
              <el-button link type="primary" size="small" @click="handleView(row)">查看</el-button>
              <el-button link type="primary" size="small" @click="openDrawer('edit', row)">编辑</el-button>
              <el-dropdown trigger="click" @command="(cmd) => handleCommand(cmd, row)">
                <el-button link type="info" size="small"><el-icon><MoreFilled /></el-icon></el-button>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item v-if="row.status === 1" command="disable">停用</el-dropdown-item>
                    <el-dropdown-item v-if="row.status === 0" command="enable">启用</el-dropdown-item>
                    <el-dropdown-item v-if="row.status === 2" command="resend">重发激活</el-dropdown-item>
                    <el-dropdown-item command="delete" divided class="text-red">删除账号</el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </div>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <span class="page-info">显示 1-{{ displayData.length }} 条，共 {{ total }} 条账号</span>
        <el-pagination
          background
          layout="sizes, prev, pager, next"
          :total="total"
          :page-sizes="[10, 20, 50]"
          v-model:current-page="queryParams.page"
          v-model:page-size="queryParams.size"
          @current-change="fetchData"
          @size-change="fetchData"
        />
      </div>
    </div>

    <!-- 6. 新增/编辑抽屉 -->
    <el-drawer v-model="drawerVisible" :title="drawerType === 'create' ? '新增管理员' : '编辑管理员'" size="450px" destroy-on-close>
      <el-form ref="formRef" :model="formData" :rules="rules" label-position="top">
        <el-form-item label="登录账号" prop="username">
          <el-input v-model="formData.username" placeholder="请输入登录账号" :disabled="drawerType === 'edit'" />
        </el-form-item>
        <el-form-item label="姓名" prop="realName">
          <el-input v-model="formData.realName" placeholder="请输入真实姓名" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="formData.phone" placeholder="请输入手机号">
            <template #prepend>+86</template>
          </el-input>
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="formData.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="所属部门" prop="department">
          <el-select v-model="formData.department" placeholder="请选择部门" style="width: 100%">
            <el-option label="运营中心" value="运营中心" />
            <el-option label="技术部" value="技术部" />
            <el-option label="风控合规组" value="风控合规组" />
            <el-option label="内容运营组" value="内容运营组" />
          </el-select>
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="formData.role" placeholder="请选择角色" style="width: 100%">
            <el-option label="超级管理员" value="super_admin" />
            <el-option label="内容运营" value="content_ops" />
            <el-option label="风控管理" value="risk_mgr" />
            <el-option label="数据分析" value="data_analyst" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="formData.remark" type="textarea" :rows="3" placeholder="选填" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="drawerVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="submitForm">保存</el-button>
      </template>
    </el-drawer>

    <!-- 7. 底部安全策略与操作面板 -->
    <el-row :gutter="16" class="bottom-panels">
      <el-col :span="8">
        <el-card shadow="never" class="panel-card">
          <div class="panel-title"><el-icon><Lock /></el-icon> 账号安全策略</div>
          <p class="panel-desc">新密码符合高强度，敏感操作二次验证。</p>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="never" class="panel-card">
          <div class="panel-title"><el-icon><User /></el-icon> 去角色权限配置</div>
          <p class="panel-desc">支持角色权限配置、菜单及数据范围设定。</p>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="never" class="panel-card">
          <div class="panel-title"><el-icon><Clock /></el-icon> 最近账号操作</div>
          <p class="panel-desc">陈可 09:35 停用账号 admin_shenyan</p>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRouter } from 'vue-router'
import { 
  Download, User, Plus, Search, CircleCheck, Warning, WarningFilled, 
  Operation, Setting, Refresh, MoreFilled, Lock, Clock 
} from '@element-plus/icons-vue'
import { getAdminAccounts, updateAdminAccountStatus, saveAdminAccount } from '@/api/admin'

const router = useRouter()

// ================== 状态定义 ==================
const queryParams = ref({
  page: 1,
  size: 10,
  keyword: '',
  role: '',
  status: null,
  department: ''
})

const activeTab = ref('all')
const tableData = ref([])
const total = ref(0)
const loading = ref(false)

// ================== 动态计算统计数字 ==================
const activeCount = computed(() => tableData.value.filter(r => r.status === 1).length)
const stoppedCount = computed(() => tableData.value.filter(r => r.status === 0).length)
const pendingCount = computed(() => tableData.value.filter(r => r.status === 2).length)
// 💡 计算异常风险账号（有 loginAnomaly 标记或者 is2faEnabled 为 0 的）
const riskCount = computed(() => tableData.value.filter(r => r.loginAnomaly === 1 || r.is2faEnabled === 0).length)

// 计算启用占比
const activePercent = computed(() => {
  if (total.value === 0) return 0
  return Math.round((activeCount.value / total.value) * 100)
})

// 💡 前端 Tab 过滤：如果点了“登录异常”，只展示异常数据
const displayData = computed(() => {
  if (activeTab.value === 'risk') {
    return tableData.value.filter(r => r.loginAnomaly === 1 || r.is2faEnabled === 0)
  }
  return tableData.value
})

// 抽屉控制
const drawerVisible = ref(false)
const drawerType = ref('create')
const submitting = ref(false)
const formRef = ref(null)
const formData = ref({})

const rules = {
  username: [{ required: true, message: '请输入登录账号', trigger: 'blur' }],
  realName: [{ required: true, message: '请输入真实姓名', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确', trigger: 'blur' }
  ],
  department: [{ required: true, message: '请选择所属部门', trigger: 'change' }],
  role: [{ required: true, message: '请选择角色', trigger: 'change' }]
}

// ================== 方法 ==================

const fetchData = async () => {
  loading.value = true
  try {
    const res = await getAdminAccounts(queryParams.value)
    // 确保接收到了 loginAnomaly 和 is2faEnabled 字段
    tableData.value = (res.data.records || []).map(item => ({
      ...item,
      loginAnomaly: item.loginAnomaly ?? 0,
      is2faEnabled: item.is2faEnabled ?? 1
    }))
    total.value = res.data.total || 0
  } catch (error) {
    ElMessage.error('获取管理员列表失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  queryParams.value.page = 1
  fetchData()
}

const resetQuery = () => {
  queryParams.value = { page: 1, size: 10, keyword: '', role: '', status: null, department: '' }
  activeTab.value = 'all'
  fetchData()
}

const switchTab = (tab) => {
  activeTab.value = tab
  if (tab === 'all') queryParams.value.status = null
  if (tab === 'active') queryParams.value.status = 1
  if (tab === 'stopped') queryParams.value.status = 0
  if (tab === 'pending') queryParams.value.status = 2
  if (tab === 'risk') queryParams.value.status = null 
  // 注意：登录异常过滤在前端 displayData 做，不需要走后端
  handleSearch()
}

const handleView = (row) => {
  ElMessageBox.alert(`账号：${row.username}<br/>姓名：${row.realName}<br/>角色：${row.roleName}`, '账号详情', {
    dangerouslyUseHTMLString: true
  })
}

const openDrawer = (type, row = null) => {
  drawerType.value = type
  if (type === 'create') {
    formData.value = { username: '', realName: '', phone: '', email: '', department: '', role: 'content_ops', remark: '' }
  } else {
    formData.value = { ...row }
  }
  drawerVisible.value = true
  if (formRef.value) formRef.value.clearValidate()
}

const submitForm = async () => {
  if (!formRef.value) return
  try {
    await formRef.value.validate()
  } catch { return }

  submitting.value = true
  try {
    await saveAdminAccount(formData.value)
    ElMessage.success(drawerType.value === 'create' ? '添加成功' : '修改成功')
    drawerVisible.value = false
    fetchData()
  } catch (e) {
    ElMessage.error('操作失败')
  } finally {
    submitting.value = false
  }
}

const handleCommand = async (command, row) => {
  if (command === 'enable' || command === 'disable') {
    const newStatus = command === 'enable' ? 1 : 0
    try {
      await updateAdminAccountStatus(row.id, newStatus)
      ElMessage.success(`账号已${command === 'enable' ? '启用' : '停用'}`)
      fetchData()
    } catch (e) {
      ElMessage.error('操作失败')
    }
  } else if (command === 'resend') {
    ElMessage.success(`已向 ${row.realName} 的邮箱重发激活链接`)
  } else if (command === 'delete') {
    ElMessageBox.confirm(`确定要删除账号 ${row.username} 吗？此操作不可恢复。`, '警告', {
      type: 'warning',
      confirmButtonText: '删除',
      confirmButtonClass: 'el-button--danger'
    }).then(async () => {
      ElMessage.success('删除成功')
      fetchData()
    }).catch(() => {})
  }
}

const handleExport = () => ElMessage.success('正在导出 CSV...')
const goToRoles = () => router.push('/back/roles')

const formatTime = (timeStr) => {
  if (!timeStr) return '从未登录'
  return timeStr.replace('T', ' ').substring(0, 16)
}

const getStatusText = (status) => {
  const map = { 1: '启用', 0: '已停用', 2: '待激活' }
  return map[status] || '未知'
}

const getStatusClass = (status) => {
  const map = { 1: 'bg-green', 0: 'bg-gray', 2: 'bg-orange' }
  return map[status] || 'bg-gray'
}

const getStatusTextClass = (status) => {
  const map = { 1: 'text-green', 0: 'text-gray', 2: 'text-orange' }
  return map[status] || 'text-gray'
}

const getAvatarColor = (name) => {
  if (!name) return '#cbd5e1'
  const colors = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#06b6d4']
  const index = name.length % colors.length
  return colors[index]
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped lang="scss">
/* 样式与你原来完全一致，这里为了节省篇幅不作修改，直接保留你之前的 CSS 即可 */
.admin-accounts-page {
  padding: 24px;
  background: #f8fafc;
  min-height: 100vh;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 20px;
    h2 { 
      margin: 0 0 8px 0; 
      font-size: 20px; 
      font-weight: 600; 
      display: flex; 
      align-items: center; 
      gap: 8px;
      .count-tag { border-radius: 4px; font-weight: normal; }
    }
    .subtitle { margin: 0; font-size: 13px; color: #64748b; }
    .actions {
      display: flex;
      gap: 12px;
      .btn-export { border-color: #e2e8f0; color: #475569; }
      .btn-add { background: #2563eb; border: none; border-radius: 6px; }
    }
  }

  .stats-row {
    margin-bottom: 20px;
    .stat-card {
      border-radius: 8px;
      border: none;
      box-shadow: 0 1px 3px rgba(0,0,0,0.04);
      :deep(.el-card__body) { padding: 16px 20px; }
      .stat-title {
        font-size: 13px;
        color: #64748b;
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 12px;
      }
      .stat-value {
        font-size: 24px;
        font-weight: 700;
        color: #0f172a;
        margin-bottom: 8px;
        display: flex;
        align-items: center;
        gap: 8px;
        .percent { font-size: 12px; font-weight: normal; color: #64748b; }
        .danger-tag { font-size: 12px; background: #fef2f2; color: #ef4444; padding: 2px 6px; border-radius: 4px; font-weight: normal; }
      }
      .stat-desc { font-size: 12px; color: #94a3b8; }
    }
  }

  .filter-bar {
    display: flex;
    gap: 12px;
    margin-bottom: 16px;
    background: #fff;
    padding: 16px;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.04);
    .search-input { width: 240px; }
    .filter-select { width: 140px; }
  }

  .status-tabs {
    display: flex;
    align-items: center;
    background: #fff;
    padding: 0 16px;
    border-radius: 8px 8px 0 0;
    border-bottom: 1px solid #e2e8f0;
    box-shadow: 0 1px 2px rgba(0,0,0,0.02);
    margin-bottom: 0;
    .tab {
      padding: 16px 16px;
      font-size: 14px;
      color: #475569;
      cursor: pointer;
      border-bottom: 2px solid transparent;
      display: flex;
      align-items: center;
      gap: 6px;
      transition: all 0.2s;
      .badge {
        background: #f1f5f9;
        color: #64748b;
        padding: 0 6px;
        border-radius: 10px;
        font-size: 12px;
      }
      &:hover { color: #2563eb; }
      &.active {
        color: #2563eb;
        font-weight: 600;
        border-bottom-color: #2563eb;
        .badge { background: #eff6ff; color: #2563eb; }
      }
    }
    .tab-right {
      margin-left: auto;
      .update-time { font-size: 12px; color: #94a3b8; }
    }
  }

  .table-card {
    background: #fff;
    border-radius: 0 0 8px 8px;
    padding: 0 16px 16px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.04);
    .table-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 16px 0;
      border-bottom: 1px solid #f1f5f9;
      .title { font-size: 15px; font-weight: 600; color: #0f172a; .sub { color: #94a3b8; font-weight: normal; margin-left: 4px; } }
      .table-actions { display: flex; gap: 12px; .el-button { color: #64748b; font-size: 13px; } }
    }
    :deep(.el-table th) { background: #f8fafc; color: #475569; font-weight: 500; font-size: 13px; border-bottom: none; }
    :deep(.el-table td) { padding: 12px 0; border-bottom: 1px solid #f1f5f9; }
    .user-info {
      display: flex;
      align-items: center;
      gap: 12px;
      .user-detail {
        display: flex;
        flex-direction: column;
        gap: 2px;
        .name-row { display: flex; align-items: center; gap: 6px; }
        .real-name { font-size: 14px; font-weight: 500; color: #0f172a; }
        .role-tag { transform: scale(0.9); transform-origin: left center; }
        .username { font-size: 12px; color: #94a3b8; }
      }
    }
    .role-text { font-size: 13px; color: #334155; }
    .contact-info, .login-info {
      display: flex;
      flex-direction: column;
      gap: 2px;
      font-size: 13px;
      color: #334155;
      .phone, .ip { font-size: 12px; color: #94a3b8; }
    }
    .status-cell {
      display: flex;
      align-items: center;
      gap: 6px;
      font-size: 13px;
      .dot { width: 6px; height: 6px; border-radius: 50%; }
      .bg-green { background: #10b981; }
      .bg-gray { background: #94a3b8; }
      .bg-orange { background: #f59e0b; }
    }
    .action-links {
      display: flex;
      align-items: center;
      gap: 8px;
      .el-button { padding: 0; }
    }
    .pagination-wrapper {
      margin-top: 16px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      .page-info { font-size: 13px; color: #64748b; }
    }
  }

  .bottom-panels {
    margin-top: 20px;
    .panel-card {
      border-radius: 8px;
      border: none;
      box-shadow: 0 1px 3px rgba(0,0,0,0.04);
      :deep(.el-card__body) { padding: 16px; }
      .panel-title {
        font-size: 14px;
        font-weight: 600;
        color: #0f172a;
        display: flex;
        align-items: center;
        gap: 6px;
        margin-bottom: 8px;
        i { color: #2563eb; }
      }
      .panel-desc { margin: 0; font-size: 13px; color: #64748b; }
    }
  }

  .text-green { color: #10b981 !important; }
  .text-orange { color: #f59e0b !important; }
  .text-red { color: #ef4444 !important; }
  .text-gray { color: #94a3b8 !important; }
}
</style>