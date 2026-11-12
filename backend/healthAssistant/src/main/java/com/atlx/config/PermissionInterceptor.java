package com.atlx.config;

import com.atlx.entity.AdminAccount;
import com.atlx.mapper.AdminAccountMapper;
import com.atlx.service.RoleService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.List;
import java.util.Map;

@Component
public class PermissionInterceptor implements HandlerInterceptor {

    @Autowired
    private RoleService roleService;

    // 💡 新增：注入账号 Mapper，用来查真实的登录角色
    @Autowired
    private AdminAccountMapper adminAccountMapper;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 1. 放行预检请求 (CORS)
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }

        // 2. 获取当前请求的路径
        String uri = request.getRequestURI();

        // 3. 定义需要拦截的路径和对应的权限模块 code
        String requiredModule = null;
        if (uri.startsWith("/api/admin/user-management") || uri.startsWith("/api/admin/users")) {
            requiredModule = "user";
        } else if (uri.startsWith("/api/admin/assessments")) {
            requiredModule = "scale";
        } else if (uri.startsWith("/api/admin/foods")) {
            requiredModule = "food";
        } else if (uri.startsWith("/api/admin/suggestion-templates") || uri.startsWith("/api/admin/push-templates")) {
            requiredModule = "suggestion";
        } else if (uri.startsWith("/api/admin/prompt-templates") || uri.startsWith("/api/admin/chat-audits")) {
            requiredModule = "ai";
        } else if (uri.startsWith("/api/admin/warning-rules") || uri.startsWith("/api/admin/warning-orders")) {
            requiredModule = "risk";
        } else if (uri.startsWith("/api/admin/roles") || uri.startsWith("/api/admin/accounts")) {
            requiredModule = "system";
        }

        // 4. 如果不需要特定权限的接口（比如登录、获取角色列表），直接放行
        if (requiredModule == null) {
            return true;
        }

        // ================= 💡 核心修改：获取当前用户真实角色 =================
        String currentRoleCode = null;

        // 尝试从请求头里拿账号 (临时方案，等你接好 JWT 后换成解析 Token 取角色)
        String usernameHeader = request.getHeader("X-Username");
        if (usernameHeader != null && !usernameHeader.isEmpty()) {
            AdminAccount account = adminAccountMapper.selectOne(
                    new LambdaQueryWrapper<AdminAccount>().eq(AdminAccount::getUsername, usernameHeader)
            );
            if (account != null) {
                currentRoleCode = account.getRole();
            }
        }

        // 如果请求头没带账号（例如前端还没传），为了测试先默认成超级管理员
        if (currentRoleCode == null) {
            currentRoleCode = "super_admin";
        }

        // 💡 核心：如果是超级管理员，所有权限直接放行！
        if ("super_admin".equals(currentRoleCode)) {
            return true;
        }

        // 5. 查该角色的权限
        Map<String, List<String>> permissions = roleService.getRolePermissions(currentRoleCode);

        // 6. 判断有没有 "view" 权限
        List<String> actions = permissions.get(requiredModule);
        if (actions == null || !actions.contains("view")) {
            // 没有权限，返回 403 错误
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"code\":\"403\",\"message\":\"您没有权限访问该模块\"}");
            return false;
        }

        return true;
    }
}