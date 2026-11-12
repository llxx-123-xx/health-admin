package com.atlx.controller;

import com.atlx.common.Result;
import com.atlx.entity.ChatAudit;
import com.atlx.mapper.ChatAuditMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/chat-audits")
public class AdminChatAuditController {

    @Autowired
    private ChatAuditMapper chatAuditMapper;

    /**
     * 1. 分页获取对话审计列表
     */
    @GetMapping
    public Result<Page<ChatAudit>> getList(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String risk,
            @RequestParam(required = false) String model
    ) {
        Page<ChatAudit> pageInfo = new Page<>(page, size);

        // 💡 构建查询条件
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<ChatAudit> queryWrapper =
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            queryWrapper.and(w -> w.like(ChatAudit::getSessionId, keyword)
                    .or().like(ChatAudit::getUserName, keyword));
        }
        if (risk != null && !risk.trim().isEmpty()) {
            queryWrapper.eq(ChatAudit::getRiskLevel, risk);
        }
        if (model != null && !model.trim().isEmpty()) {
            queryWrapper.eq(ChatAudit::getModel, model);
        }

        return Result.ok(chatAuditMapper.selectPage(pageInfo, queryWrapper));
    }

    /**
     * 2. 修改复核状态 (1已通过, 2待复核, 3已复核)
     */
    @PutMapping("/{id}/status")
    public Result<?> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        ChatAudit audit = new ChatAudit();
        audit.setId(id);
        audit.setStatus(status);
        chatAuditMapper.updateById(audit);
        return Result.ok("状态修改成功");
    }
}