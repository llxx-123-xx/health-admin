package com.atlx.aspect;

import cn.hutool.core.util.IdUtil;
import com.atlx.annotation.AuditLog;
import com.atlx.entity.AdminAccount;
import com.atlx.entity.SysAuditLog;
import com.atlx.mapper.AdminAccountMapper;
import com.atlx.mapper.SysAuditLogMapper;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

@Slf4j
@Aspect
@Component
@RequiredArgsConstructor
public class AuditLogAspect {

    private final SysAuditLogMapper auditLogMapper;
    private final AdminAccountMapper adminAccountMapper;

    @AfterReturning(pointcut = "@annotation(auditLog)", returning = "result")
    public void recordLog(JoinPoint joinPoint, AuditLog auditLog, Object result) {
        try {
            // 1. 获取请求信息（IP 等）
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            String ip = "未知";
            String username = "未知";
            if (attributes != null) {
                HttpServletRequest request = attributes.getRequest();
                ip = request.getRemoteAddr();
                // 从请求头拿到用户名（前端已在 request.js 里带了）
                username = request.getHeader("X-Username");
            }

            // 2. 根据用户名查操作人信息
            AdminAccount account = null;
            if (username != null && !username.equals("未知")) {
                account = adminAccountMapper.selectOne(
                        new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AdminAccount>()
                                .eq(AdminAccount::getUsername, username)
                );
            }

            // 3. 构建日志对象
            SysAuditLog log = new SysAuditLog();
            log.setLogCode("LOG-" + IdUtil.fastSimpleUUID().substring(0, 8).toUpperCase());
            log.setOperatorName(account != null ? account.getRealName() : "系统");
            log.setOperatorAccount(username);
            log.setOperatorRole(account != null ? account.getRoleName() : "系统");
            log.setAction(auditLog.action());
            log.setRiskLevel(auditLog.riskLevel());
            log.setSourceIp(ip);
            log.setStatus("success");
            // 操作对象可以从方法参数里取（这里简化处理）
            log.setTarget(joinPoint.getSignature().getName());

            auditLogMapper.insert(log);
        } catch (Exception e) {
            log.error("记录审计日志失败", e);
        }
    }
}