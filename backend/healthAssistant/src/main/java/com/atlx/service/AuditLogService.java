package com.atlx.service;

import com.atlx.entity.SysAuditLog;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

public interface AuditLogService {
    /**
     * 分页查询审计日志
     * @param page 当前页码
     * @param size 每页条数
     * @param keyword 模糊搜索关键字（日志编号、操作人、操作动作）
     * @param riskLevel 风险等级（danger/warning/normal）
     * @return 分页后的结果
     */

        Page<SysAuditLog> getAuditLogPage(Integer page, Integer size, String keyword, String riskLevel, String status);
    }
