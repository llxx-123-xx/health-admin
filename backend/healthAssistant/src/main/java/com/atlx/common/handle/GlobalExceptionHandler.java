package com.atlx.common.handle; // 如果你的包名叫 handler，这里改成 package com.atlx.handler;

import com.atlx.common.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * 💡 全局异常处理器
 * 拦截所有 Controller 抛出的异常，统一格式返回给前端
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * 1. 拦截【@Valid 参数校验失败】的异常
     * 比如 ResetPasswordDTO 里的 @Email, @Size 校验失败时触发
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Result<?> handleValidException(MethodArgumentNotValidException e) {
        // 获取第一个校验失败的提示信息 (比如："密码长度必须在 8 到 32 位之间")
        FieldError fieldError = e.getBindingResult().getFieldError();
        String message = fieldError != null ? fieldError.getDefaultMessage() : "参数校验失败";

        log.warn("⚠️ 参数校验异常: {}", message);
        return Result.fail("400", message);
    }

    /**
     * 2. 拦截【表单绑定异常】 (普通表单提交时参数类型不匹配)
     */
    @ExceptionHandler(BindException.class)
    public Result<?> handleBindException(BindException e) {
        String message = e.getAllErrors().get(0).getDefaultMessage();
        log.warn("⚠️ 参数绑定异常: {}", message);
        return Result.fail("400", message);
    }

    /**
     * 3. 拦截【兜底异常】 (所有没有被上面捕获的 Exception，比如空指针、SQL报错、Redis连接失败等)
     */
    @ExceptionHandler(Exception.class)
    public Result<?> handleException(Exception e) {
        // 💡 将完整的错误堆栈打印到 IDEA 控制台，方便你排查真实原因
        log.error("💥 系统发生未知异常: ", e);

        // 💡 返回给前端的永远是友好的提示，不暴露底层代码
        return Result.fail("500", "系统繁忙，请稍后再试");
    }
}