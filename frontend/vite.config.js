import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      // 💡 把 @ 指向 src 目录
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  // 💡 新增：配置跨域代理
  server: {
    port: 5173, // 确保你的前端端口是 5173
    proxy: {
      '/api': {
        target: 'http://localhost:1237', // 你的后端端口
        changeOrigin: true // 允许跨域
      }
    }
  }
})