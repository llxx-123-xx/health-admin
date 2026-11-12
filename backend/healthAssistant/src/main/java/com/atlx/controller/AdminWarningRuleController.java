package com.atlx.controller;

import cn.hutool.json.JSONUtil;
import com.atlx.DTO.command.WarningRuleCreateDTO;
import com.atlx.common.Result;
import com.atlx.entity.WarningRule;
import com.atlx.mapper.WarningRuleMapper;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/warning-rules")
public class AdminWarningRuleController {

    @Autowired
    private WarningRuleMapper warningRuleMapper;

    /**
     * 1. 保存新建的预警规则
     */
    @PostMapping
    public Result<?> saveRule(@Valid @RequestBody WarningRuleCreateDTO dto) {
        WarningRule rule = new WarningRule();
        rule.setName(dto.getName());
        rule.setDescription(dto.getDescription());
        rule.setCategory(dto.getCategory());
        rule.setPriority(dto.getPriority());
        rule.setLogic(dto.getLogic());
        rule.setStatus(1); // 默认启用

        // 把前端传来的复杂对象，转成 JSON 字符串存进数据库
        rule.setConditionsJson(JSONUtil.toJsonStr(dto.getConditions()));
        rule.setWindowJson(JSONUtil.toJsonStr(dto.getWindow()));
        rule.setGradingJson(JSONUtil.toJsonStr(dto.getGrading()));
        rule.setNotifyJson(JSONUtil.toJsonStr(dto.getNotify()));

        warningRuleMapper.insert(rule);
        return Result.ok("保存成功");
    }

    /**
     * 2. 获取预警规则列表
     */
    @GetMapping
    public Result<List<WarningRule>> getRuleList() {
        List<WarningRule> list = warningRuleMapper.selectList(null);
        return Result.ok(list);
    }

    /**
     * 3. 修改规则启用/停用状态 (💡 这个必须放在类的大括号里面！)
     */
    @PutMapping("/{id}/status")
    public Result<?> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        WarningRule rule = new WarningRule();
        rule.setId(id);
        rule.setStatus(status);
        warningRuleMapper.updateById(rule);
        return Result.ok("状态修改成功");
    }
} // 💡 注意这个大括号，它是用来结束整个类的