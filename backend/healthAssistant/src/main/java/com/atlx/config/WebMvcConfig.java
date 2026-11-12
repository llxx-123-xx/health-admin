package com.atlx.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Autowired
    private PermissionInterceptor permissionInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(permissionInterceptor)
                .addPathPatterns("/api/admin/**") // 拦截所有管理端接口
                .excludePathPatterns(
                        "/api/auth/**",          // 放行登录注册
                        "/api/admin/roles/list", // 放行获取所有角色（下拉框需要）
                        "/api/admin/dashboard/**" // 放行工作台首页
                );
    }
}