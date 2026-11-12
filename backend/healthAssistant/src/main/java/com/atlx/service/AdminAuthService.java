package com.atlx.service;

import com.atlx.common.Result;
import java.util.Map;

public interface AdminAuthService {
    // 登录
    Result<?> login(Map<String, String> loginForm);

    // 发送验证码
    Result<?> sendCode(String email);

    // 注册
    Result<?> register(Map<String, String> registerForm);

    // 校验账号是否存在
    Result<?> checkAccount(String username);

    // 验证码校验逻辑
    Result<?> verifyCode(Map<String, String> verifyForm);

    // 密码重置
    Result<?> resetPassword(String email, String password);
}