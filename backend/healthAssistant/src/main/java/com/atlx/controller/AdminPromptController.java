package com.atlx.controller;

import com.atlx.common.Result;
import com.atlx.entity.PromptTemplate;
import com.atlx.mapper.PromptTemplateMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;

@RestController
@RequestMapping("/api/admin/prompt-templates")
public class AdminPromptController {

    @Autowired
    private PromptTemplateMapper promptMapper;

    @GetMapping
    public Result<Page<PromptTemplate>> getList(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size
    ) {
        Page<PromptTemplate> pageInfo = new Page<>(page, size);
        return Result.ok(promptMapper.selectPage(pageInfo, null));
    }

    @PostMapping
    public Result<?> create(@RequestBody PromptTemplate template) {
        template.setStatus(2); // 默认待审核

        // 💡 防止前端没传这几个字段，给个兜底值
        if (template.getVersion() == null || template.getVersion().trim().isEmpty()) {
            template.setVersion("v1.0");
        }
        if (template.getTokens() == null || template.getTokens().trim().isEmpty()) {
            template.setTokens("0");
        }
        if (template.getUpdater() == null || template.getUpdater().trim().isEmpty()) {
            template.setUpdater("系统");
        }

        promptMapper.insert(template);
        return Result.ok("新建成功");
    }
    @PutMapping("/{id}")
    public Result<?> update(@PathVariable Long id, @RequestBody PromptTemplate template) {
        template.setId(id);
        template.setStatus(null);
        promptMapper.updateById(template);
        return Result.ok("修改成功");
    }

    @PutMapping("/{id}/status")
    public Result<?> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        PromptTemplate template = new PromptTemplate();
        template.setId(id);
        template.setStatus(status);
        promptMapper.updateById(template);
        return Result.ok("状态修改成功");
    }

    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id) {
        promptMapper.deleteById(id);
        return Result.ok("删除成功");
    }
    /**
     * 💡 4. 获取审计规则列表 (复用 prompt_template 表)
     */
    @GetMapping("/audit-rules")
    public Result<Page<PromptTemplate>> getAuditRules(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "8") Integer size,
            @RequestParam(required = false) String riskLevel,
            @RequestParam(required = false) String keyword
    ) {
        Page<PromptTemplate> pageInfo = new Page<>(page, size);
        LambdaQueryWrapper<PromptTemplate> queryWrapper = new LambdaQueryWrapper<>();

        // 只查询分类为 audit 的规则
        queryWrapper.eq(PromptTemplate::getCategory, "audit");

        if (keyword != null && !keyword.isEmpty()) {
            queryWrapper.and(w -> w.like(PromptTemplate::getTitle, keyword)
                    .or().like(PromptTemplate::getCode, keyword));
        }
        // 如果有风险等级筛选，这里需要你在实体类里加个 riskLevel 字段，或者暂时忽略
        // queryWrapper.eq(PromptTemplate::getRiskLevel, riskLevel);

        return Result.ok(promptMapper.selectPage(pageInfo, queryWrapper));
    }

    /**
     * 💡 5. 修改审计规则启用/停用状态
     */
    @PutMapping("/audit-rules/{id}/status")
    public Result<?> updateAuditRuleStatus(@PathVariable Long id, @RequestParam Integer status) {
        PromptTemplate template = new PromptTemplate();
        template.setId(id);
        template.setStatus(status); // 1启用 0停用
        promptMapper.updateById(template);
        return Result.ok("状态修改成功");
    }
}