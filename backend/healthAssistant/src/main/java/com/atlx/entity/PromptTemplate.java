package com.atlx.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("prompt_template")
public class PromptTemplate {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String title;
    private String code;
    private String category; // 'audit'
    private String model;    // 💡 必填，前端传来的 model
    private String version;
    private String tokens;
    private Integer status;
    private String updater;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // ================= 扩展字段 =================
    private String ruleCategory; // 业务分类（sensitive/custom等）
    private String level;
    private String scene;
    private String models;
    private String detectType;
    private String comboLogic;
    private String keywordInput;
    private BigDecimal similarityThreshold;
    private Integer hitTimes;

    @TableField("exclude_conditions")
    private String excludeConditions; // 对应数据库的 exclude_conditions

    private String actions;
}