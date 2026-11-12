package com.atlx.service.impl;

import com.atlx.common.RedisUtil;
import com.atlx.common.Result;
import com.atlx.entity.AdminAccount;
import com.atlx.mapper.AdminAccountMapper;
import com.atlx.service.AdminAuthService;
import com.atlx.utils.JwtUtils;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@Service
public class AdminAuthServiceImpl implements AdminAuthService {

    @Autowired
    private AdminAccountMapper adminAccountMapper;

    @Autowired
    private JavaMailSender mailSender;

    @Autowired
    private RedisUtil redisUtil; // 💡 注入 Redis 工具类

    @Value("${spring.mail.username}")
    private String fromEmail;

    // ================= 登录逻辑 =================
    @Override
    public Result<?> login(Map<String, String> loginForm) {
        String username = loginForm.get("username");
        String password = loginForm.get("password");

        if (username == null || password == null) {
            return Result.fail("400", "账号或密码不能为空");
        }

        AdminAccount account = adminAccountMapper.selectOne(
                new LambdaQueryWrapper<AdminAccount>().eq(AdminAccount::getUsername, username)
        );

        if (account == null) {
            return Result.fail("401", "账号不存在");
        }
        if (account.getStatus() == 0) {
            return Result.fail("403", "该账号已被停用，请联系管理员");
        }
        if (account.getStatus() == 2) {
            return Result.fail("403", "账号待审核，请联系管理员");
        }
        if (!password.equals(account.getPassword())) {
            return Result.fail("401", "密码错误");
        }

        String token = JwtUtils.generateToken(account.getId(), account.getUsername());
        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        data.put("userInfo", account);
        return Result.ok("登录成功", data);
    }

    // ================= 发送验证码逻辑 (已改为 Redis) =================
    @Override
    public Result<?> sendCode(String email) {
        if (email == null || email.isEmpty()) {
            return Result.fail("400", "邮箱不能为空");
        }

        String code = String.format("%06d", new Random().nextInt(1000000));

        // 💡 核心修改：存入 Redis，设置 5 分钟 (300秒) 过期
        String redisKey = "verify:code:" + email;
        redisUtil.setCode(redisKey, code, 300);

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(email);
            message.setSubject("Health Hub 注册验证码");
            message.setText("您的验证码是：" + code + "，5分钟内有效。请勿泄露给他人。");
            mailSender.send(message);

            // 测试时在控制台打印，方便查看
            System.out.println("=== 发送验证码到 [" + email + "]： " + code + " ===");

            return Result.ok("验证码已发送至您的邮箱，请查收", null);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.fail("500", "邮件发送失败，请检查邮箱配置");
        }
    }

    // ================= 注册逻辑 (已改为 Redis 校验) =================
    @Override
    public Result<?> register(Map<String, String> registerForm) {
        String email = registerForm.get("email");
        String code = registerForm.get("code");
        String password = registerForm.get("password");
        String realName = registerForm.get("realName");
        String phone = registerForm.get("phone");
        String department = registerForm.get("department");
        String role = registerForm.get("role");

        if (email == null || password == null || realName == null) {
            return Result.fail("400", "请填写完整的必填信息");
        }
        if (code == null || code.isEmpty()) {
            return Result.fail("400", "请输入邮箱验证码");
        }

        // 💡 核心修改：从 Redis 获取验证码进行比对
        String redisKey = "verify:code:" + email;
        String cachedCode = redisUtil.get(redisKey);

        if (cachedCode == null) return Result.fail("400", "验证码已过期或未获取");
        if (!cachedCode.equals(code)) return Result.fail("400", "验证码错误");

        // 验证通过，立刻删除 Redis 中的验证码
        redisUtil.delete(redisKey);

        long count = adminAccountMapper.selectCount(
                new LambdaQueryWrapper<AdminAccount>().eq(AdminAccount::getUsername, email)
        );
        if (count > 0) return Result.fail("400", "该企业邮箱已被注册");

        AdminAccount account = new AdminAccount();
        account.setUsername(email);
        account.setRealName(realName);
        account.setPhone(phone);
        account.setPassword(password);
        account.setRole(role);
        account.setDepartment(department);
        account.setStatus(2); // 待审核

        if ("content_ops".equals(role)) {
            account.setRoleName("运营专员");
        } else if ("data_analyst".equals(role)) {
            account.setRoleName("数据分析");
        } else {
            account.setRoleName("普通管理员");
        }

        adminAccountMapper.insert(account);
        return Result.ok("申请提交成功，请等待管理员审核", null);
    }

    // ================= 校验账号是否存在（忘记密码用） =================
    @Override
    public Result<?> checkAccount(String username) {
        if (username == null || username.trim().isEmpty()) {
            return Result.fail("400", "请输入账号或邮箱");
        }

        long count = adminAccountMapper.selectCount(
                new LambdaQueryWrapper<AdminAccount>().eq(AdminAccount::getUsername, username)
        );

        if (count == 0) {
            return Result.fail("401", "该账号不存在，请确认后重试");
        }
        return Result.ok("账号存在，允许重置", null);
    }

    // ================= 校验验证码接口 (已改为 Redis 校验) =================
    @Override
    public Result<?> verifyCode(Map<String, String> verifyForm) {
        String email = verifyForm.get("email");
        String code = verifyForm.get("code");

        if (email == null || code == null) {
            return Result.fail("400", "邮箱或验证码不能为空");
        }

        // 💡 核心修改：从 Redis 获取验证码
        String redisKey = "verify:code:" + email;
        String cachedCode = redisUtil.get(redisKey);

        if (cachedCode == null) {
            return Result.fail("400", "验证码已过期，请重新获取");
        }
        if (!cachedCode.equals(code)) {
            return Result.fail("400", "验证码错误");
        }

        // 验证通过，立刻销毁 Redis 中的验证码，防止重复使用
        redisUtil.delete(redisKey);

        return Result.ok("身份验证通过", null);
    }

    // ================= 重置密码逻辑 =================
    @Override
    public Result<?> resetPassword(String email, String password) {
        AdminAccount account = adminAccountMapper.selectOne(
                new LambdaQueryWrapper<AdminAccount>().eq(AdminAccount::getUsername, email)
        );
        if (account == null) {
            return Result.fail("401", "账号不存在");
        }

        account.setPassword(password);
        adminAccountMapper.updateById(account);

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(email);
            message.setSubject("Health Hub 密码重置成功通知");
            message.setText("您好 " + account.getRealName() + "：\n\n" +
                    "您的 Health Hub 运营后台账号密码已于 " + new java.util.Date() + " 成功重置。\n" +
                    "如果这不是您本人的操作，请立即联系 IT 管理员 (chenke@healthhub.cn) 冻结账号。\n\n" +
                    "Health Hub 安全中心");
            mailSender.send(message);
        } catch (Exception e) {
            System.err.println("密码重置成功，但通知邮件发送失败：" + e.getMessage());
        }

        return Result.ok("密码重置成功，通知邮件已发送", null);
    }
}