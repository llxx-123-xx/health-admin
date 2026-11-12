package com.atlx.service.impl;

import com.atlx.common.Result;
import com.atlx.entity.AdminAccount;
import com.atlx.entity.SysRole;
import com.atlx.entity.SysRolePermission;
import com.atlx.mapper.AdminAccountMapper;
import com.atlx.mapper.SysRoleMapper;
import com.atlx.mapper.SysRolePermissionMapper;
import com.atlx.service.RoleService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class RoleServiceImpl implements RoleService {

    private final SysRoleMapper sysRoleMapper;
    private final SysRolePermissionMapper sysRolePermissionMapper;
    private final AdminAccountMapper adminAccountMapper; // 💡 已经注入好了

    @Override
    public List<SysRole> getAllRoles() {
        List<SysRole> roles = sysRoleMapper.selectList(null);

        for (SysRole role : roles) {
            Long userCount = adminAccountMapper.selectCount(
                    new LambdaQueryWrapper<AdminAccount>().eq(AdminAccount::getRole, role.getRoleCode())
            );
            role.setUserCount(userCount != null ? userCount.intValue() : 0);

            Long permCount = sysRolePermissionMapper.selectCount(
                    new LambdaQueryWrapper<SysRolePermission>().eq(SysRolePermission::getRoleCode, role.getRoleCode())
            );
            role.setPermCount(permCount != null ? permCount.intValue() : 0);
        }
        return roles;
    }

    @Override
    public Map<String, List<String>> getRolePermissions(String roleCode) {
        List<SysRolePermission> list = sysRolePermissionMapper.selectList(
                new LambdaQueryWrapper<SysRolePermission>().eq(SysRolePermission::getRoleCode, roleCode)
        );

        Map<String, List<String>> result = new HashMap<>();
        for (SysRolePermission p : list) {
            result.computeIfAbsent(p.getModuleCode(), k -> new ArrayList<>()).add(p.getActionCode());
        }
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Result<?> saveRolePermissions(String roleCode, Map<String, List<String>> permissions) {
        sysRolePermissionMapper.delete(
                new LambdaQueryWrapper<SysRolePermission>().eq(SysRolePermission::getRoleCode, roleCode)
        );

        if (permissions != null && !permissions.isEmpty()) {
            List<SysRolePermission> newPermissions = new ArrayList<>();
            permissions.forEach((moduleCode, actions) -> {
                if (actions != null) {
                    for (String action : actions) {
                        SysRolePermission p = new SysRolePermission();
                        p.setRoleCode(roleCode);
                        p.setModuleCode(moduleCode);
                        p.setActionCode(action);
                        newPermissions.add(p);
                    }
                }
            });

            for (SysRolePermission p : newPermissions) {
                sysRolePermissionMapper.insert(p);
            }
        }

        return Result.ok("权限保存成功", null);
    }

    // 💡 补上这个方法：去 sys_admin 表查真实成员
    @Override
    public List<AdminAccount> getRoleMembers(String roleCode) {
        return adminAccountMapper.selectList(
                new LambdaQueryWrapper<AdminAccount>().eq(AdminAccount::getRole, roleCode)
        );
    }
}