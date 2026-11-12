import { createApp } from 'vue'
import App from './App.vue'
import router from './router' // 引入路由
import ElementPlus from 'element-plus'
import 'remixicon/fonts/remixicon.css'
import 'element-plus/dist/index.css'
import 'remixicon/fonts/remixicon.css'

const app = createApp(App)
app.use(router) // 挂载路由
app.use(ElementPlus) // 挂载 Element Plus
app.mount('#app')