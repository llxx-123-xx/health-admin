package com.atlx.controller;

import com.atlx.annotation.AuditLog;
import com.atlx.common.Result;
import com.atlx.entity.AdminAccount;
import com.atlx.entity.SysRole;
import com.atlx.service.RoleService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/roles")
@RequiredArgsConstructor
public class RoleController {

    // 💡 只注入 Service，不再直接注入 Mapper
    private final RoleService roleService;

    // 1. 获取所有角色列表
    @GetMapping
    public Result<List<SysRole>> getRoleList() {
        return Result.ok(roleService.getAllRoles());
    }

    // 2. 获取某个角色的权限配置
    @GetMapping("/{roleCode}/permissions")
    public Result<Map<String, List<String>>> getRolePermissions(@PathVariable String roleCode) {
        return Result.ok(roleService.getRolePermissions(roleCode));
    }

    // 3. 保存某个角色的权限配置
    @AuditLog(action = "角色权限变更", riskLevel = "danger")
    @PostMapping("/{roleCode}/permissions")
    public Result<?> saveRolePermissions(@PathVariable String roleCode, @RequestBody Map<String, List<String>> permissions) {
        return roleService.saveRolePermissions(roleCode, permissions);
    }
    // 💡 根据角色编码查询成员列表
    @GetMapping("/{roleCode}/members")
    public Result<List<AdminAccount>> getRoleMembers(@PathVariable String roleCode) {
        return Result.ok(roleService.getRoleMembers(roleCode));
    }
}