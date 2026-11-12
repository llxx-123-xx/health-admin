package com.atlx.controller;

import cn.hutool.core.util.StrUtil;
import com.atlx.DTO.AdminAccountQueryDTO;
import com.atlx.common.Result;
import com.atlx.entity.AdminAccount;
import com.atlx.service.AdminAccountService;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/accounts")
@RequiredArgsConstructor
public class AdminAccountController {

    private final AdminAccountService adminAccountService;

    // 分页查询列表
    @GetMapping
    public Result<Page<AdminAccount>> list(AdminAccountQueryDTO query) {
        return Result.ok(adminAccountService.queryPage(query));
    }

    // 修改状态 (启用/停用)
    @PutMapping("/{id}/status")
    public Result<?> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        adminAccountService.updateStatus(id, status);
        return Result.ok("状态更新成功", null);
    }

    // 新增管理员
    @PostMapping
    public Result<?> create(@RequestBody AdminAccount account) {
        // 1. 基本参数校验
        if (StrUtil.isBlank(account.getUsername()) || StrUtil.isBlank(account.getRealName())) {
            return Result.fail("400", "登录账号和姓名不能为空");
        }
        if (StrUtil.isBlank(account.getPhone())) {
            return Result.fail("400", "手机号不能为空");
        }

        // 2. 检查账号是否已存在
        boolean exists = adminAccountService.lambdaQuery()
                .eq(AdminAccount::getUsername, account.getUsername())
                .exists();
        if (exists) {
            return Result.fail("400", "该登录账号已存在，请更换");
        }

        // 3. 处理默认密码（实际开发建议用 BCrypt 加密）
        if (StrUtil.isBlank(account.getPassword())) {
            account.setPassword("123456"); // 默认初始密码
        }

        // 4. 自动映射角色名称
        if ("super_admin".equals(account.getRole())) {
            account.setRoleName("超级管理员");
        } else if ("content_ops".equals(account.getRole())) {
            account.setRoleName("内容运营");
        } else {
            account.setRoleName("普通管理员");
        }

        // 5. 设置默认状态为待激活
        if (account.getStatus() == null) {
            account.setStatus(2);
        }

        // 6. 保存到数据库
        adminAccountService.save(account);
        return Result.ok("创建成功，初始密码为 123456", null);
    }
}