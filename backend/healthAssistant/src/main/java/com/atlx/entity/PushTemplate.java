package com.atlx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("push_template")
public class PushTemplate {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String title;
    private String code;
    private String event;
    private String channel;
    private String target;
    private Integer status;
    private String updater;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}