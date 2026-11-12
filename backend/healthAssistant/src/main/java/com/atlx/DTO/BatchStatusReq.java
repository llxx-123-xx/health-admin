package com.atlx.DTO;

import lombok.Data;
import java.util.List;

@Data
public class BatchStatusReq {
    private List<Long> ids;
    private Integer status;
}