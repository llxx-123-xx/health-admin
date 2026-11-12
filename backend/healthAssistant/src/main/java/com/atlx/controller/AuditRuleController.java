package com.atlx.controller;

import com.atlx.DTO.AuditRuleCreateDTO;
import com.atlx.common.Result;
import com.atlx.entity.PromptTemplate;
import com.atlx.service.PromptTemplateService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid; // 注意 Spring Boot 3 使用 jakarta

@RestController
@RequestMapping("/api/admin/prompt-templates/audit-rules")
@RequiredArgsConstructor
public class AuditRuleController {

    private final PromptTemplateService promptTemplateService;

    /**
     * 新建审计规则
     */
    @PostMapping
    public Result<PromptTemplate> create(@Valid @RequestBody AuditRuleCreateDTO dto) {
        // 💡 把 Result.success 改为 Result.ok
        return Result.ok(promptTemplateService.createAuditRule(dto));
    }

    /**
     * 自动生成规则编码
     */
    @GetMapping("/generate-code")
    public Result<String> generateCode() {
        // 💡 把 Result.success 改为 Result.ok
        return Result.ok(promptTemplateService.generateAuditRuleCode());
    }
}