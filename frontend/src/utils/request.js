// src/utils/request.js
import axios from 'axios'
import { ElMessage } from 'element-plus'

// 创建 axios 实例
const service = axios.create({
  baseURL: '/api', 
  timeout: 15000
})

// 请求拦截器
service.interceptors.request.use(
  config => {
    const token = localStorage.getItem('admin_token')
    if (token) {
      config.headers['Authorization'] = 'Bearer ' + token
    }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// 响应拦截器
service.interceptors.response.use(
  response => {
    const res = response.data
    // 兼容后端返回 200 是字符串或数字的情况
    if (res.code !== '200' && res.code !== 200) {
      ElMessage.error(res.message || '操作失败')
      return Promise.reject(new Error(res.message || '操作失败'))
    }
    return res
  },
  error => {
    // 💡 核心修改：把所有可能的错误路径都挖出来，让你能在控制台看见
    let errorMsg = '网络异常，请稍后重试'
    
    if (error.response) {
      // 后端返回了状态码（如 500, 400）
      if (error.response.status === 401) {
        localStorage.removeItem('admin_token')
        window.location.href = '/login'
        errorMsg = '登录已过期，请重新登录'
      } else {
        // 尝试读取后端的标准错误信息
        errorMsg = error.response.data?.message || error.response.statusText || `服务器错误 (${error.response.status})`
      }
    } else if (error.request) {
      // 请求发出了，但没有响应（比如后端没启动）
      errorMsg = '未连接到服务器，请检查后端是否启动'
    } else {
      // 其他错误
      errorMsg = error.message
    }

    // 打印详细报错到控制台
    console.error('【接口请求异常】:', error.response?.data || error.message)
    
    ElMessage.error(errorMsg)
    return Promise.reject(error)
  }
)

export default service