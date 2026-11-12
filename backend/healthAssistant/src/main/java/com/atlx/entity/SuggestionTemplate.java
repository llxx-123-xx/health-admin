package com.atlx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("suggestion_template")
public class SuggestionTemplate {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String title;
    private String code;
    private String scaleName;
    private String triggerCondition;
    private String riskLevel;
    private String tone;
    private String content;
    private Integer status;
    private String updater;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}