package com.atlx.service.impl;

import com.atlx.entity.Food;
import com.atlx.mapper.FoodMapper;
import com.atlx.service.FoodService;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FoodServiceImpl implements FoodService {

    private final FoodMapper foodMapper;

    @Override
    public Page<Food> getFoodPage(Integer page, Integer size) {
        Page<Food> pageInfo = new Page<>(page, size);
        return foodMapper.selectPage(pageInfo, null);
    }

    @Override
    public void createFood(Food food) {
        food.setStatus(2); // 默认待审核
        foodMapper.insert(food);
    }

    @Override
    public void updateFood(Long id, Food food) {
        food.setId(id);
        food.setStatus(null); // 状态不能通过基本信息修改接口去改
        foodMapper.updateById(food);
    }

    @Override
    public void updateFoodStatus(Long id, Integer status) {
        Food food = new Food();
        food.setId(id);
        food.setStatus(status);
        foodMapper.updateById(food);
    }

    @Override
    public void deleteFood(Long id) {
        foodMapper.deleteById(id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void batchUpdateFoodStatus(List<Long> ids, Integer status) {
        Food food = new Food();
        food.setStatus(status);

        LambdaUpdateWrapper<Food> updateWrapper = new LambdaUpdateWrapper<>();
        updateWrapper.in(Food::getId, ids);

        foodMapper.update(food, updateWrapper);
    }
}