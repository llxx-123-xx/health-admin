<template>
  <div class="roles-page">
    <!-- 1. 页面头部 -->
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">
          角色权限
          <el-tag size="small" type="info" effect="plain">RBAC 2.0</el-tag>
        </h2>
        <p class="page-subtitle">按角色统一配置功能权限与数据可见范围，权限变更实时生效并写入审计日志。</p>
      </div>
      <div class="header-right">
        <el-button class="btn-export"><el-icon><Download /></el-icon> 导出矩阵</el-button>
        <el-button class="btn-export"><el-icon><Document /></el-icon> 权限模板库</el-button>
        <el-button type="primary" class="btn-add" @click="handleCreateRole"><el-icon><Plus /></el-icon> 新增角色</el-button>
      </div>
    </div>

    <!-- 2. 顶部统计卡片 -->
    <el-row :gutter="16" class="stats-row">
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">角色总数 <el-icon class="right-icon" color="#3b82f6"><User /></el-icon></div>
          <div class="stat-value">{{ roleList.length }}</div>
          <div class="stat-desc">内置 {{ systemCount }} · 自定义 {{ customCount }}</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">启用中角色 <el-icon class="right-icon" color="#10b981"><CircleCheck /></el-icon></div>
          <div class="stat-value text-green">{{ enabledCount }}</div>
          <div class="stat-desc">{{ roleList.length - enabledCount }} 个角色已停用</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">已授权成员 <el-icon class="right-icon" color="#8b5cf6"><UserFilled /></el-icon></div>
          <div class="stat-value"><span class="text-purple">{{ totalUserCount }}</span> 人</div>
          <div class="stat-desc">覆盖全系统真实管理员</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-title">近 7 天权限变更 <el-icon class="right-icon" color="#f59e0b"><Warning /></el-icon></div>
          <div class="stat-value text-orange">12 次</div>
          <div class="stat-desc">较上周 +3 次</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 3. 主体内容区 -->
    <div class="main-content">
      <!-- 左侧：角色列表 -->
      <div class="left-menu">
        <div class="menu-header">
          <span>角色列表 <span class="sub">({{ filteredRoles.length }})</span></span>
          <el-button link type="primary" @click="handleCreateRole"><el-icon><Plus /></el-icon></el-button>
        </div>
        <div class="menu-search">
          <el-input v-model="searchRole" placeholder="搜索角色名称" size="small" clearable>
            <template #prefix><el-icon><Search /></el-icon></template>
          </el-input>
        </div>

        <div class="menu-tabs">
          <span class="tab active">全部 <span class="badge">{{ roleList.length }}</span></span>
          <span class="tab">内置 <span class="badge">{{ systemCount }}</span></span>
          <span class="tab">自定义 <span class="badge">{{ customCount }}</span></span>
        </div>

        <ul class="menu-list">
          <li 
            v-for="(role, index) in filteredRoles" 
            :key="role.id" 
            :class="{ active: currentRole?.roleCode === role.roleCode }"
            @click="selectRole(role)"
          >
            <div class="role-icon" :style="{ background: getIconBg(index), color: getIconColor(index) }">
              <el-icon><component :is="getIcon(index)" /></el-icon>
            </div>
            <div class="role-info">
              <div class="name-row">
                <span class="name">{{ role.roleName }}</span>
                <el-tag v-if="role.category === 'system'" size="small" type="info" effect="plain">内置</el-tag>
                <el-tag v-else size="small" type="success" effect="plain">自定义</el-tag>
                <el-tag v-if="role.status === 0" size="small" type="danger" effect="plain">停用</el-tag>
              </div>
              <div class="role-desc">{{ role.userCount || 0 }} 名成员 · {{ role.permCount || 0 }} 项权限</div>
            </div>
          </li>
        </ul>

        <div class="menu-footer">
          <div class="tip-title"><el-icon><Warning /></el-icon> 推荐做法</div>
          <p>优先使用权限模板库中的行业预置角色，可减少 80% 的配置与试错。</p>
          <el-button size="small" plain style="width: 100%">了解权限模板</el-button>
        </div>
      </div>

      <!-- 右侧：权限配置 -->
      <div class="right-content" v-if="currentRole">
        <div class="role-header">
          <div class="info">
            <div class="title-row">
              <div class="role-avatar"><el-icon><User /></el-icon></div>
              <div>
                <h3>
                  {{ currentRole.roleName }} 
                  <el-tag size="small" type="success" effect="plain" v-if="currentRole.status === 1">启用中</el-tag>
                  <el-tag size="small" type="info" effect="plain">{{ currentRole.category === 'system' ? '内置角色' : '自定义角色' }}</el-tag>
                </h3>
                <p>{{ currentRole.description || '暂无角色描述' }}</p>
              </div>
            </div>
            <div class="meta-row">
              <span><el-icon><Link /></el-icon> {{ currentRole.roleCode }}</span>
              <span><el-icon><User /></el-icon> {{ currentRole.userCount || 0 }} 名成员</span>
              <span><el-icon><Calendar /></el-icon> 创建于 {{ currentRole.createdAt ? currentRole.createdAt.substring(0, 10) : '未知' }}</span>
            </div>
          </div>
          <div class="actions">
            <el-button size="small" @click="handleCopyRole"><el-icon><CopyDocument /></el-icon> 复制</el-button>
            <el-button size="small" @click="handleEditRole"><el-icon><Edit /></el-icon> 编辑</el-button>
            <el-button 
              size="small" 
              type="danger" 
              plain 
              @click="handleToggleStatus"
              :disabled="currentRole?.roleCode === 'super_admin'"
            >
              <el-icon><CircleClose /></el-icon> 
              {{ currentRole?.status === 1 ? '停用' : '启用' }}
            </el-button>
          </div>
        </div>

        <div class="inherit-warning" v-if="currentRole.category === 'system'">
          <el-icon><WarningFilled /></el-icon>
          <span>该角色继承自「内容编辑」，继承的 9 项权限不可单独取消。如需调整父角色或解除继承关系。</span>
        </div>

        <el-tabs v-model="activeTab" class="custom-tabs" @tab-change="handleTabChange">
          <el-tab-pane label="功能权限配置" name="func" />
          
          <el-tab-pane :label="`关联成员 ${currentRole.userCount || 0}`" name="members">
            <el-table :data="memberList" style="width: 100%" v-loading="loadingMembers">
              <el-table-column label="姓名" width="150">
                <template #default="{ row }">
                  <div style="display: flex; align-items: center; gap: 8px;">
                    <el-avatar :size="28" :style="{ background: '#eff6ff', color: '#2563eb' }">{{ row.realName?.charAt(0) }}</el-avatar>
                    <span>{{ row.realName }}</span>
                  </div>
                </template>
              </el-table-column>
              <el-table-column prop="username" label="登录账号" min-width="150" />
              <el-table-column prop="department" label="所属部门" width="120" />
              <el-table-column prop="phone" label="手机号" width="130" />
              <el-table-column label="状态" width="100">
                <template #default="{ row }">
                  <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
                    {{ row.status === 1 ? '启用' : '停用' }}
                  </el-tag>
                </template>
              </el-table-column>
            </el-table>
            <el-empty v-if="memberList.length === 0 && !loadingMembers" description="该角色暂无关联成员" :image-size="80" />
          </el-tab-pane>
          
          <el-tab-pane label="变更记录" name="logs" />
        </el-tabs>

        <div class="perm-content" v-if="activeTab === 'func'">
          <div class="perm-header">
            <div class="title">功能权限 <span class="sub">7 个模块 · {{ currentRole.permCount || 0 }} 项已授权</span></div>
            <div class="actions">
              <el-button link @click="expandAll">展开全部</el-button>
              <el-button link @click="handleCheckAll(true)">全选</el-button>
              <el-button link @click="handleCheckAll(false)">清空</el-button>
            </div>
          </div>

          <el-table :data="moduleList" style="width: 100%" v-loading="loadingPerms">
            <el-table-column label="权限模块" width="220">
              <template #default="{ row }">
                <div class="module-cell">
                  <div class="mod-icon"><el-icon><Menu /></el-icon></div>
                  <div>
                    <div class="mod-name">{{ row.moduleName }}</div>
                    <div class="mod-desc">{{ row.moduleCode === 'user' ? '4 项' : '3 项' }}</div>
                  </div>
                </div>
              </template>
            </el-table-column>
            <el-table-column label="查看" width="80" align="center">
              <template #default="{ row }">
                <el-checkbox :model-value="hasPerm(row.moduleCode, 'view')" @change="(val) => togglePerm(row.moduleCode, 'view', val)" />
              </template>
            </el-table-column>
            <el-table-column label="编辑" width="80" align="center">
              <template #default="{ row }">
                <el-checkbox :model-value="hasPerm(row.moduleCode, 'edit')" @change="(val) => togglePerm(row.moduleCode, 'edit', val)" />
              </template>
            </el-table-column>
            <el-table-column label="导出" width="80" align="center">
              <template #default="{ row }">
                <el-checkbox :model-value="hasPerm(row.moduleCode, 'export')" @change="(val) => togglePerm(row.moduleCode, 'export', val)" />
              </template>
            </el-table-column>
            <el-table-column label="删除" width="80" align="center">
              <template #default="{ row }">
                <el-checkbox :model-value="hasPerm(row.moduleCode, 'delete')" @change="(val) => togglePerm(row.moduleCode, 'delete', val)" />
              </template>
            </el-table-column>
          </el-table>

          <div class="perm-footer">
            <div class="tip"><el-icon><InfoFilled /></el-icon> 灰色表示未授权，修改后将立即对 {{ currentRole.userCount || 0 }} 名成员生效</div>
            <div class="btns">
              <el-button @click="resetPermission">取消</el-button>
              <el-button type="primary" @click="savePermissions" :loading="saving"><el-icon><Check /></el-icon> 保存权限</el-button>
            </div>
          </div>

          <div class="data-scope-section">
            <div class="scope-header">
              <span class="title"><el-icon><Lock /></el-icon> 数据权限范围 <span class="sub">决定可查看的用户数据</span></span>
              <el-button link type="primary">调整范围</el-button>
            </div>
            <div class="scope-options">
              <div class="scope-card">
                <el-radio-group v-model="dataScope">
                  <el-radio label="all" border>
                    <div class="radio-title">全部用户</div>
                    <div class="radio-desc">可访问全系统用户档案</div>
                  </el-radio>
                </el-radio-group>
              </div>
              <div class="scope-card">
                <el-radio-group v-model="dataScope">
                  <el-radio label="group" border>
                    <div class="radio-title">按用户分组</div>
                    <div class="radio-desc">仅可访问指定分组的用户</div>
                  </el-radio>
                </el-radio-group>
              </div>
              <div class="scope-card">
                <el-radio-group v-model="dataScope">
                  <el-radio label="mask" border>
                    <div class="radio-title">脱敏视图</div>
                    <div class="radio-desc">仅可查看脱敏字段与标签</div>
                  </el-radio>
                </el-radio-group>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  Download, Document, Plus, User, CircleCheck, UserFilled, Warning, WarningFilled,
  Search, Link, Calendar, Edit, CopyDocument, CircleClose, Menu, InfoFilled, Check, Lock,
  Star, DataAnalysis, Monitor, Service, Setting, Cpu
} from '@element-plus/icons-vue'
import service from '@/utils/request'

const roleList = ref([])
const currentRole = ref(null)
const activeTab = ref('func')
const searchRole = ref('')
const loadingPerms = ref(false)
const loadingMembers = ref(false)
const saving = ref(false)
const dataScope = ref('all')

const memberList = ref([])

const moduleList = ref([
  { moduleName: '用户管理', moduleCode: 'user' },
  { moduleName: '量表管理', moduleCode: 'scale' },
  { moduleName: '食物库管理', moduleCode: 'food' },
  { moduleName: '建议文案与推送模板', moduleCode: 'suggestion' },
  { moduleName: 'AI运营与对话审计', moduleCode: 'ai' },
  { moduleName: '风险预警与用户日志', moduleCode: 'risk' },
  { moduleName: '系统管理与账号权限', moduleCode: 'system' },
])

const rolePermissions = ref({})

const systemCount = computed(() => roleList.value.filter(r => r.category === 'system').length)
const customCount = computed(() => roleList.value.filter(r => r.category === 'custom').length)
const enabledCount = computed(() => roleList.value.filter(r => r.status === 1).length)
const totalUserCount = computed(() => roleList.value.reduce((sum, r) => sum + (r.userCount || 0), 0))

const filteredRoles = computed(() => {
  if (!searchRole.value) return roleList.value
  return roleList.value.filter(r => r.roleName.includes(searchRole.value))
})

const colors = ['#eff6ff', '#f0fdf4', '#fef2f2', '#fffbeb', '#faf5ff', '#ecfeff']
const textColors = ['#2563eb', '#10b981', '#ef4444', '#f59e0b', '#8b5cf6', '#06b6d4']
const icons = ['Star', 'User', 'DataAnalysis', 'Monitor', 'Service', 'Setting', 'Cpu']
const getIconBg = (index) => colors[index % colors.length]
const getIconColor = (index) => textColors[index % textColors.length]
const getIcon = (index) => icons[index % icons.length]

const fetchRoles = async (keepCurrent = false) => {
  try {
    const res = await service.get('/admin/roles')
    if (res.code === '200' || res.code === 200) {
      roleList.value = res.data || []
      if (!keepCurrent && roleList.value.length > 0) {
        const defaultRole = roleList.value.find(r => r.roleCode === 'content_lead') || roleList.value[0]
        selectRole(defaultRole)
      }
    }
  } catch (error) {
    ElMessage.error('获取角色列表失败')
  }
}

const selectRole = async (role) => {
  currentRole.value = role
  activeTab.value = 'func'
  memberList.value = []
  loadingPerms.value = true
  try {
    const res = await service.get(`/admin/roles/${role.roleCode}/permissions`)
    if (res.code === '200' || res.code === 200) {
      rolePermissions.value = res.data || {}
    }
  } catch (error) {
    ElMessage.error('获取角色权限失败')
  } finally {
    loadingPerms.value = false
  }
}

const handleTabChange = async (name) => {
  if (name === 'members' && currentRole.value) {
    loadingMembers.value = true
    try {
      const res = await service.get(`/admin/roles/${currentRole.value.roleCode}/members`)
      if (res.code === '200' || res.code === 200) {
        memberList.value = res.data || []
      }
    } catch (error) {
      ElMessage.error('获取成员列表失败')
    } finally {
      loadingMembers.value = false
    }
  }
}

const hasPerm = (moduleCode, action) => {
  return rolePermissions.value[moduleCode]?.includes(action) || false
}

const togglePerm = (moduleCode, action, checked) => {
  if (!rolePermissions.value[moduleCode]) {
    rolePermissions.value[moduleCode] = []
  }
  if (checked) {
    rolePermissions.value[moduleCode].push(action)
  } else {
    rolePermissions.value[moduleCode] = rolePermissions.value[moduleCode].filter(a => a !== action)
  }
}

const handleCheckAll = (val) => {
  if (val) {
    moduleList.value.forEach(m => {
      rolePermissions.value[m.moduleCode] = ['view', 'edit', 'export', 'delete']
    })
  } else {
    rolePermissions.value = {}
  }
}

// 💡 保存权限逻辑
const savePermissions = async () => {
  if (!currentRole.value) return
  saving.value = true
  try {
    // 1. 调用保存接口
    const res = await service.post(`/admin/roles/${currentRole.value.roleCode}/permissions`, rolePermissions.value)
    if (res.code === '200' || res.code === 200) {
      ElMessage.success('权限保存成功')
      
      // 2. 成功后原地重新拉取该角色的最新权限
      const permRes = await service.get(`/admin/roles/${currentRole.value.roleCode}/permissions`)
      if (permRes.code === '200' || permRes.code === 200) {
        rolePermissions.value = permRes.data || {}
      }
      
      // 3. 更新左侧列表里的统计数字
      await fetchRoles(true)
      const updatedRole = roleList.value.find(r => r.roleCode === currentRole.value.roleCode)
      if (updatedRole) {
        currentRole.value = updatedRole
      }
    }
  } catch (error) {
    ElMessage.error('保存失败')
  } finally {
    saving.value = false
  }
}

const resetPermission = () => {
  selectRole(currentRole.value)
}

const expandAll = () => {
  ElMessage.info('展开全部功能开发中')
}

const handleCreateRole = () => {
  ElMessageBox.prompt('请输入新角色名称', '新增角色', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
  }).then(async ({ value }) => {
    if (!value) return
    try {
      const res = await service.post('/admin/roles', {
        roleName: value,
        roleCode: 'custom_' + Date.now(),
        category: 'custom',
        status: 1
      })
      if (res.code === '200' || res.code === 200) {
        ElMessage.success('角色创建成功')
        fetchRoles()
      }
    } catch (e) {
      ElMessage.error('创建失败')
    }
  }).catch(() => {})
}

const handleCopyRole = () => {
  if (!currentRole.value) return
  ElMessageBox.prompt('请输入新角色名称', '复制角色', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputValue: currentRole.value.roleName + '（副本）',
  }).then(async ({ value }) => {
    if (!value) return
    try {
      const res = await service.post('/admin/roles', {
        roleName: value,
        roleCode: 'copy_' + Date.now(),
        category: 'custom',
        description: currentRole.value.description,
        status: 1
      })
      if (res.code === '200' || res.code === 200) {
        ElMessage.success('角色复制成功')
        fetchRoles()
      }
    } catch (e) {
      ElMessage.error('复制失败')
    }
  }).catch(() => {})
}

const handleEditRole = () => {
  if (!currentRole.value) return
  ElMessageBox.prompt('请输入新的角色名称', '编辑角色', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputValue: currentRole.value.roleName,
  }).then(async ({ value }) => {
    if (!value) return
    try {
      const res = await service.put('/admin/roles', {
        id: currentRole.value.id,
        roleName: value,
        roleCode: currentRole.value.roleCode,
        category: currentRole.value.category,
        status: currentRole.value.status
      })
      if (res.code === '200' || res.code === 200) {
        ElMessage.success('修改成功')
        fetchRoles()
      }
    } catch (e) {
      ElMessage.error('修改失败')
    }
  }).catch(() => {})
}

const handleToggleStatus = async () => {
  if (!currentRole.value) return
  const newStatus = currentRole.value.status === 1 ? 0 : 1
  const actionText = newStatus === 1 ? '启用' : '停用'
  
  try {
    await ElMessageBox.confirm(`确定要${actionText}该角色吗？`, '提示', {
      type: 'warning'
    })
    
    const res = await service.put('/admin/roles', {
      id: currentRole.value.id,
      roleName: currentRole.value.roleName,
      roleCode: currentRole.value.roleCode,
      category: currentRole.value.category,
      status: newStatus
    })
    
    if (res.code === '200' || res.code === 200) {
      ElMessage.success(`${actionText}成功`)
      fetchRoles()
    }
  } catch (e) {
    // 取消操作
  }
}

onMounted(() => {
  fetchRoles()
})
</script>

<style scoped lang="scss">
/* 样式保持原样 */
.roles-page {
  padding: 20px;
  background: #f8fafc;
  min-height: 100vh;

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 20px;
    .header-left {
      .page-title { font-size: 22px; font-weight: 600; color: #111827; margin: 0 0 8px 0; display: flex; align-items: center; gap: 8px; }
      .page-subtitle { font-size: 13px; color: #94a3b8; margin: 0; }
    }
    .header-right {
      display: flex; gap: 12px;
      .el-button { height: 36px; border-radius: 6px; }
      .btn-export { background: #fff; border: 1px solid #e2e8f0; color: #475569; &:hover { color: #2563eb; border-color: #2563eb; } }
      .btn-add { background: #2563eb; border: none; &:hover { background: #1d4ed8; } }
    }
  }

  .stats-row {
    margin-bottom: 20px;
    .stat-card {
      border-radius: 8px; border: none; box-shadow: 0 1px 3px rgba(0,0,0,0.05); padding: 4px;
      .stat-title { font-size: 13px; color: #64748b; display: flex; justify-content: space-between; align-items: center; .right-icon { font-size: 18px; } }
      .stat-value { font-size: 24px; font-weight: 700; color: #111827; margin: 10px 0 6px; }
      .stat-desc { font-size: 12px; color: #94a3b8; }
    }
  }
  .text-green { color: #10b981 !important; }
  .text-purple { color: #8b5cf6 !important; }
  .text-orange { color: #f59e0b !important; }

  .main-content {
    display: flex;
    gap: 20px;

    .left-menu {
      width: 280px;
      background: #fff;
      border-radius: 8px;
      padding: 16px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.05);
      height: fit-content;

      .menu-header {
        display: flex; justify-content: space-between; align-items: center;
        font-size: 14px; font-weight: 600; color: #111827; margin-bottom: 12px;
        .sub { font-size: 12px; color: #94a3b8; font-weight: normal; }
      }
      .menu-search { margin-bottom: 12px; }
      .menu-tabs {
        display: flex; gap: 8px; font-size: 12px; color: #64748b; margin-bottom: 12px;
        .tab { cursor: pointer; padding: 4px 8px; border-radius: 4px;
          &.active { background: #eff6ff; color: #2563eb; font-weight: 500; }
          .badge { margin-left: 4px; }
        }
      }
      .menu-list {
        list-style: none; padding: 0; margin: 0;
        max-height: 450px; overflow-y: auto;
        li {
          display: flex; gap: 12px; padding: 12px; border-radius: 8px; cursor: pointer; margin-bottom: 4px;
          border: 1px solid transparent; transition: all 0.2s;
          &:hover { background: #f8fafc; }
          &.active { background: #eff6ff; border-color: #bfdbfe; }
          .role-icon {
            width: 32px; height: 32px; border-radius: 6px;
            display: flex; align-items: center; justify-content: center; font-size: 18px;
          }
          .role-info {
            flex: 1;
            .name-row { display: flex; align-items: center; gap: 8px; margin-bottom: 4px;
              .name { font-size: 13px; font-weight: 500; color: #111827; }
            }
            .role-desc { font-size: 12px; color: #94a3b8; }
          }
        }
      }
      .menu-footer {
        margin-top: 16px; padding: 12px; background: #f8fafc; border-radius: 8px;
        .tip-title { font-size: 13px; color: #0f172a; font-weight: 600; display: flex; align-items: center; gap: 6px; margin-bottom: 6px; }
        p { font-size: 12px; color: #64748b; line-height: 1.5; margin: 0 0 10px; }
      }
    }

    .right-content {
      flex: 1;
      background: #fff;
      border-radius: 8px;
      padding: 20px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.05);

      .role-header {
        display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px;
        .info {
          .title-row {
            display: flex; gap: 12px; margin-bottom: 12px;
            .role-avatar { width: 40px; height: 40px; background: #eff6ff; color: #2563eb; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 20px; }
            h3 { margin: 0 0 6px; font-size: 18px; display: flex; align-items: center; gap: 8px; }
          }
          p { margin: 0; font-size: 13px; color: #64748b; }
          .meta-row {
            display: flex; gap: 16px; font-size: 12px; color: #94a3b8; margin-top: 12px;
            span { display: flex; align-items: center; gap: 4px; }
          }
        }
      }

      .inherit-warning {
        display: flex; align-items: center; gap: 8px;
        background: #fffbeb; border: 1px solid #fde68a; border-radius: 8px; padding: 12px 16px; margin-bottom: 20px;
        font-size: 13px; color: #b45309;
      }

      .custom-tabs {
        :deep(.el-tabs__header) { margin-bottom: 16px; }
      }

      .perm-content {
        .perm-header {
          display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;
          .title { font-size: 14px; font-weight: 600; color: #111827; .sub { font-size: 12px; color: #94a3b8; font-weight: normal; margin-left: 8px; } }
          .actions { display: flex; gap: 12px; }
        }

        :deep(.el-table th) { background: #f8fafc; color: #475569; font-weight: 500; font-size: 13px; }
        :deep(.el-table td) { padding: 12px 0; }

        .module-cell {
          display: flex; align-items: center; gap: 12px;
          .mod-icon { width: 28px; height: 28px; background: #f1f5f9; border-radius: 6px; display: flex; align-items: center; justify-content: center; color: #64748b; }
          .mod-name { font-size: 13px; color: #111827; font-weight: 500; }
          .mod-desc { font-size: 12px; color: #94a3b8; margin-top: 2px; }
        }

        .perm-footer {
          margin-top: 20px; display: flex; justify-content: space-between; align-items: center;
          .tip { display: flex; align-items: center; gap: 6px; font-size: 12px; color: #94a3b8; }
        }

        .data-scope-section {
          margin-top: 30px;
          padding-top: 20px;
          border-top: 1px dashed #e2e8f0;
          
          .scope-header {
            display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;
            .title { font-size: 14px; font-weight: 600; color: #111827; display: flex; align-items: center; gap: 6px;
              .sub { font-size: 12px; color: #94a3b8; font-weight: normal; margin-left: 8px; }
            }
          }

          .scope-options {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;

            .scope-card {
              :deep(.el-radio) {
                height: auto; padding: 16px; border-radius: 8px; border: 1px solid #e2e8f0; display: flex;
                align-items: flex-start; margin: 0; width: 100%; transition: all 0.2s;
                
                &:hover { border-color: #bfdbfe; }
                &.is-checked { border-color: #2563eb; background: #eff6ff; }
                .el-radio__label { padding-left: 8px; display: flex; flex-direction: column; gap: 4px; }
                .el-radio__input.is-checked .el-radio__inner { background: #2563eb; border-color: #2563eb; }
              }
              .radio-title { font-size: 13px; font-weight: 600; color: #111827; }
              .radio-desc { font-size: 12px; color: #64748b; line-height: 1.4; }
            }
          }
        }
      }
    }
  }
}
</style>