package com.atlx.service;

import com.atlx.entity.AdminAccount;
import com.atlx.entity.SysRole;
import com.atlx.common.Result;
import java.util.List;
import java.util.Map;

public interface RoleService {
    // 获取所有角色
    List<SysRole> getAllRoles();

    // 获取某个角色的权限
    Map<String, List<String>> getRolePermissions(String roleCode);

    // 保存某个角色的权限
    Result<?> saveRolePermissions(String roleCode, Map<String, List<String>> permissions);
    // 💡 新增：获取某个角色下的真实成员列表
    List<AdminAccount> getRoleMembers(String roleCode);
}