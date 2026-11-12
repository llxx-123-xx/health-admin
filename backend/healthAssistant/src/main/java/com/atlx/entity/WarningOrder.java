package com.atlx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("warning_order")
public class WarningOrder {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long ruleId;
    private Long userId;
    private String userName;
    private String uid;
    private String source;
    private String triggerReason;
    private String riskLevel;
    private LocalDateTime triggerTime;
    private String status;
    private Integer isOverdue;
    private String remainTime;
    private LocalDateTime createdAt;
}