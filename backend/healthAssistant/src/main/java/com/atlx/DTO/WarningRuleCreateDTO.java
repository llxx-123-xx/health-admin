package com.atlx.DTO.command;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import java.util.List;
import java.util.Map;

@Data
public class WarningRuleCreateDTO {
    @NotBlank(message = "规则名称不能为空")
    private String name;
    private String description;
    private String category;
    private String priority;
    private String logic;

    // 前端的复杂数据
    private List<Map<String, Object>> conditions;
    private Map<String, Object> window;
    private Map<String, Object> grading;
    private Map<String, Object> notify;
}