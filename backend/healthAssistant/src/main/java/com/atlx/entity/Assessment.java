package com.atlx.entity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("assessment")
public class Assessment {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private String code;
    private String category;
    private Integer questionCount;
    private String timeCost;
    private String version;
    private String riskRule;
    private Integer status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}