package com.atlx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("warning_rule")
public class WarningRule {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private String description;
    private String category;
    private String priority;
    private Integer status;
    private String logic;

    // 复杂的嵌套数据直接用 String 接收前端的 JSON
    private String conditionsJson;
    private String windowJson;
    private String gradingJson;
    private String notifyJson;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}