package com.atlx.controller;

import com.atlx.DTO.ResetPasswordDTO;
import com.atlx.common.Result;
import com.atlx.service.AdminAuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AdminLoginController {

    private final AdminAuthService adminAuthService;

    @PostMapping("/login")
    public Result<?> login(@RequestBody Map<String, String> loginForm) {
        return adminAuthService.login(loginForm);
    }

    @GetMapping("/send-code")
    public Result<?> sendCode(@RequestParam String email) {
        return adminAuthService.sendCode(email);
    }

    @PostMapping("/register")
    public Result<?> register(@RequestBody Map<String, String> registerForm) {
        return adminAuthService.register(registerForm);
    }

    // ================= 💡 新增：校验账号是否存在 =================
    @GetMapping("/check-account")
    public Result<?> checkAccount(@RequestParam String username) {
        return adminAuthService.checkAccount(username);
    }
    // 💡 新增：校验验证码接口
    @PostMapping("/verify-code")
    public Result<?> verifyCode(@RequestBody Map<String, String> verifyForm) {
        return adminAuthService.verifyCode(verifyForm);

    }
    // 💡 重置密码接口（使用 @Valid 自动触发校验）
    @PostMapping("/reset-password")
    public Result<?> resetPassword(@Valid @RequestBody ResetPasswordDTO resetForm) {
        // 如果参数不合法（比如密码少于 8 位），Spring 会自动抛出异常，根本走不到这行代码
        return adminAuthService.resetPassword(resetForm.getEmail(), resetForm.getPassword());
    }
}