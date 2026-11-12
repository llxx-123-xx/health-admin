package com.atlx.service.impl;

import com.atlx.DTO.AuditRuleCreateDTO;
import com.atlx.entity.PromptTemplate;
import com.atlx.mapper.PromptTemplateMapper;
import com.atlx.service.PromptTemplateService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;

@Service
public class PromptTemplateServiceImpl extends ServiceImpl<PromptTemplateMapper, PromptTemplate> implements PromptTemplateService {

    @Override
    public PromptTemplate createAuditRule(AuditRuleCreateDTO dto) {
        PromptTemplate template = new PromptTemplate();
        // 1. 拷贝基础属性
        BeanUtils.copyProperties(dto, template);

        // 2. 强制设置分类为 audit
        template.setCategory("audit");

        // 3. 字段名适配（前端传 exclude，数据库叫 exclude_conditions）
        template.setExcludeConditions(dto.getExclude());

        // 4. 生成唯一编码兜底
        if (template.getCode() == null || template.getCode().isEmpty()) {
            template.setCode(generateAuditRuleCode());
        }

        // 5. 必填字段兜底（防止数据库非空约束报错）
        // 💡 重点：如果前端没传 model，默认给 'GPT-4o'，防止报 500
        if (template.getModel() == null || template.getModel().isEmpty()) {
            template.setModel("GPT-4o");
        }
        if (template.getVersion() == null) {
            template.setVersion("v1.0");
        }
        if (template.getUpdater() == null) {
            template.setUpdater("系统");
        }
        if (template.getSimilarityThreshold() == null) {
            template.setSimilarityThreshold(new BigDecimal("0.72"));
        }
        if (template.getHitTimes() == null) {
            template.setHitTimes(1);
        }
        if (template.getStatus() == null) {
            template.setStatus(0);
        }

        // 6. 插入数据库
        this.save(template);
        return template;
    }

    @Override
    public String generateAuditRuleCode() {
        LambdaQueryWrapper<PromptTemplate> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PromptTemplate::getCategory, "audit")
                .likeRight(PromptTemplate::getCode, "R-")
                .orderByDesc(PromptTemplate::getCode)
                .last("LIMIT 1");

        PromptTemplate last = this.getOne(wrapper);
        int next = 1001;

        if (last != null && last.getCode() != null) {
            try {
                String numStr = last.getCode().replace("R-", "");
                next = Integer.parseInt(numStr) + 1;
            } catch (NumberFormatException ignored) {}
        }
        return "R-" + next;
    }
}