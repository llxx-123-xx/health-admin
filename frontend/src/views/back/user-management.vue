<template>
    <div class="dashboard">
        <!-- 头部区域 -->
        <div class="dashboard-header">
            <div class="header-left">
                <h2 class="page-title">用户管理</h2>
                <div class="sub-info">
                    <p class="page-subtitle">共 {{ totalUsers || 0 }} 位用户</p>
                    <el-icon class="dot-icon">
                        <i class="ri-circle-fill" style="font-size: 6px;"></i>
                    </el-icon>
                    <p class="page-subtitle">敏感字段已默认脱敏</p>
                </div>
            </div>

            <div class="header-right">
                <div class="action-buttons">
                    <el-button class="btn-export" @click="ElMessage.info('导出功能开发中...')">
                        <span>导出脱敏列表</span>
                    </el-button>
                    <el-button type="primary" class="btn-add" @click="handleOpenAddDialog">
                        <span>+ 新建用户</span>
                    </el-button>
                </div>
            </div>
        </div>

        <!-- 搜索框 -->
        <div class="search-box">
            <div class="first-filter">
                <el-input v-model="queryParams.keyword" placeholder="用户ID / 昵称" class="filter-item" clearable />
                <el-input v-model="queryParams.phone" placeholder="手机号" class="filter-item" clearable />
                <el-select v-model="queryParams.status" placeholder="全部状态" class="filter-item" clearable>
                    <el-option label="正常" :value="1" />
                    <el-option label="高风险关注" :value="2" />
                    <el-option label="已禁用" :value="0" />
                </el-select>
                <el-date-picker v-model="queryParams.registerDate" type="date" placeholder="注册时间范围"
                    class="filter-item date-picker" />

                <div class="filter-actions">
                    <el-button type="primary" class="btn-search" @click="handleSearch">查询</el-button>
                    <el-button class="btn-reset" @click="handleReset">重置</el-button>
                </div>
            </div>
        </div>

        <!-- 💡 批量操作栏 (去掉了 v-if，强制显示) -->
        <div class="batch-toolbar">
            <div class="batch-left">
                <!-- 已选标签 (浅蓝色) -->
                <div class="selected-tag">
                    已选 <span class="highlight">{{ selectedIds.length }}</span> 项
                </div>
                
                <!-- 批量打标签 (灰边) -->
                <el-button class="btn-batch-tag" @click="ElMessage.info('批量打标签开发中...')">
                    <el-icon><PriceTag /></el-icon>
                    <span>批量打标签</span>
                </el-button>
                
                <!-- 批量禁用 (红边) -->
                <el-button class="btn-batch-disable" @click="handleBatchDisable">
                    <el-icon><CircleClose /></el-icon>
                    <span>批量禁用</span>
                </el-button>
            </div>
            <div class="batch-right">
                <el-icon><InfoFilled /></el-icon> 
                <span>查看用户健康数据明细需填写理由并记录审计日志</span>
            </div>
        </div>

        <!-- 数据表格 -->
        <el-table 
            v-loading="loading"
            :data="tableData" 
            style="width: 100%" 
            class="custom-table"
            @selection-change="handleSelectionChange"
            row-key="id"
        >
            <el-table-column type="selection" width="55" align="center" />
            
            <el-table-column label="用户" min-width="160">
                <template #default="{ row }">
                    <div class="user-cell">
                        <el-avatar :size="32" :src="row.avatar" class="avatar">
                            {{ row.nickname ? row.nickname.charAt(0) : 'U' }}
                        </el-avatar>
                        <div class="user-info">
                            <span class="name">{{ row.nickname }}</span>
                            <span class="id">{{ row.userNo }}</span>
                        </div>
                    </div>
                </template>
            </el-table-column>

            <el-table-column prop="phone" label="手机号" width="130" />
            
            <el-table-column label="性别/年龄" width="100">
                <template #default="{ row }">
                    {{ formatGender(row.gender) }} / {{ row.age }}
                </template>
            </el-table-column>

            <el-table-column prop="registerTime" label="注册时间" width="160">
                <template #default="{ row }">
                    {{ formatTime(row.registerTime) }}
                </template>
            </el-table-column>
            <el-table-column prop="lastActiveTime" label="最近活跃" width="160">
                <template #default="{ row }">
                    {{ formatTime(row.lastActiveTime) }}
                </template>
            </el-table-column>
            
            <el-table-column prop="recordDays" label="记录天数" width="100">
                <template #default="{ row }">{{ row.recordDays }} 天</template>
            </el-table-column>
            <el-table-column prop="testCount" label="测评次数" width="100">
                <template #default="{ row }">{{ row.testCount }} 次</template>
            </el-table-column>
            
            <el-table-column label="状态" width="120">
                <template #default="{ row }">
                    <el-tag 
                        :type="getStatusType(row.status)" 
                        effect="light"
                        :class="['status-tag', getStatusClass(row.status)]"
                    >
                        {{ getStatusText(row.status) }}
                    </el-tag>
                </template>
            </el-table-column>

            <el-table-column label="操作" fixed="right" width="220" align="center">
                <template #default="{ row }">
                    <el-button link type="primary" @click="handleDetail(row)">详情</el-button>
                    <el-button link type="primary" @click="handleMessage(row)">消息</el-button>
                    <el-button 
                        link 
                        :type="row.status === 0 ? 'success' : 'danger'" 
                        @click="handleToggleStatus(row)"
                    >
                        {{ row.status === 0 ? '解禁' : '禁用' }}
                    </el-button>
                </template>
            </el-table-column>
        </el-table>

        <div class="pagination-container">
            <span class="total-text">共 {{ totalUsers }} 条，每页 {{ queryParams.pageSize }} 条</span>
            <el-pagination
                v-model:current-page="queryParams.pageNum"
                v-model:page-size="queryParams.pageSize"
                layout="prev, pager, next, jumper"
                :total="totalUsers"
                @current-change="getList"
            />
        </div>

        <!-- ================= 弹窗区 ================= -->
        <el-dialog v-model="addDialogVisible" title="新建用户" width="500px">
            <el-form :model="addForm" label-width="80px">
                <el-form-item label="昵称">
                    <el-input v-model="addForm.nickname" placeholder="请输入用户昵称" />
                </el-form-item>
                <el-form-item label="手机号">
                    <el-input v-model="addForm.phone" placeholder="请输入手机号" />
                </el-form-item>
                <el-form-item label="性别">
                    <el-radio-group v-model="addForm.gender">
                        <el-radio :label="1">男</el-radio>
                        <el-radio :label="2">女</el-radio>
                    </el-radio-group>
                </el-form-item>
                <el-form-item label="年龄">
                    <el-input-number v-model="addForm.age" :min="1" :max="120" />
                </el-form-item>
            </el-form>
            <template #footer>
                <span class="dialog-footer">
                    <el-button @click="addDialogVisible = false">取消</el-button>
                    <el-button type="primary" @click="submitAddUser">确定</el-button>
                </span>
            </template>
        </el-dialog>

        <el-drawer v-model="detailDrawerVisible" title="用户详情" size="400px">
            <el-descriptions :column="1" border v-if="currentUser">
                <el-descriptions-item label="用户ID">{{ currentUser.id }}</el-descriptions-item>
                <el-descriptions-item label="昵称">{{ currentUser.nickname }}</el-descriptions-item>
                <el-descriptions-item label="手机号">{{ currentUser.phone }}</el-descriptions-item>
                <el-descriptions-item label="性别/年龄">{{ formatGender(currentUser.gender) }} / {{ currentUser.age }}</el-descriptions-item>
                <el-descriptions-item label="注册时间">{{ formatTime(currentUser.registerTime) }}</el-descriptions-item>
                <el-descriptions-item label="最近活跃">{{ formatTime(currentUser.lastActiveTime) }}</el-descriptions-item>
                <el-descriptions-item label="记录天数">{{ currentUser.recordDays }} 天</el-descriptions-item>
                <el-descriptions-item label="测评次数">{{ currentUser.testCount }} 次</el-descriptions-item>
                <el-descriptions-item label="当前状态">
                    <el-tag :type="getStatusType(currentUser.status)">{{ getStatusText(currentUser.status) }}</el-tag>
                </el-descriptions-item>
            </el-descriptions>
            <div style="margin-top: 20px; color: #909399; font-size: 12px;">
                * 敏感数据根据系统策略已进行脱敏处理
            </div>
        </el-drawer>

        <el-dialog v-model="messageDialogVisible" title="发送系统消息" width="500px">
            <el-form label-width="80px">
                <el-form-item label="接收人">
                    <el-input v-model="messageForm.nickname" disabled />
                </el-form-item>
                <el-form-item label="消息内容">
                    <el-input type="textarea" v-model="messageForm.content" :rows="4" placeholder="请输入要发送的消息内容..." />
                </el-form-item>
            </el-form>
            <template #footer>
                <span class="dialog-footer">
                    <el-button @click="messageDialogVisible = false">取消</el-button>
                    <el-button type="primary" @click="submitMessage">发送</el-button>
                </span>
            </template>
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { PriceTag, CircleClose, InfoFilled } from '@element-plus/icons-vue'
import { getUserList, updateUserStatus, createUser } from '@/api/admin'
import dayjs from 'dayjs'

// ================= 数据定义 =================
const loading = ref(false)
const tableData = ref([])
const totalUsers = ref(0)
const selectedIds = ref([])

const queryParams = reactive({
    pageNum: 1,
    pageSize: 20,
    keyword: '',
    phone: '',
    status: null,
    registerDate: ''
})

// ================= 获取数据 =================
const getList = async () => {
    loading.value = true
    try {
        const res = await getUserList(queryParams)
        let responseData = res.data && res.data.code ? res.data : res;
        
        if (responseData && (responseData.code === '200' || responseData.code === 200)) {
            const pageInfo = responseData.data || {};
            tableData.value = pageInfo.records || [];
            totalUsers.value = pageInfo.total || 0;
        } else {
            if (responseData && responseData.records) {
                tableData.value = responseData.records;
                totalUsers.value = responseData.total || 0;
            } else {
                ElMessage.error(responseData?.message || '获取数据格式异常');
            }
        }
    } catch (error) {
        console.error('请求出错:', error)
        ElMessage.error('网络请求失败')
    } finally {
        loading.value = false
    }
}

const handleSearch = () => {
    queryParams.pageNum = 1
    getList()
}

const handleReset = () => {
    queryParams.keyword = ''
    queryParams.phone = ''
    queryParams.status = null
    queryParams.registerDate = ''
    handleSearch()
}

// ================= 表格逻辑 =================
const handleSelectionChange = (selection) => {
    selectedIds.value = selection.map(item => item.id)
}

const formatGender = (gender) => {
    if (gender === 1) return '男'
    if (gender === 2) return '女'
    return '未知'
}

const formatTime = (time) => {
    if (!time) return '-';
    return dayjs(time).format('YYYY-MM-DD HH:mm');
}

const getStatusText = (status) => {
    const map = { 0: '已禁用', 1: '正常', 2: '高风险关注' };
    return map[status] || '未知';
}
const getStatusType = (status) => {
    const map = { 0: 'info', 1: 'success', 2: 'danger' };
    return map[status] || 'info';
}
const getStatusClass = (status) => {
    const map = { 0: 'tag-gray', 1: 'tag-green', 2: 'tag-red' };
    return map[status] || '';
}

// ================= 操作逻辑 =================
const handleToggleStatus = async (row) => {
    const newStatus = row.status === 0 ? 1 : 0;
    const actionText = newStatus === 0 ? '禁用' : '解禁';
    
    try {
        await ElMessageBox.confirm(`确认要${actionText}用户 "${row.nickname}" 吗？`, '提示', { type: 'warning' });
        const res = await updateUserStatus({ ids: [row.id], status: newStatus });
        
        const responseData = res.data || res;
        if (responseData.code === '200' || responseData.code === 200) {
            ElMessage.success(`${actionText}成功`);
            getList();
        } else {
            ElMessage.error(responseData.message || '操作失败');
        }
    } catch (e) {}
}

const handleBatchDisable = async () => {
    try {
        await ElMessageBox.confirm(`确认要禁用选中的 ${selectedIds.value.length} 个用户吗？`, '提示', { type: 'warning' });
        const res = await updateUserStatus({ ids: selectedIds.value, status: 0 });
        
        const responseData = res.data || res;
        if (responseData.code === '200' || responseData.code === 200) {
            ElMessage.success('批量禁用成功');
            getList();
        } else {
            ElMessage.error(responseData.message || '操作失败');
        }
    } catch (e) {}
}

// ================= 弹窗逻辑 =================
const addDialogVisible = ref(false)
const addForm = reactive({
    nickname: '',
    phone: '',
    gender: 1,
    age: 18
})

const handleOpenAddDialog = () => {
    addForm.nickname = ''
    addForm.phone = ''
    addForm.gender = 1
    addForm.age = 18
    addDialogVisible.value = true
}

const submitAddUser = async () => {
    if (!addForm.nickname || !addForm.phone) {
        return ElMessage.warning('请填写昵称和手机号')
    }
    
    try {
        // 调用后端接口
        const res = await createUser(addForm)
        const responseData = res.data || res;
        
        if (responseData.code === '200' || responseData.code === 200) {
            ElMessage.success('新建用户成功')
            addDialogVisible.value = false
            getList() // 💡 刷新列表，看到新数据
        } else {
            ElMessage.error(responseData.message || '新建失败')
        }
    } catch (error) {
        console.error('新建出错:', error)
        ElMessage.error('网络请求异常')
    }
}

const detailDrawerVisible = ref(false)
const currentUser = ref(null)

const handleDetail = (row) => {
    currentUser.value = row
    detailDrawerVisible.value = true
}

const messageDialogVisible = ref(false)
const messageForm = reactive({
    id: null,
    nickname: '',
    content: ''
})

const handleMessage = (row) => {
    messageForm.id = row.id
    messageForm.nickname = row.nickname
    messageForm.content = ''
    messageDialogVisible.value = true
}

const submitMessage = () => {
    if (!messageForm.content) {
        return ElMessage.warning('请输入消息内容')
    }
    ElMessage.success(`消息已发送给 ${messageForm.nickname}（模拟）`)
    messageDialogVisible.value = false
}

onMounted(() => {
    getList()
})
</script>

<style scoped lang="scss">
/* 样式完全不变 */
.dashboard-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; }
.dashboard-header .header-left .page-title { font-size: 22px; font-weight: 600; color: #111827; margin: 0 0 8px 0; }
.dashboard-header .header-left .sub-info { display: flex; align-items: center; gap: 8px; }
.dashboard-header .header-left .sub-info .page-subtitle { font-size: 13px; color: #94A3B8; margin: 0; line-height: 1; }
.dashboard-header .header-left .sub-info .dot-icon { color: #94A3B8; display: flex; align-items: center; }
.dashboard-header .header-right .action-buttons { display: flex; align-items: center; gap: 12px; }
.dashboard-header .header-right .action-buttons .el-button { height: 36px; border-radius: 8px; font-size: 14px; display: flex; align-items: center; gap: 6px; padding: 0 16px; margin: 0; }
.dashboard-header .header-right .action-buttons .btn-export { background-color: #FFFFFF; border: 1px solid #E2E8F0; color: #475569; }
.dashboard-header .header-right .action-buttons .btn-export:hover { background-color: #F8FAFC; color: #2563EB; border-color: #2563EB; }
.dashboard-header .header-right .action-buttons .btn-add { background-color: #2563EB; border: none; color: #FFFFFF; }
.dashboard-header .header-right .action-buttons .btn-add:hover { background-color: #1D4ED8; }
.search-box { background-color: #FFFFFF; padding: 16px 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05); }
.search-box .first-filter { display: flex; align-items: center; flex-wrap: wrap; gap: 12px; }
.search-box .first-filter .filter-item { width: 200px; }
.search-box .first-filter .date-picker { width: 240px !important; }
.search-box .first-filter .filter-actions { display: flex; gap: 8px; }
.search-box .first-filter .filter-actions .el-button { margin-left: 10px; height: 36px; border-radius: 6px; padding: 0 20px; }
.search-box .first-filter .filter-actions .btn-search { background-color: #2563EB; border: none; }
.search-box .first-filter .filter-actions .btn-search:hover { background-color: #1D4ED8; }
.search-box .first-filter .filter-actions .btn-reset { background-color: #FFFFFF; border: 1px solid #E2E8F0; color: #475569; }
.search-box .first-filter .filter-actions .btn-reset:hover { color: #2563EB; border-color: #2563EB; }

.batch-toolbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; padding: 0; background: transparent; border: none; }
.batch-toolbar .batch-left { display: flex; align-items: center; gap: 12px; }
.batch-toolbar .batch-left .selected-tag { background-color: #EFF6FF; color: #2563EB; height: 32px; line-height: 32px; padding: 0 12px; border-radius: 6px; font-size: 13px; font-weight: 500; }
.batch-toolbar .batch-left .selected-tag .highlight { font-weight: bold; margin: 0 4px; }
.batch-toolbar .batch-left .el-button { height: 32px; border-radius: 6px; background: #FFFFFF; padding: 0 12px; display: flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 500; margin-left: 0 !important; }
.batch-toolbar .batch-left .btn-batch-tag { border: 1px solid #E2E8F0; color: #475569; }
.batch-toolbar .batch-left .btn-batch-tag .el-icon { color: #64748B; }
.batch-toolbar .batch-left .btn-batch-tag:hover { background-color: #F8FAFC; border-color: #CBD5E1; }
.batch-toolbar .batch-left .btn-batch-disable { border: 1px solid #FECACA; color: #EF4444; }
.batch-toolbar .batch-left .btn-batch-disable .el-icon { color: #EF4444; }
.batch-toolbar .batch-left .btn-batch-disable:hover { background-color: #FEF2F2; border-color: #FCA5A5; }
.batch-toolbar .batch-right { display: flex; align-items: center; gap: 6px; color: #94A3B8; font-size: 13px; }

.custom-table { border-radius: 8px; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05); background: #fff; margin-bottom: 20px; }
.user-cell { display: flex; align-items: center; gap: 10px; }
.user-cell .avatar { background-color: #EFF6FF; color: #2563EB; font-size: 14px; }
.user-cell .user-info { display: flex; flex-direction: column; line-height: 1.4; }
.user-cell .user-info .name { font-weight: 500; color: #1E293B; font-size: 14px; }
.user-cell .user-info .id { font-size: 12px; color: #94A3B8; }
.status-tag { border: none; font-weight: 500; padding: 0 8px; border-radius: 4px; }
.tag-gray { background-color: #F1F5F9; color: #64748B; }
.tag-green { background-color: #F0FDF4; color: #22C55E; }
.tag-red { background-color: #FEF2F2; color: #EF4444; }
.pagination-container { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; }
.pagination-container .total-text { color: #94A3B8; font-size: 13px; }
</style>