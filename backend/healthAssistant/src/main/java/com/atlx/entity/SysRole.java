package com.atlx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("sys_role")
public class SysRole {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String roleCode;
    private String roleName;
    private String category;
    private String description;
    private Integer status;
    private LocalDateTime createdAt;

    // ================= 💡 新增：用于前端展示的统计字段 =================

    // 告诉 MyBatis-Plus 这个字段在数据库表里不存在，查询时不要报错
    @TableField(exist = false)
    private Integer userCount;

    @TableField(exist = false)
    private Integer permCount;
}