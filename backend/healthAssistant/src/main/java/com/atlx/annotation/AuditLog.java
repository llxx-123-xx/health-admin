package com.atlx.annotation;

import java.lang.annotation.*;

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface AuditLog {
    /** 操作名称，如：修改量表状态 */
    String action() default "";

    /** 风险等级：danger / warning / normal */
    String riskLevel() default "normal";
}