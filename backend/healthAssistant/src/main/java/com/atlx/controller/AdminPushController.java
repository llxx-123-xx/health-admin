package com.atlx.controller;

import com.atlx.common.Result;
import com.atlx.entity.PushTemplate;
import com.atlx.mapper.PushTemplateMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/push-templates")
public class AdminPushController {

    @Autowired
    private PushTemplateMapper pushMapper;

    /**
     * 1. 分页获取列表
     */
    @GetMapping
    public Result<Page<PushTemplate>> getList(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size
    ) {
        Page<PushTemplate> pageInfo = new Page<>(page, size);
        Page<PushTemplate> result = pushMapper.selectPage(pageInfo, null);
        return Result.ok(result);
    }

    /**
     * 2. 新建模板
     */
    @PostMapping
    public Result<?> create(@RequestBody PushTemplate template) {
        template.setStatus(2); // 默认待审核
        pushMapper.insert(template);
        return Result.ok("新建成功");
    }

    /**
     * 3. 修改模板
     */
    @PutMapping("/{id}")
    public Result<?> update(@PathVariable Long id, @RequestBody PushTemplate template) {
        template.setId(id);
        template.setStatus(null); // 修改基本信息不能直接改状态
        pushMapper.updateById(template);
        return Result.ok("修改成功");
    }

    /**
     * 4. 修改状态 (启用/停用/审核)
     */
    @PutMapping("/{id}/status")
    public Result<?> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        if (status != 0 && status != 1 && status != 2 && status != 3) {
            return Result.fail("400", "非法的状态值");
        }
        PushTemplate template = new PushTemplate();
        template.setId(id);
        template.setStatus(status);
        pushMapper.updateById(template);
        return Result.ok("状态修改成功");
    }

    /**
     * 5. 删除模板
     */
    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id) {
        pushMapper.deleteById(id);
        return Result.ok("删除成功");
    }
}