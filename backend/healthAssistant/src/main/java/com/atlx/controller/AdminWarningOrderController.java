package com.atlx.controller;

import com.atlx.common.Result;
import com.atlx.entity.WarningOrder;
import com.atlx.mapper.WarningOrderMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin/warning-orders")
public class AdminWarningOrderController {

    @Autowired
    private WarningOrderMapper warningOrderMapper;

    /**
     * 获取预警列表数据
     */
    @GetMapping
    public Result<List<WarningOrder>> getWarningList() {
        // 简单粗暴，直接查全表返回（实际开发要加分页和条件筛选）
        List<WarningOrder> list = warningOrderMapper.selectList(null);
        return Result.ok(list);
    }
}