<template>
  <div class="common-layout">
    <el-container class="layout-container">
      <!-- 侧边栏区域 -->
      <el-aside width="220px" class="sidebar-aside">
        <div class="sidebar">
          <!-- 品牌区 -->
          <div class="brand">
            <div class="logo-box">
              <el-icon size="20" color="#FFFFFF"><i class="ri-heart-pulse-line"></i></el-icon>
            </div>
            <div class="brand-text">
              <h2 class="brand-title">Health Hub</h2>
              <span class="brand-subtitle">运营管理后台</span>
            </div>
          </div>

          <!-- 导航菜单区 (动态权限渲染) -->
          <el-menu :default-active="$route.path" class="el-menu-vertical" :router="true">
            <el-menu-item v-if="hasPerm('dashboard')" index="/back/dashboard">
              <el-icon><i class="ri-dashboard-line"></i></el-icon>
              <span>运营工作台</span>
            </el-menu-item>

            <el-menu-item v-if="hasPerm('user')" index="/back/user-management">
              <el-icon><i class="ri-user-line"></i></el-icon>
              <span>用户管理</span>
            </el-menu-item>

            <!-- 内容运营 -->
            <template v-if="hasPerm('scale') || hasPerm('food') || hasPerm('suggestion')">
              <div class="menu-group-title">内容运营</div>
              <el-menu-item v-if="hasPerm('scale')" index="/back/scale-management">
                <el-icon><i class="ri-file-list-3-line"></i></el-icon>
                <span>量表管理</span>
              </el-menu-item>
              <el-menu-item v-if="hasPerm('food')" index="/back/food-library">
                <el-icon><i class="ri-restaurant-line"></i></el-icon>
                <span>食物库管理</span>
              </el-menu-item>
              <el-menu-item v-if="hasPerm('suggestion')" index="/back/suggestion-templates">
                <el-icon><i class="ri-edit-line"></i></el-icon>
                <span>建议文案模板</span>
              </el-menu-item>
              <el-menu-item v-if="hasPerm('suggestion')" index="/back/push-templates">
                <el-icon><i class="ri-notification-3-line"></i></el-icon>
                <span>推送模板</span>
              </el-menu-item>
            </template>

            <!-- AI 运营 -->
            <template v-if="hasPerm('ai')">
              <div class="menu-group-title">AI 运营</div>
              <el-menu-item index="/back/prompt-templates">
                <el-icon><i class="ri-magic-line"></i></el-icon>
                <span>提示词模板</span>
              </el-menu-item>
              <el-menu-item index="/back/conversation-audit">
                <el-icon><i class="ri-message-2-line"></i></el-icon>
                <span>对话审计</span>
              </el-menu-item>
            </template>

            <!-- 风险管理 -->
            <template v-if="hasPerm('risk')">
              <div class="menu-group-title">风险管理</div>
              <el-menu-item index="/back/warning-rules">
                <el-icon><i class="ri-shield-check-line"></i></el-icon>
                <span>预警规则</span>
              </el-menu-item>
              <el-menu-item index="/back/risk-alerts">
                <el-icon><i class="ri-alarm-warning-line"></i></el-icon>
                <span>预警列表</span>
              </el-menu-item>
            </template>

            <!-- 系统管理 -->
            <template v-if="hasPerm('system')">
              <div class="menu-group-title">系统管理</div>
              <el-menu-item index="/back/admin-accounts">
                <el-icon><i class="ri-admin-line"></i></el-icon>
                <span>管理员账号</span>
              </el-menu-item>
              <el-menu-item index="/back/roles">
                <el-icon><i class="ri-lock-2-line"></i></el-icon>
                <span>角色权限</span>
              </el-menu-item>
              <el-menu-item index="/back/audit-logs">
                <el-icon><i class="ri-file-list-line"></i></el-icon>
                <span>审计日志</span>
              </el-menu-item>
            </template>
          </el-menu>
        </div>
      </el-aside>

      <!-- 右侧主体区域 -->
      <el-container class="main-container">
        <!-- 顶部导航 -->
        <el-header class="header">
          <div class="header-left">
            <el-icon><i class="ri-home-4-line"></i></el-icon>
            <span>{{ $route.meta.group || '运营管理' }}</span>
            <el-icon><i class="ri-arrow-right-wide-line"></i></el-icon>
            <span style="color: #2C3E50; font-weight: 600;">{{ $route.meta.title || '首页' }}</span>
          </div>
          <div class="header-right">
            <el-input v-model="searchKeyword" placeholder="搜索用户ID / 手机号 / 量表名称" class="header-search"
              @keyup.enter="handleSearch" clearable>
              <template #prefix>
                <el-icon><i class="ri-search-line"></i></el-icon>
              </template>
            </el-input>

            <div class="notification-btn">
              <el-icon size="18"><i class="ri-notification-3-line"></i></el-icon>
            </div>

            <!-- 💡 动态显示用户信息 + 退出登录下拉菜单 -->
            <el-dropdown @command="handleCommand" trigger="click">
              <div class="user-info">
                <div class="avatar-text">{{ userInfo?.realName?.charAt(0) || '管' }}</div>
                <div class="user-text">
                  <span class="user-name">{{ userInfo?.realName || '管理员' }}</span>
                  <span class="user-role">{{ userInfo?.roleName || '系统用户' }}</span>
                </div>
                <el-icon style="margin-left: 4px; color: #94A3B8;"><i class="ri-arrow-down-s-line"></i></el-icon>
              </div>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="logout">
                    <el-icon><i class="ri-logout-box-r-line"></i></el-icon> 退出登录
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </el-header>
        
        <!-- 右侧内容区 -->
        <el-main class="main-content">
          <router-view />
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import service from '@/utils/request'

const router = useRouter()
const searchKeyword = ref('')

const userInfo = ref(null)
const permissions = ref([])

// 检查是否有某个模块的权限
const hasPerm = (moduleCode) => {
  if (userInfo.value?.role === 'super_admin') return true
  return permissions.value.includes(moduleCode)
}

const handleSearch = () => {
  if (!searchKeyword.value.trim()) return
  router.push({ 
    path: '/back/user-management', 
    query: { keyword: searchKeyword.value } 
  })
}

// 退出登录逻辑
const handleCommand = (command) => {
  if (command === 'logout') {
    localStorage.removeItem('admin_token')
    localStorage.removeItem('admin_info')
    ElMessage.success('已安全退出')
    router.push('/login')
  }
}

// 加载当前登录人的权限
const loadUserPermission = async () => {
  try {
    const infoStr = localStorage.getItem('admin_info')
    if (infoStr) {
      userInfo.value = JSON.parse(infoStr)
    } else {
      router.push('/login')
      return
    }

    if (userInfo.value?.role) {
      const res = await service.get(`/admin/roles/${userInfo.value.role}/permissions`)
      if (res.code === '200' || res.code === 200) {
        permissions.value = Object.keys(res.data || {})
      }
    }
  } catch (error) {
    console.error('加载用户权限失败', error)
  }
}

onMounted(() => {
  loadUserPermission()
})
</script>

<style scoped lang="scss">
/* 样式保持你之前的原样不变 */
.common-layout {
  height: 100vh; 
  width: 100vw;
  overflow: hidden;
}
.layout-container {
  height: 100%;
}
.main-container {
  flex-direction: column;
  height: 100%;
}
.sidebar-aside {
  background-color: #2C3E50;
  height: 100%;
  .sidebar {
    height: 100%;
    display: flex;
    flex-direction: column;
    .brand {
      padding: 15px 20px;
      border-bottom: 1px solid rgba(255, 255, 255, 0.1);
      display: flex;
      align-items: center;
      gap: 10px;
      flex-shrink: 0; 
      .logo-box {
        width: 36px;
        height: 36px;
        background-color: #2563EB;
        border-radius: 8px;
        display: flex;
        justify-content: center;
        align-items: center;
        flex-shrink: 0;
      }
      .brand-text {
        display: flex;
        flex-direction: column;
        gap: 2px;
      }
      .brand-title {
        color: #FFFFFF;
        font-size: 16px;
        margin: 0;
        font-weight: 700;
        line-height: 1;
      }
      .brand-subtitle {
        color: #94A3B8;
        font-size: 11px;
        line-height: 1;
      }
    }
    .menu-group-title {
      padding: 10px 20px 4px;
      font-size: 12px;
      color: #64748B;
      letter-spacing: 1px;
    }
    .el-menu-vertical {
      border-right: none;
      background-color: transparent;
      flex: 1; 
      overflow-y: auto;
      overflow-x: hidden;
      padding-bottom: 10px;
      &::-webkit-scrollbar { width: 0; }
      :deep(.el-menu-item) {
        height: 36px;
        line-height: 36px;
        margin: 2px 12px;
        border-radius: 6px;
        font-size: 13px;
        color: #CBD5E1;
        background-color: transparent;
        .el-icon { color: #94A3B8; font-size: 16px; }
        &:hover {
          background-color: #3E5266 !important;
          color: #FFFFFF;
          .el-icon { color: #FFFFFF; }
        }
        &.is-active {
          background-color: #2563EB !important;
          color: #FFFFFF !important;
          .el-icon { color: #FFFFFF; }
        }
      }
    }
  }
}
.header {
  background-color: #FFFFFF;
  border-bottom: 1px solid #E2E8F0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 60px;
  padding: 0 20px;
  flex-shrink: 0;
  .header-left {
    font-size: 14px;
    color: #64748B;
    display: flex;
    align-items: center;
    gap: 8px;
  }
  .header-right {
    display: flex;
    align-items: center;
    gap: 16px;
  }
}
.header-search {
  width: 280px;
  flex-shrink: 0;
  :deep(.el-input__wrapper) {
    border-radius: 8px;
    background-color: #F1F5F9;
    box-shadow: none;
    border: 1px solid transparent;
    transition: all 0.3s;
    &.is-focus {
      background-color: #FFFFFF;
      border-color: #2563EB;
    }
  }
  :deep(.el-input__prefix) {
    color: #94A3B8;
  }
}
.notification-btn {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  background-color: #FFFFFF;
  border: 1px solid #E2E8F0;
  display: flex;
  justify-content: center;
  align-items: center;
  color: #64748B;
  cursor: pointer;
  transition: all 0.2s;
  &:hover {
    background-color: #F8FAFC;
    color: #2563EB;
  }
}
.user-info {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  .avatar-text {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    background-color: #2563EB;
    color: #FFFFFF;
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 14px;
    font-weight: 600;
  }
  .user-text {
    display: flex;
    flex-direction: column;
    justify-content: center;
    .user-name {
      font-size: 14px;
      color: #111827;
      font-weight: 600;
      line-height: 1.2;
    }
    .user-role {
      font-size: 12px;
      color: #94A3B8;
      line-height: 1.2;
      margin-top: 2px;
    }
  }
}
.main-content {
  background-color: #F5F7F9;
  padding: 20px;
  overflow-y: auto;
  flex: 1;
  height: 0;
}
</style>