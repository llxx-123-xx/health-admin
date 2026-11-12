package com.atlx.entity; // 【关键修复】必须声明包路径

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("sys_user")
public class User {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String userNo;
    private String nickname;
    private String avatar;
    private String phone;
    private Integer gender;
    private Integer age;
    private LocalDateTime registerTime;
    private LocalDateTime lastActiveTime;
    private Integer recordDays;
    private Integer testCount;
    private Integer status; // 1正常 2高风险 0禁用

    @TableLogic
    private Integer isDeleted;
}