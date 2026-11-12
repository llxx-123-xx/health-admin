package com.atlx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("chat_audit")
public class ChatAudit {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String sessionId;
    private String userName;
    private String uid;
    private String scene;
    private String model;
    private Integer msgCount;
    private String riskLevel;
    private String ruleHit;
    private Integer score;
    private LocalDateTime lastTime;
    private Integer status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}