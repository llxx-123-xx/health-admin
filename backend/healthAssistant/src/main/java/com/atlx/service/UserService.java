package com.atlx.service;

import com.atlx.DTO.BatchStatusReq;
import com.atlx.DTO.UserQueryReq;
import com.atlx.entity.User;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

import java.util.Map;

public interface UserService {
    // 分页查询
    Page<User> getUserPage(UserQueryReq req);
    // 批量修改状态
    void batchUpdateStatus(BatchStatusReq req);
    /**
     * 新建用户
     */
    boolean save(User user);
    // 获取仪表盘统计数据
    Map<String, Object> getDashboardStats();
}