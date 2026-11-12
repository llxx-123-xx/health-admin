package com.atlx;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.atlx.mapper") // 💡 加上这一行，告诉 Spring 去哪找 Mapper
public class AiSpringApplication {
    public static void main(String[] args) {
        SpringApplication.run(AiSpringApplication.class, args);
    }
}