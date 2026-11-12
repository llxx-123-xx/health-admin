package com.atlx.controller;

import com.atlx.annotation.AuditLog;
import com.atlx.common.Result;
import com.atlx.entity.Food;
import com.atlx.service.FoodService;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/foods")
@RequiredArgsConstructor
public class AdminFoodController {

    // 💡 只注入 Service
    private final FoodService foodService;

    /**
     * 1. 获取列表
     */
    @GetMapping
    public Result<Page<Food>> getList(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size
    ) {
        return Result.ok(foodService.getFoodPage(page, size));
    }

    /**
     * 2. 新建食物
     */
    @AuditLog(action = "新增食物数据", riskLevel = "normal")
    @PostMapping
    public Result<?> create(@RequestBody Food food) {
        foodService.createFood(food);
        return Result.ok("新增成功", null);
    }

    /**
     * 3. 修改食物
     */
    @AuditLog(action = "修改食物信息", riskLevel = "warning")
    @PutMapping("/{id}")
    public Result<?> update(@PathVariable Long id, @RequestBody Food food) {
        foodService.updateFood(id, food);
        return Result.ok("修改成功", null);
    }

    /**
     * 4. 修改状态
     */
    @AuditLog(action = "修改食物状态", riskLevel = "warning")
    @PutMapping("/{id}/status")
    public Result<?> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        if (status != 0 && status != 1 && status != 2) {
            return Result.fail("400", "非法的状态值");
        }
        foodService.updateFoodStatus(id, status);
        return Result.ok("状态修改成功", null);
    }

    /**
     * 5. 删除食物
     */
    @AuditLog(action = "删除食物数据", riskLevel = "danger")
    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id) {
        foodService.deleteFood(id);
        return Result.ok("删除成功", null);
    }

    /**
     * 6. 批量修改状态
     */
    @AuditLog(action = "批量修改食物状态", riskLevel = "danger")
    @PutMapping("/batch-status")
    public Result<?> batchUpdateStatus(@RequestBody List<Long> ids, @RequestParam Integer status) {
        if (ids == null || ids.isEmpty()) {
            return Result.fail("400", "请选择要操作的数据");
        }
        foodService.batchUpdateFoodStatus(ids, status);
        return Result.ok("批量操作成功", null);
    }
}