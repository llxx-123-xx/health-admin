package com.atlx.service;

import com.atlx.entity.SysAuditLog;
import java.util.List;
import java.util.Map;

public interface DashboardService {
    /**
     * 获取运营工作台的全部统计数据
     */
    Map<String, Object> getDashboardData();

    /**
     * 获取最近的审计日志（用于工作台展示）
     */
    List<SysAuditLog> getRecentLogs(int limit);
}