package com.sportx.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class SlotDTO {
    private Long courtId;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private double price;
}

