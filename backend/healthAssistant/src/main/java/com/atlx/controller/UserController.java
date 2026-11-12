package com.atlx.controller;

import com.atlx.DTO.UserQueryReq;
import com.atlx.DTO.BatchStatusReq;
import com.atlx.common.RedisUtil;
import com.atlx.common.Result;
import com.atlx.entity.User;
import com.atlx.service.UserService;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;

import java.time.LocalDateTime;
import java.util.concurrent.TimeUnit; // 👈 核心修复：加上这个 import

@RestController
@RequestMapping("/api/admin/users")
public class UserController {

    // 注入 Service 层
    @Resource
    private UserService userService;

    @Resource
    private RedisUtil redisUtil;

    /**
     * 分页查询用户列表
     */
    @GetMapping("/list")
    public Result<Page<User>> list(UserQueryReq req) {
        Page<User> pageData = userService.getUserPage(req);
        return Result.ok(pageData);
    }

    /**
     * 批量修改用户状态 (禁用/启用)
     */
    @PostMapping("/batch-status")
    public Result<?> batchUpdateStatus(@RequestBody BatchStatusReq req) {
        userService.batchUpdateStatus(req);
        return Result.ok("批量操作成功", null);
    }

    /**
     * 新建用户 (包含 Redis 防重复提交和默认字段赋值)
     */
    @PostMapping
    public Result<?> addUser(@RequestBody User user) {
        // 1. 简单校验
        if (user.getNickname() == null || user.getPhone() == null) {
            return Result.fail("500", "昵称和手机号不能为空");
        }

        // 2. 💡 Redis 防重复提交：同一个手机号 3 秒内只能提交一次
        String lockKey = "user:create:" + user.getPhone();
        boolean isLock = redisUtil.tryLock(lockKey, "1", 3, TimeUnit.SECONDS);

        if (!isLock) {
            return Result.fail("429", "操作太频繁，请稍后再试");
        }

        // 3. 设置默认属性
        user.setUserNo("U" + System.currentTimeMillis() % 1000000); // 生成编号
        user.setRegisterTime(LocalDateTime.now());                  // 注册时间
        user.setStatus(1);                                          // 默认状态正常

        // 4. 调用 Service 层保存 (MyBatis-Plus 自带 save 方法)
        boolean success = userService.save(user);

        if (success) {
            return Result.ok("新建成功", null);
        } else {
            return Result.fail("500", "新建失败");
        }
    }
}