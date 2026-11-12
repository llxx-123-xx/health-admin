package com.atlx.controller;

import com.atlx.annotation.AuditLog;
import com.atlx.common.Result;
import com.atlx.entity.Assessment;
import com.atlx.mapper.AssessmentMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/assessments")
public class AdminAssessmentController {

    @Autowired
    private AssessmentMapper assessmentMapper;

    // 1. 获取列表
    @GetMapping
    public Result<List<Assessment>> getList() {
        return Result.ok(assessmentMapper.selectList(null));
    }

    // 2. 修改上下架状态
    @AuditLog(action = "修改量表状态", riskLevel = "warning")
    @PutMapping("/{id}/status")
    public Result<?> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        Assessment assessment = new Assessment();
        assessment.setId(id);
        assessment.setStatus(status);
        assessmentMapper.updateById(assessment);
        return Result.ok("状态修改成功");
    }
}