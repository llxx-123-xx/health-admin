package com.atlx.service;

import com.atlx.entity.Food;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import java.util.List;

public interface FoodService {
    Page<Food> getFoodPage(Integer page, Integer size);
    void createFood(Food food);
    void updateFood(Long id, Food food);
    void updateFoodStatus(Long id, Integer status);
    void deleteFood(Long id);
    void batchUpdateFoodStatus(List<Long> ids, Integer status);
}