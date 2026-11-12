package com.atlx.service;

import com.atlx.DTO.AuditRuleCreateDTO;
import com.atlx.entity.PromptTemplate;
import com.baomidou.mybatisplus.extension.service.IService;

public interface PromptTemplateService extends IService<PromptTemplate> {
    // 💡 补上这两个方法声明
    PromptTemplate createAuditRule(AuditRuleCreateDTO dto);
    String generateAuditRuleCode();
}