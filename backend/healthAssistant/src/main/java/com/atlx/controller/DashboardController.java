package com.atlx.controller;

import com.atlx.common.Result;
import com.atlx.service.UserService;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    @Resource
    private UserService userService;

    /**
     * 获取登录页/工作台的统计数据
     */
    @GetMapping("/stats")
    public Result<Map<String, Object>> getStats() {
        Map<String, Object> stats = userService.getDashboardStats();
        return Result.ok(stats);
    }
}