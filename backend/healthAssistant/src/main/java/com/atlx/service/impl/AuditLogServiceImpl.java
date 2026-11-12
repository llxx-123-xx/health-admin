package com.atlx.service.impl;

import cn.hutool.core.util.StrUtil;
import com.atlx.entity.SysAuditLog;
import com.atlx.mapper.SysAuditLogMapper;
import com.atlx.service.AuditLogService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuditLogServiceImpl implements AuditLogService {

    private final SysAuditLogMapper auditLogMapper;

    @Override
    @Transactional(rollbackFor = Exception.class, readOnly = true)
    public Page<SysAuditLog> getAuditLogPage(Integer page, Integer size, String keyword, String riskLevel, String status) {
        Page<SysAuditLog> pageInfo = new Page<>(page, size);
        LambdaQueryWrapper<SysAuditLog> wrapper = new LambdaQueryWrapper<>();

        // 1. 关键字模糊查询
        if (StrUtil.isNotBlank(keyword)) {
            wrapper.and(w -> w.like(SysAuditLog::getLogCode, keyword)
                    .or().like(SysAuditLog::getOperatorName, keyword)
                    .or().like(SysAuditLog::getAction, keyword));
        }

        // 2. 风险等级筛选
        if (StrUtil.isNotBlank(riskLevel)) {
            wrapper.eq(SysAuditLog::getRiskLevel, riskLevel);
        }

        // 💡 3. 核心修复：执行结果筛选 (前端传的 status 必须拼到 SQL 里)
        if (StrUtil.isNotBlank(status)) {
            wrapper.eq(SysAuditLog::getStatus, status);
        }

        // 4. 按时间倒序排列
        wrapper.orderByDesc(SysAuditLog::getCreatedAt);

        return auditLogMapper.selectPage(pageInfo, wrapper);
    }
}