package com.atlx.common;

import jakarta.annotation.Resource;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;

@Component
public class RedisUtil {

    @Resource
    private StringRedisTemplate stringRedisTemplate;

    // 存入并设置过期时间
    public void set(String key, String value, long timeout, TimeUnit unit) {
        stringRedisTemplate.opsForValue().set(key, value, timeout, unit);
    }

    // 获取
    public String get(String key) {
        return stringRedisTemplate.opsForValue().get(key);
    }

    // 删除
    public void delete(String key) {
        stringRedisTemplate.delete(key);
    }

    // 防重复提交（SETNX）
    public boolean tryLock(String key, String value, long timeout, TimeUnit unit) {
        Boolean success = stringRedisTemplate.opsForValue().setIfAbsent(key, value, timeout, unit);
        return Boolean.TRUE.equals(success);
    }
    /**
     * 存入带过期时间的验证码
     * @param key 键
     * @param value 验证码
     * @param seconds 过期时间（秒）
     */
    public void setCode(String key, String value, long seconds) {
        stringRedisTemplate.opsForValue().set(key, value, seconds, TimeUnit.SECONDS);
    }
}