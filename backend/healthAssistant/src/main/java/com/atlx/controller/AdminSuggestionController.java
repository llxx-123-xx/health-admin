package com.atlx.controller;

import com.atlx.common.Result;
import com.atlx.entity.SuggestionTemplate;
import com.atlx.mapper.SuggestionTemplateMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/suggestion-templates")
public class AdminSuggestionController {

    @Autowired
    private SuggestionTemplateMapper suggestionMapper;

    /**
     * 1. 分页获取列表
     */
    @GetMapping
    public Result<Page<SuggestionTemplate>> getList(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size
    ) {
        Page<SuggestionTemplate> pageInfo = new Page<>(page, size);
        Page<SuggestionTemplate> result = suggestionMapper.selectPage(pageInfo, null);
        return Result.ok(result);
    }

    /**
     * 2. 新建文案
     */
    @PostMapping
    public Result<?> create(@RequestBody SuggestionTemplate template) {
        template.setStatus(2); // 默认待审核
        template.setUpdater("系统");
        suggestionMapper.insert(template);
        return Result.ok("新建成功");
    }

    /**
     * 3. 修改文案
     */
    @PutMapping("/{id}")
    public Result<?> update(@PathVariable Long id, @RequestBody SuggestionTemplate template) {
        template.setId(id);
        template.setStatus(null); // 修改基本信息不能直接改状态
        suggestionMapper.updateById(template);
        return Result.ok("修改成功");
    }

    /**
     * 4. 修改状态 (启用/停用/审核)
     */
    @PutMapping("/{id}/status")
    public Result<?> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        if (status != 0 && status != 1 && status != 2) {
            return Result.fail("400", "非法的状态值");
        }
        SuggestionTemplate template = new SuggestionTemplate();
        template.setId(id);
        template.setStatus(status);
        suggestionMapper.updateById(template);
        return Result.ok("状态修改成功");
    }

    /**
     * 5. 删除文案
     */
    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id) {
        suggestionMapper.deleteById(id);
        return Result.ok("删除成功");
    }
}