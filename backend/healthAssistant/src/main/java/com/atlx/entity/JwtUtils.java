package com.atlx.utils;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import java.util.Date;

public class JwtUtils {

    // 签名密钥 (生产环境请放在 application.yml 里)
    private static final String SECRET_KEY = "HealthHubSecretKey2024";

    // Token 过期时间：24小时 (单位：毫秒)
    private static final long EXPIRE_TIME = 24 * 60 * 60 * 1000;

    /**
     * 生成 JWT Token
     * @param id 管理员 ID
     * @param username 登录账号
     * @return Token 字符串
     */
    public static String generateToken(Long id, String username) {
        return JWT.create()
                .withClaim("id", id)
                .withClaim("username", username)
                .withExpiresAt(new Date(System.currentTimeMillis() + EXPIRE_TIME))
                .sign(Algorithm.HMAC256(SECRET_KEY));
    }
}