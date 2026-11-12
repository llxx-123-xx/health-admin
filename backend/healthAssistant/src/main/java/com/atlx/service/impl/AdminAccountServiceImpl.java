package com.atlx.service.impl;

import cn.hutool.core.util.StrUtil;
import com.atlx.DTO.AdminAccountQueryDTO;
import com.atlx.entity.AdminAccount;
import com.atlx.mapper.AdminAccountMapper;
import com.atlx.service.AdminAccountService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

/**
 * 管理员账号服务实现类
 */
@Service
public class AdminAccountServiceImpl extends ServiceImpl<AdminAccountMapper, AdminAccount> implements AdminAccountService {

    @Override
    public Page<AdminAccount> queryPage(AdminAccountQueryDTO query) {
        Page<AdminAccount> page = new Page<>(query.getPage(), query.getSize());
        LambdaQueryWrapper<AdminAccount> wrapper = new LambdaQueryWrapper<>();

        // 关键字模糊搜索（姓名、账号、手机号）
        if (StrUtil.isNotBlank(query.getKeyword())) {
            wrapper.and(w -> w.like(AdminAccount::getUsername, query.getKeyword())
                    .or().like(AdminAccount::getRealName, query.getKeyword())
                    .or().like(AdminAccount::getPhone, query.getKeyword()));
        }

        // 角色过滤
        if (StrUtil.isNotBlank(query.getRole())) {
            wrapper.eq(AdminAccount::getRole, query.getRole());
        }

        // 状态过滤
        if (query.getStatus() != null) {
            wrapper.eq(AdminAccount::getStatus, query.getStatus());
        }

        // 部门过滤
        if (StrUtil.isNotBlank(query.getDepartment())) {
            wrapper.eq(AdminAccount::getDepartment, query.getDepartment());
        }

        // 按创建时间倒序排列
        wrapper.orderByDesc(AdminAccount::getCreatedAt);

        return this.page(page, wrapper);
    }

    @Override
    public void updateStatus(Long id, Integer status) {
        // 用 UpdateWrapper 直接更新状态，避免全字段更新
        AdminAccount account = new AdminAccount();
        account.setId(id);
        account.setStatus(status);
        this.updateById(account);
    }
}