package com.atlx.service.impl;

import com.atlx.entity.Food;
import com.atlx.entity.SysAuditLog;
import com.atlx.mapper.AdminAccountMapper;
import com.atlx.mapper.FoodMapper;
import com.atlx.mapper.SysAuditLogMapper;
import com.atlx.service.DashboardService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class DashboardServiceImpl implements DashboardService {

    private final AdminAccountMapper adminAccountMapper;
    private final FoodMapper foodMapper;
    private final SysAuditLogMapper auditLogMapper;

    @Override
    public Map<String, Object> getDashboardData() {
        Map<String, Object> data = new HashMap<>();

        // ==========================================
        // 💡 真实数据部分（从数据库查）
        // ==========================================

        // 1. 今日新增用户（注：你这里查的是管理员表，如果查普通用户表请换成 UserMapper）
        Long userCount = adminAccountMapper.selectCount(null);
        // 把兜底假数据从 328 改成 5
        data.put("newUsers", userCount != null ? userCount : 5);

        // 2. 食物库总数
        Long foodCount = foodMapper.selectCount(null);
        // 把兜底假数据从 41203 改成 26
        data.put("foodCount", foodCount != null ? foodCount : 26);

        // 3. 待审核食物（status = 2 代表待审核）
        Long pendingFoodCount = foodMapper.selectCount(
                new LambdaQueryWrapper<Food>().eq(Food::getStatus, 2)
        );
        data.put("pendingFoodCount", pendingFoodCount != null ? pendingFoodCount : 0);

        // ==========================================
        // 💡 假数据部分（按你 500 用户量级缩小）
        // ==========================================

        // 日活跃用户：总用户才 500，日活写 38 非常真实
        data.put("activeUsers", 38);

        // 今日测评完成：十几个人测评很正常
        data.put("todayAssessments", 15);

        // 待处理预警：个位数预警
        data.put("pendingWarnings", 3);

        // 5. 附带最近的 5 条审计日志，供前端底部展示
        data.put("recentLogs", getRecentLogs(5));

        return data;
    }

    @Override
    public List<SysAuditLog> getRecentLogs(int limit) {
        return auditLogMapper.selectList(
                new LambdaQueryWrapper<SysAuditLog>()
                        .orderByDesc(SysAuditLog::getCreatedAt)
                        .last("LIMIT " + limit)
        );
    }
}