package com.atlx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 系统审计日志表实体类
 */
@Data
@TableName("sys_audit_log")
public class SysAuditLog {

    /**
     * 主键 ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 日志编号（如：LOG-106402）
     */
    private String logCode;

    /**
     * 操作人姓名
     */
    private String operatorName;

    /**
     * 操作人账号
     */
    private String operatorAccount;

    /**
     * 操作人角色
     */
    private String operatorRole;

    /**
     * 操作动作（如：复核结论变更）
     */
    private String action;

    /**
     * 操作对象（如：会话档案 CS-240612-0087）
     */
    private String target;

    /**
     * 变更摘要（如：待复核 → 确认风险）
     */
    private String changeSummary;

    /**
     * 来源 IP
     */
    private String sourceIp;

    /**
     * 风险等级（danger/warning/normal）
     */
    private String riskLevel;

    /**
     * 执行结果（success/fail）
     */
    private String status;

    /**
     * 操作时间
     */
    private LocalDateTime createdAt;
}