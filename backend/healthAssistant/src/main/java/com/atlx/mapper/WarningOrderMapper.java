package com.atlx.mapper;

import com.atlx.entity.WarningOrder;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

@Mapper // 💡 必须要有这个注解，或者启动类上加了 @MapperScan
public interface WarningOrderMapper extends BaseMapper<WarningOrder> {
}