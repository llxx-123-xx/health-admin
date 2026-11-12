package com.atlx.DTO; // 建议放在 dto 包下

import lombok.Data;

@Data
public class UserQueryReq {
    private Integer pageNum = 1;
    private Integer pageSize = 20;
    private String keyword; // 支持用户ID或昵称
    private String phone;
    private Integer status; // 全部状态
    private String startDate; // 注册时间范围
    private String endDate;
}