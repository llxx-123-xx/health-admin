package com.atlx.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("sys_admin")
public class AdminAccount {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String username;
    private String realName;
    private String password;
    private String phone;
    private String email;
    private String role;
    private String roleName;
    private String department;
    private Integer status; // 1启用, 0停用, 2待激活
    private LocalDateTime lastLoginTime;
    private String lastLoginIp;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}