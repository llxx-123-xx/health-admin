package com.atlx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("food_library")
public class Food {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private String code;
    private String category;
    private Integer calories;
    private String carbs;
    private String protein;
    private String fat;
    private String portion;
    private String source;
    private Integer status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}