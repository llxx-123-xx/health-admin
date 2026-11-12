package com.atlx.service;

import com.atlx.DTO.AdminAccountQueryDTO;
import com.atlx.entity.AdminAccount;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * 管理员账号服务接口
 */
public interface AdminAccountService extends IService<AdminAccount> {

    /**
     * 分页条件查询
     */
    Page<AdminAccount> queryPage(AdminAccountQueryDTO query);

    /**
     * 修改状态
     */
    void updateStatus(Long id, Integer status);


}