package com.atlx.DTO;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;
import java.math.BigDecimal;

@Data
public class AuditRuleCreateDTO {
    @NotBlank(message = "规则名称不能为空")
    private String title;
    private String code;
    private String category;
    private String model;
    private String version;

    private String ruleCategory;
    private String level;
    private String scene;
    private String models;
    private String detectType;
    private String comboLogic;
    private String keywordInput;
    private BigDecimal similarityThreshold;
    private Integer hitTimes;
    private String exclude; // 前端传 exclude，实体叫 excludeConditions
    private String actions;
    private Integer status;
}