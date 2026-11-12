package com.atlx.DTO;

import lombok.Data;

@Data
public class AdminAccountQueryDTO {
    private Integer page = 1;
    private Integer size = 10;
    private String keyword;     // 姓名/账号/手机号
    private String role;        // 角色筛选
    private Integer status;     // 状态筛选
    private String department;  // 部门筛选
}